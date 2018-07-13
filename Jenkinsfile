pipeline {
  agent {
    node {
      label 'mac-os'
    } 
  }
  parameters {
        string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
  }
  stages {
    stage('Build and test') {
      environment {
        GIT = credentials('65325e52-5ec0-46a7-a937-f81f545f3c1b')
      }
      steps {
        checkout scm
        dir(path: 'Yona') {
          echo "Hello ${params.PERSON}"
          sh 'echo "Hello ${params.PERSON}"'
          sh '/usr/local/bin/pod deintegrate'
          sh '/usr/local/bin/pod repo update'
          sh '/usr/local/bin/pod install'
          sh 'xcodebuild -workspace Yona.xcworkspace -scheme Yona archive -archivePath /BuildOutput/Yona.xcarchive'
          sh 'xcodebuild -exportArchive -archivePath /BuildOutput/Yona.xcarchive -exportPath /BuildOutput/Yona.ipa -exportOptionsPlist /ExportOptions.plist'
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
        
        archiveArtifacts(artifacts: '**/*.app', allowEmptyArchive: true)
      }
    }
  }
}
