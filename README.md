# Java-web-application
Java web application repo for CI/CD Pipeline.

In this Project,

=> I used Jenkins as a CI/CD tool by writing a pipeline to fetch the code from github by enabling Webhook trigger to start the build whenever changes made to repo.

=> Configured Maven using jenkins global tool config to run the builds.

=> using the sonar qube plugin from maven to generate the sonarqube report by configuring the sonar server details in jenkins configure system by installing sonar scanner plugin.

=> setting up the quality gate check in the pipeline of jenkins by configuring webhook in sonarqube to pass/abort the pipeline according to the quality gate result of sonarqube. 

=> And next, configured the Artifactory plugin info in pom.xml to store the build artifact/package in Jfrog artifactory.

=> Here i'm building a docker image using a tomcat image as base and on top of that i am copying the .war that located in the target directory to the webapps of tomcat by exposing port 8080:8080

=> And once after building the image with tag of docker-uname/reponame. i am pushing that image to docker registry to save and to pull that image and run in remote servers.
  
         eg: docker build -t  docker-uname/reponame:tagname /path/to/Dockerfile or .    
             docker login -u usrname -p passwd
             docker push docker-uname/reponame:tagname

=> Now i am setting up the plugin called kubernetes continous deploy in manage jenkins and configuring the plugin to access the kubernetes cluster by providing .kube/config file and deploying the application in kubernetes. 

=> Now i can access the application by using ip/dns of kubernetes master/any node ip of kubernetes using k8's service NodePort instead application target port.

=> Here we are deploying our containerized application in kuberenetes to manage the containers when it goes down. so, there k8 will UP the application by creating a new pod with container to meet desired state of replicas we provided in k8's manifest.
