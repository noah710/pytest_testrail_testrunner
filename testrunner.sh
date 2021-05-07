#!/bin/bash
# This script manages deployment of the testrunner

source deploy/testrunner.env

while getopts "a:lph" opt; do
  case ${opt} in
    a) # action (start, stop, deploy etc) -a deploy
        export ACTION="$OPTARG"
      ;; 
    l) # launch locally
        export LOCAL=true
      ;;
    p) # launch persistent server
        export DEFAULT_LAUNCH='persistent'
        export EXTRA_ARGS='-p'
        export CONTAINER_NAME="${CONTAINER_NAME}-persistent"
      ;;
    h)
        printf "Usage: ./testrunner.sh -a [start|stop|deploy|watch|shell|ssh] [-l]\n-l: deploy locally\n"
      ;;
    *) 
        printf "Usage: ./testrunner.sh -a [start|stop|deploy|watch|shell|ssh] [-l]\n-l: deploy locally\n"
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ -n "${LOCAL}" ]]; then
    unset DOCKER_HOST
    TESTRUNNER_IP="127.0.0.1"
else
    export DOCKER_HOST="ssh://${TESTRUNNER_USER}@${TESTRUNNER_IP}" # MAKE SURE YOU SSH-COPY-ID THE SERVER
fi

case $ACTION in
    start)
        shift
        docker stop ${CONTAINER_NAME} &> /dev/null
        docker rm ${CONTAINER_NAME} &> /dev/null
        docker run \
            -it \
            --name ${CONTAINER_NAME} \
            --env DEFAULT_LAUNCH=${DEFAULT_LAUNCH} \
            ${IMAGE_NAME} \
            /bin/bash

        if [ $? -eq 0 ]; then
            echo "Error starting container"
        fi
    ;;

    stop)
        docker stop ${CONTAINER_NAME} &> /dev/null
        docker rm ${CONTAINER_NAME} &> /dev/null
    ;;

    shutdown)
        ssh ${TESTRUNNER_USER}@${TESTRUNNER_IP} "sudo poweroff" &> /dev/null
    ;;

    shell)
        docker exec -it ${CONTAINER_NAME} /bin/bash
    ;;

    watch)
        docker logs -f ${CONTAINER_NAME}
    ;;

    deploy)
        if [[ -n "${LOCAL}" ]]; then
            $0 -a stop -l
            set -e
            docker build -f deploy/Dockerfile -t ${IMAGE_NAME} .
            $0 -a start -l ${EXTRA_ARGS}
        else
            $0 -a stop
            set -e
            docker build -f deploy/Dockerfile -t ${IMAGE_NAME} .
            $0 -a start ${EXTRA_ARGS}
        fi
    ;;
    
    ssh)
        if [[ -n "${LOCAL}" ]]; then
            echo "You're sshing into your own machine!"
        else
            ssh ${TESTRUNNER_USER}@${TESTRUNNER_IP}
        fi
	;;
    *)
        printf "Usage: ./testrunner.sh -a [start|stop|deploy|watch|shell|ssh] [-l]\n-l: deploy locally\n"
    ;;
esac
