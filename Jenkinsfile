node ("demo-node"){
    
    def mvnhome = tool name: "maven"
    properties([pipelineTriggers([githubPush()])])
    
    stage("checkout code"){
        checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/MaddineniGirish/Java-web-application-2.git']]])
    }
    
    stage ("build") {
        sh "${mvnhome}/bin/mvn clean install"
    }
    
    stage ("sonar report") {
        withSonarQubeEnv(credentialsId: 'sonarqube') {
            sh "${mvnhome}/bin/mvn sonar:sonar"
        }
    }
    
    stage ("quality gate analysis") {
        waitForQualityGate abortPipeline: false, credentialsId: 'sonarqube'
    }
    
    stage ("Artifactory upload"){
        sh "${mvnhome}/bin/mvn deploy"
    }
    
    stage ("docker image build"){
        sh "docker build -t girishdocker18/java-web-application:${BUILD_NUMBER} ."
    }
    
    stage ("docker push"){
        withCredentials([string(credentialsId: '65e67bd6-ffdd-4e97-8d08-486d576a28fb', variable: 'DOCKER_PASS')]) {
            sh "docker login -u girishdocker18 -p ${DOCKER_PASS}"
            sh "docker push girishdocker18/java-web-application:${BUILD_NUMBER}"
        }
    }
    
    stage ("deploying in kubernetes"){
        kubernetesDeploy configs: 'k8s-deployment.yml', kubeConfig: [path: ''], kubeconfigId: 'Kubernetes', secretName: '', ssh: [sshCredentialsId: '*', sshServer: ''], textCredentials: [certificateAuthorityData: '', clientCertificateData: '', clientKeyData: '', serverUrl: 'https://']
    }
    
    post {
        success {
            wrap([$class: 'BuildUser']){
                slackSend(channel: "#general", color: "good",  message: "Status: ${currentBuild.currentResult}, USER: ${BUILD_USER}, Build_ID: #${env.BUILD_ID}, JOB_NAME: ${env.JOB_NAME}, URL: <${env.BUILD_URL}|(Open)>")
            }
        }
        failure {
            wrap([$class: 'BuildUser']){
                slackSend(channel: "#general", color: "#FF0000" , message: "Status: ${currentBuild.currentResult}, USER: ${BUILD_USER}, Build_ID: #${env.BUILD_ID}, JOB_NAME: ${env.JOB_NAME}, URL: <${env.BUILD_URL}|(Open)>")
            }
        }
        unstable {
            wrap([$class: 'BuildUser']){
                slackSend(channel: "#general", color: "#FFBF00" , message: "Status: ${currentBuild.currentResult}, USER: ${BUILD_USER}, Build_ID: #${env.BUILD_ID}, JOB_NAME: ${env.JOB_NAME}, URL: <${env.BUILD_URL}|(Open)>")
            }
        }
    }
}
    
