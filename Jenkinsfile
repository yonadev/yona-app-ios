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
        powershell(script: 'cd Yona xcodebuild -workspace "Yona.xcworkspace" -scheme "Yona" -configuration "Debug" build test -destination "platform=iOS Simulator,name=iPhone 6,OS=11.4"', returnStatus: true, returnStdout: true)
        powershell(script: '-enableCodeCoverage YES | /usr/local/bin/xcpretty -r junit', returnStatus: true, returnStdout: true)
        powershell(script: '[$class: \'JUnitResultArchiver\', allowEmptyResults: true, testResults: \'build/reports/junit.xml\']', returnStatus: true, returnStdout: true)
        bat(script: 'cd Yona xcodebuild -workspace "Yona.xcworkspace" -scheme "Yona" -configuration "Debug" build test -destination "platform=iOS Simulator,name=iPhone 6,OS=11.4"', returnStatus: true, returnStdout: true)
      }
    }
  }
}