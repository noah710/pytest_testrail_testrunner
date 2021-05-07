#!/bin/bash

# pull latest tests
cd OHS_QA_Auto; sudo git pull; cd ..

IMAGE_NAME=testrunner
CONTAINER_NAME=testrunner-spec

# deploy container

docker build -f OHS_QA_Auto/deploy/Dockerfile -t ${IMAGE_NAME} OHS_QA_Auto
docker run --name ${CONTAINER_NAME} --env RUN_ID=${2} --env RUN_ENV=${4} --env DEFAULT_LAUNCH="specific" ${IMAGE_NAME}

# kill on exit
docker rm ${CONTAINER_NAME}
