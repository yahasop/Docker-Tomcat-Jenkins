FROM alpine:3.18

#This will install Tomcat. First, Java is needed. This install Java 11 using apk package manager
#The we download and extract the Tomcat binary into the /usr/local path
RUN apk update && \
    apk add --no-cache wget openjdk11 && \
    wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.53/bin/apache-tomcat-8.0.53.tar.gz && \
    tar xvf apache-tomcat-8.0.53.tar.gz && \
    mv apache-tomcat-8.0.53 /usr/local/tomcat && \
    rm apache-tomcat-8.0.53.tar.gz

#This package is needed to enable graphics in older versions of Tomcat when tries to run Jenkins
RUN apk add ttf-dejavu 

#Setting environment variables to add a Tomcat home and then add this to the $PATH in order to be able to execute scripts from there
ENV CATALINA_HOME=/usr/local/tomcat 
ENV PATH=$CATALINA_HOME/bin:$PATH

#Typically Tomcat runs on port 8080
EXPOSE 8080

#This set the working directory for the container
WORKDIR /usr/local/tomcat/

#This copies the tomcat-users.xml file pre-populated with an admin user and password to enable the host manager UI
COPY tomcat-users.xml /usr/local/tomcat/conf/

#This dowloads the Jenkins war into the webapps path, where Tomcat search for the web apps to host and deploy
ADD https://get.jenkins.io/war-stable/2.7.1/jenkins.war /usr/local/tomcat/webapps/

#The catalina.sh is the script that runs everything needed to start the Tomcat service
CMD ["catalina.sh", "run"]
