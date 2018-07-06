pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git(branch: 'feature/APPDEV-1123-build-up-on-jenkins', url: 'https://github.com/yonadev/yona-app-ios.git', credentialsId: 'yonabuild', changelog: true)
      }
    }
    stage('Build & Test') {
      steps {
        sh '''cd Yona
/usr/local/bin/pod deintegrate
/usr/local/bin/pod repo update
/usr/local/bin/pod install
mkdir -p output # this directory will contain the output of the tests
xcrun xcodebuild -workspace Yona.xcworkspace \
    -scheme Yona \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=11.4' \
    -derivedDataPath './output' \
    test
      }
    }
  }
}
