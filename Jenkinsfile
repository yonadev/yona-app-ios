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
        dir(path: 'Yona') {
          sh '/usr/local/bin/pod deintegrate'
          sh '/usr/local/bin/pod repo update'
          sh '/usr/local/bin/pod install'
          sh 'xcrun xcodebuild -workspace Yona.xcworkspace -scheme Yona -configuration Debug -derivedDataPath "./BuildOutput" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO'
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
        
        archiveArtifacts(artifacts: '**/*.app', allowEmptyArchive: true)
      }
    }
  }
}