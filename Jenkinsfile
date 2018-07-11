pipeline {
  agent {
    node {
      label 'mac-os'
    }
    
  }
  stages {
    stage('Build and test') {
      environment {
        GIT = credentials('65325e52-5ec0-46a7-a937-f81f545f3c1b')
      }
      steps {
        checkout scm
        sh 'security list-keychains -s  "~/Library/Keychains/login.keychain"'
        sh '$ security import credentials(\'yona-app-ios-creds\') -k login.keychain -P coe -A'
      }
    }
  }
}