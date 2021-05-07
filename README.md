# Testrail Tests & Backend Server

This repo holds all test cases as well as a backend server to run tests for Testrail

## Organization

* **prod_tests** - holds all tests available to run on Testrail. Internal organization is irrelevant, feel free to add your own dirs in here.
* **dev_tests**  - holds all tests that are in development that are not ready for use on Testrail
* **testrail**   - holds code for running tests and talking to Testrail API
* **deploy**     - holds all files necessary for deploying the backend server

## Run custom test runs/plan
1. Once you've created a test run on Testrail, find the Run ID (ex. R100)
2. From the office, open your command promt and run ```ssh noah@192.168.10.54 ./run_test -r RUN_ID -e ENVIRONMENT```
* where RUN_ID is the run ID in testrail | Ex. Want to run R14 - ./run_test -r 14
* where ENVIRONMENT is either "uat" or "prod", without the quotes (CaSe SenSiTiVe)

## Installation/Deployment
Deployment of the server is managed with ```testrunner.sh```. By default, the server is deployed to the QA testrunner server in Noah's office. The deployment target can be changed in ```deploy/testrunner.env```. You can also deploy the server locally with the ```-l``` flag. 

### testrunner.sh options
* -a [start|stop|deploy|watch|shell|ssh]
  * **start** - Start a server that has already been deployed
  * **stop** - Stop the running container
  * **deploy** - Deploy the image. **DO THIS EVERY TIME SOMETHING CHANGES**
  * **watch** - Watch the container logs
  * **shell** - ssh into container
  * **ssh** - ssh into host computer
* -l - This is a lowercase L. Use this to interact with local only
### Example usage
*Deploy to QA testrunner server*
```bash
./testrunner.sh -a deploy
```
*Stop the remote server*
```bash
./testrunner.sh -a stop
```
*Deploy to your local machine*
```bash
./testrunner.sh -a deploy -l
```
*Deploy from Windows*
1. Open command prompt
2. Run ```ssh noah@192.168.10.119```
   * This will only work in the OHS office
   * Ask Noah for password
3. Once you connect and your Command Prompt says ```noah@qatestrunner:~/OHS_QA_Auto$```, run ```git pull && ./testrunner.sh -a deploy -l```
## Running tests
Tests start running as soon as the server is deployed. To manually run the tests in the container:
```bash
python3 /testrail/testrail_auto.py
```
## Adding tests for Testrail
To make a test available to test rail, simply move it into the ```prod_tests``` folder. It can be nested in as many folders as you like, it just needs to be under ```prod_tests```.
## Naming Conventions

* Test naming syntax ```CASE_ID-testname```
  * where CASE_ID corresponds to the case id in testrail
* Please ensure you are using a UAT URL when creating test cases. This URL will be expected by a script made to replace it with other URLs (dev, prod, etc)

## Some comments for nerds
Running these tests headless in alpine (docker) requires some special options. I implemented this with ```deploy/headlesss_prep.sh``` and added it to the container entrypoint.  
 
The Dockerfile sets a bash env var called ```sooper_sekret_key```. This is used to ensure that the headless prep script only runs in the docker container as to avoid modifying files on the host computer.

```testrail/testrail_auto.py``` is the script that runs all the test cases. This is made possible by the unique case ID associated with each case in Testrail. This script will only look for tests located in ```prod_tests```.

Want to debug? Comment out what you don't want in ```deploy/entrypoint.sh``` and uncomment ```exec $@```

Questions? Contact Noah at noahlaf@gmail.com
