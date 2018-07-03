pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git(branch: 'feature/APPDEV-1123-build-up-on-jenkins', url: 'https://github.com/yonadev/yona-app-ios.git', credentialsId: 'github', changelog: true)
      }
    }
  }
}