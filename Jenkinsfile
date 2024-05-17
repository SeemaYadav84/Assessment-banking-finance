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
}	
}
