#!/bin/bash

/./deploy/headless_prep.sh /tests

case $DEFAULT_LAUNCH in
    default)
        # run the tests
        python3 /testrail/testrail_auto_aggregated.py
    ;;

    persistent)
        python3 /testrail/persistent_test_runner.py
    ;;
    
    specific)
        python3 /testrail/testrail_specific_run.py -r ${RUN_ID} -e ${RUN_ENV}
    ;;
    
esac

# dont want a shell afterwards, uncomment to debug
#exec $@
