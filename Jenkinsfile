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
        sh '''gem install cocoapods /Users/vishalrevdiwala/.jenkins/workspace
gem which cocoapods'''
        sh '''cd Yona
/usr/local/bin/pod deintegrate
/usr/local/bin/pod install
xcodebuild -workspace "Yona.xcworkspace" -scheme "Yona" -configuration "Debug" build test -destination "platform=iOS Simulator,name=iPhone 6,OS=11.4"'''
        sh '''-enableCodeCoverage YES | /usr/local/bin/xcpretty -r junit
'''
        sh '''[$class: \'JUnitResultArchiver\', allowEmptyResults: true, testResults: \'build/reports/junit.xml\']
'''
      }
    }
  }
}
