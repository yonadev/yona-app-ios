pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git(branch: 'feature/APPDEV-1123-build-up-on-jenkins', url: 'https://github.com/yonadev/yona-app-ios.git', credentialsId: 'github', changelog: true)
      }
    }
    stage('Build and Test') {
      steps {
        sh '''cd Yona
xcodebuild -workspace "Yona.xcworkspace" -scheme "Yona" -configuration "Debug" build test -destination "platform=iOS Simulator,name=iPhone 6,OS=11.4"'''
        sh '''-enableCodeCoverage YES | /usr/local/bin/xcpretty -r junit
'''
        sh '''[$class: \'JUnitResultArchiver\', allowEmptyResults: true, testResults: \'build/reports/junit.xml\']
'''
      }
    }
  }
}