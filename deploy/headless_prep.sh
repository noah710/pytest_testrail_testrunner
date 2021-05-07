#!/bin/bash

# This script prepares the tests to be run in a headless environment (container)

# ARGS:
#$1 is going to be the directory to recursively search

# This script should never run outside of the container. It will modify the python files and make it very annoying to run them outside of docker
if [ -z "$sooper_sekret_key" ] 
then
	echo "ERROR: ONLY RUN IN DOCKER CONTAINER!!!!"
	exit
fi

# for each python file in dir supplied at $1
for file in `find ${1} -name '*.py'` ; do
	# this one adds the chrome options to the top of the file
	sed -i '1ifrom selenium.webdriver.chrome.options import Options\nchrome_options = Options()\nchrome_options.add_argument("--headless")\nchrome_options.add_argument("--no-sandbox")\nchrome_options.add_argument("--disable-dev-shm-usage")' ${file};
	# this one adds the chrome options in the webdriver constructor
	sed -i 's/self.driver = webdriver.Chrome()/self.driver = webdriver.Chrome(options=chrome_options)/g' ${file};
	# these 2 account for tests with client and provider drivers
	sed -i 's/self.client_driver = webdriver.Chrome()/self.client_driver = webdriver.Chrome(options=chrome_options)/g' ${file};
	sed -i 's/self.prov_driver = webdriver.Chrome()/self.prov_driver = webdriver.Chrome(options=chrome_options)/g' ${file};
done

