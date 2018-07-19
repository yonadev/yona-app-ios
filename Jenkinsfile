pipeline {
  agent {
    node {
      label 'mac-os'
    }
    
  }
  stages {
    stage('Build and test') {
      when {
        expression {
          result = sh (script: "git log -1 | grep '.*\\[ci skip\\].*'", returnStatus: true) // Check if commit message contains skip ci label
          result != 0 // Evaluate the result
        }
        
      }
      environment {
        GIT = credentials('65325e52-5ec0-46a7-a937-f81f545f3c1b')
      }
      steps {
        deleteDir()
        checkout scm
        importDeveloperProfile 'YonaVishalDeveloperProfile'
        dir(path: 'Yona') {
          sh '/usr/local/bin/pod install'
          sh 'security unlock-keychain -p "HPyQ2Cf9*Clh2p" "${HOME}/Library/Keychains/login.keychain-db.keychain"'
          sh 'xcrun agvtool new-marketing-version 1.1'
          sh 'xcrun agvtool next-version -all'
          sh 'xcodebuild -allowProvisioningUpdates -workspace Yona.xcworkspace -configuration Debug -scheme Yona archive -archivePath ./BuildOutput/Yona-Debug-$BUILD_NUMBER.xcarchive'
          sh 'xcodebuild -exportArchive -archivePath ./BuildOutput/Yona-Debug-$BUILD_NUMBER.xcarchive -exportPath ./BuildOutput/Yona-Debug-$BUILD_NUMBER.ipa -exportOptionsPlist ./BuildOutput/ExportOptionsDebug.plist'
          sh 'git checkout $BRANCH_NAME'
          sh 'git add -u'
          sh 'git commit -m "Updated versionCode for build $BUILD_NUMBER [ci skip]"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git'
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
        
        archiveArtifacts(artifacts: 'Yona/BuildOutput/**/*.ipa', allowEmptyArchive: true)
      }
    }
  }
}