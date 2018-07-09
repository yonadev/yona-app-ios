pipeline {
  agent {
    node {
      label 'mac-os'
    }
    
  }
  stages {
    stage('Checkout') {
      steps {
        git(url: 'https://github.com/yonadev/yona-app-ios.git', credentialsId: 'yonabuild', branch: 'feature/APPDEV-1123-build-up-on-jenkins')
        echo 'echo sh(script: \'env|sort\', returnStdout: true)'
      }
    }
    stage('Build and Test') {
      steps {
        dir(path: 'Yona') {
          sh '/usr/local/bin/pod deintegrate'
          sh '/usr/local/bin/pod repo update'
          sh '/usr/local/bin/pod install'
          sh 'mkdir -p output'
          sh 'xcrun xcodebuild -workspace Yona.xcworkspace -scheme Yona -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 6,OS=11.4" -derivedDataPath "./output" test'
        }
        
      }
    }
  }
}