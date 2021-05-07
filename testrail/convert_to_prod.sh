#!/bin/bash

# This script converts the URLs in the test to production URLs

# ARGS:
#$1 is going to be the directory to recursively search

# This script should never run outside of the container. It will modify the python files and make it very annoying to run them outside of docker
if [ -z "$sooper_sekret_key" ] 
then
	echo "ERROR: ONLY RUN IN DOCKER CONTAINER!!!!"
	exit
fi


for file in `find ${1} -iname "*py"` ; do
   sed -i 's/testclient.vetnow.com/visit.vetnow.com/g' ${file}
   sed -i 's/testprovider.vetnow.com/provider.vetnow.com/g' ${file}
done
