pipeline {
  agent any

  tools {
    maven 'M3_HOME'
    }
  
  stages {
    stage('Checkout') {
      steps {
        echo 'Checkout the source code from GitHub'
        git branch: 'master', url: 'https://github.com/SeemaYadav84/Assessment-banking-finance.git'
            }
    }
	
    stage('Package') {
      steps {
        echo 'Create a Maven Package'
        sh 'mvn clean package'
             }
    }
	
	stage('Publish Test Reports') {
       steps {
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '/var/lib/jenkins/workspace/Banking-Pipeline/target/surefire-reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: '', useWrapperFileDirectly: true])
             }
    }
	
	stage('Create a docker Image') {
       steps {
         echo 'creating a docker image from the package'
         sh 'docker build -t seemayd/banking-app:1.0 .' 
              }
    }
    stage('Docker Login') {
       steps {
          echo 'Login to Docker hub to push the images'
          withCredentials([usernamePassword(credentialsId: 'Dockerloginuser', passwordVariable: 'Dockerpassword', usernameVariable: 'Dockerlogin')]) {
          sh 'docker login -u ${Dockerlogin} -p ${Dockerpassword}'
              }
        }
    }
    stage('Push the Image') {
       steps {
          sh 'docker push seemayd/banking-app:1.0'
              }
    }
    stage('Provision server by terraform') {
       steps {
            dir('tfscripts') {
	    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'jenkinsIAMuser', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
            sh 'terraform init'
            sh 'terraform validate'
            sh 'terraform apply --auto-approve'
              }
           }
       }	       
	  
}	
}
