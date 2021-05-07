#!/bin/bash

# this script is ran every night to get new container with latest tests

docker build -f deploy/Dockerfile -t testrunner .
docker rm testrunner_instance
docker run --name testrunner_instance --env DEFAULT_LAUNCH="default" testrunner

