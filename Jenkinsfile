pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git(branch: 'feature/APPDEV-1123-build-up-on-jenkins', url: 'https://github.com/yonadev/yona-app-ios.git', credentialsId: '2b0ec580-9ce9-4701-96f4-84531a37d497', changelog: true)
      }
    }
  }
}