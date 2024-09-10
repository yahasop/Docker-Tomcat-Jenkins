#!/bin/bash

#Script to build the Jenkins Tomcat image from the Dockerfile and then run a container from said image


docker_build () {
	#Unlikely, but here's to stop and rm any container or image with the same name as the ones the script will be providing below
	docker stop jenkins-tomcat8-jmx > /dev/null 2>&1
	docker image rm jenkins-tomcat8-jmx:1.0 > /dev/null 2>&1

	echo "Building the Jenkins with Tomcat image..."
	echo ""

	#Building the image from the Dockerfile. This must be in the same directory
	docker build -t jenkins-tomcat8-jmx:1.0 .

	#Running the container after the image is created
	#Options: 
	#Detached mode to run in the background
	#The rm flag to remove the container when it is stopped 
	#A name to easier identification, 
	#Port forwarding stating we want to open the service at 8080 from any machine and forward to 8080 of the container
	docker run -d --rm --name jenkins-tomcat8-jmx -p 8081:8080 jenkins-tomcat8-jmx:1.0 >> /dev/null
}

docker_build

echo ""
echo "Starting the tomcat service..."

#When the Tomcat service start, the Jenkins service also will be starting and it will need a password
jenkins_password=""

if [ $? == 0 ]; then
	#This while lopp tries the command to retrieve the Jenkins password, until it returns a 0 exit code, meaning a succesful execution. 
	#The Tomcat service takes some time to be up and running, so this tries every 1 second
	while ! jenkins_password=$(docker exec jenkins-tomcat8-jmx cat /root/.jenkins/secrets/initialAdminPassword 2> /dev/null); do
		sleep 1
	done

fi

#These are just echoes printing information to the terminal to easy access to the Tomcat and Jenkins.
echo ""

echo "Done!"

echo "Access Tomcat Service here: http://$(curl -s -4 ifconfig.me):8081"

echo "The manager app username is \"admin\" and password is \"admin\""

echo ""

echo "Access the Jenkins service directly here: http://$(curl -s -4 ifconfig.me):8081/jenkins"

echo "The Jenkins password is: ${jenkins_password}"
