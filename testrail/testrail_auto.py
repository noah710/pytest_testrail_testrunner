# CASE IDS ARE ALL UNIQUE. THEY CANNOT BE CHANGED OR REPEATED

from testrail import *
import os
from datetime import datetime

# This script runs all tests and reports results to testrail

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
    tests_to_list()
    hash_cases()
    
    client = get_client()
    runs = []         # hold ID for runs we need to run
    for run in client.send_get('get_runs/{}'.format(project_id)): # this gets runs that have been created in Testrail
        runID = run.get('id')
        runs.append(runID)
        print("runs" + str(runs))
    for run in runs:
        for test in client.send_get('get_tests/{}'.format(run)):
            caseID = test.get('case_id')
            print(tests_map.get(int(caseID)))
            # run the test, storing the exit code
            result = os.system('pytest {}'.format(tests_map.get(caseID)))
            if (result == 0): # if exited without error, report success (status_id=1)
                client.send_post('add_result_for_case/{}/{}'.format(run, caseID),{ 'status_id': 1, 'comment': str(datetime.now())})
            else: # if non-zero exit code, report failure (status_id=5)
                client.send_post('add_result_for_case/{}/{}'.format(run, caseID),{ 'status_id': 5, 'comment': str(datetime.now())})
if __name__ == "__main__":
    main()
