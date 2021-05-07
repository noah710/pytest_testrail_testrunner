# CASE IDS ARE ALL UNIQUE. THEY CANNOT BE CHANGED OR REPEATED

from testrail import *
import os
from datetime import datetime
import argparse

# THESE NEED T BE FILLED IN
url = ""  
user = ""
pw = ""
tests_path = ''      # path to look for cases in, this is where prod_tests gets copied to in the docker container
project_id = -1             # this can be found in testrail
tests_list = [] # contains absolute paths of each test
tests_map = {}  # contains KEY Case ID mapped to VALUE absolute path of test@Case ID

def get_client():
    client = APIClient(url)
    client.user = user
    client.password = pw
    return client

# creates a list of all absolute paths
def tests_to_list():
    for root, dirs, files in os.walk(tests_path):
        for file in files:
            if file.endswith('.py'):
                tests_list.append(os.path.join(root, file))

# creates a hash map of all the cases, identified by caseID, maps to absolute path
def hash_cases():
    for testpath in tests_list:
        testname = testpath.split('/')[-1]      # full name of test NO PATH
        caseID = testname.split('-')[0]         # CaseID
        if caseID.isnumeric(): # this ensures we only add python scripts following our naming convention
            tests_map.update({int(caseID): testpath})
            print("{}\n{}\n{}".format(testname, caseID, tests_map))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-r", "--run", required=True, help="Run ID - number only!")
    ap.add_argument("-e", "--env", required=True, help="either prod or uat")

    args = vars(ap.parse_args())
    run_id = int(args["run"])
    env = args["env"]

    print("\n\n\n{}\n\n\n".format(run_id))

    tests_to_list()
    hash_cases()
    
    client = get_client()

    if env == "prod":
        os.system('/./testrail/convert_to_prod.sh ' + str(tests_path)) # passing tests location as $1 

    # determine if its a run or a plan, exec accordingly
    plan = False
    try:
        client.send_get('get_tests/{}'.format(run_id))
    except:
        plan = True


    if(plan):
        plan = client.send_get('get_plan/{}'.format(run_id))
        entries = plan.get('entries')
        for entry in entries:
            runs = entry.get('runs')
            for run in runs:
                run_id = run.get('id')
                for test in client.send_get('get_tests/{}'.format(run_id)):
                    case_id = test.get('case_id')
                    # Possible result codes 
                    # 1	Passed
                    # 2	Blocked
                    # 3	Untested (not allowed when adding a result)
                    # 4	Retest
                    # 5	Failed
                    
                    # check if the test exists
                    if(tests_map.get(case_id) is None):
                        client.send_post('add_result_for_case/{}/{}'.format(run_id, case_id),{ 'status_id': 2, 'comment': 'Automated test does not exist!'})
                        continue
                    print("Now running test {}".format(tests_map.get(case_id)))
                    result = os.system('pytest {}'.format(tests_map.get(case_id)))
                    if (result == 0): # if exited without error, report success (status_id=1)
                        client.send_post('add_result_for_case/{}/{}'.format(run_id, case_id),{ 'status_id': 1, 'comment': str(datetime.now())})
                    else: # if non-zero exit code, report failure (status_id=5)
                        client.send_post('add_result_for_case/{}/{}'.format(run_id, case_id),{ 'status_id': 5, 'comment': str(datetime.now())})
    else:

        for test in client.send_get('get_tests/{}'.format(run_id)):
            caseID = test.get('case_id')
            print(tests_map.get(int(caseID)))
            # run the test, storing the exit code
            result = os.system('pytest {}'.format(tests_map.get(caseID)))
            if (result == 0): # if exited without error, report success (status_id=1)
                client.send_post('add_result_for_case/{}/{}'.format(run_id, caseID),{ 'status_id': 1, 'comment': str(datetime.now())})
            else: # if non-zero exit code, report failure (status_id=5)
                client.send_post('add_result_for_case/{}/{}'.format(run_id, caseID),{ 'status_id': 5, 'comment': str(datetime.now())})
if __name__ == "__main__":
    main()
