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
        LC_CTYPE = 'en_US.UTF-8'
      }
      steps {
        dir(path: 'Yona') {
          withCredentials(bindings: [string(credentialsId: 'FabricApiKey', variable: 'FABRIC_API_KEY'), string(credentialsId: 'FabricBuildSecret', variable: 'FABRIC_BUILD_SECRET')]) {
            sh '/usr/local/bin/pod install'
            sh 'set -o pipefail && xcodebuild -workspace Yona.xcworkspace -scheme Yona -sdk iphonesimulator -destination \'platform=iOS Simulator,name=iPhone 6,OS=11.4\' -derivedDataPath ./BuildOutput clean build test | /usr/local/bin/xcpretty --report junit --output ./BuildOutput/Report/testreport.xml'
            sh '''set +x
"Pods/Fabric/run" "$FABRIC_API_KEY" "$FABRIC_BUILD_SECRET"
 			   '''
            sh 'xcrun agvtool new-marketing-version 1.1'
            sh 'xcrun agvtool next-version -all'
            sh 'xcodebuild -allowProvisioningUpdates -workspace Yona.xcworkspace -configuration Debug -scheme Yona archive -archivePath ./BuildOutput/Yona-Debug.xcarchive'
            sh 'xcodebuild -exportArchive -archivePath ./BuildOutput/Yona-Debug.xcarchive -exportPath ./BuildOutput/Yona-Debug.ipa -exportOptionsPlist ./ExportOptions/ExportOptionsDebug.plist'
            sh 'xcodebuild -allowProvisioningUpdates -workspace Yona.xcworkspace -configuration Release -scheme Yona archive -archivePath ./BuildOutput/Yona-Release.xcarchive'
            sh 'xcodebuild -exportArchive -archivePath ./BuildOutput/Yona-Release.xcarchive -exportPath ./BuildOutput/Yona-Release.ipa -exportOptionsPlist ./ExportOptions/ExportOptionsRelease.plist'
            sh 'git add -u'
            sh 'git commit -m "Updated versionCode for build $BUILD_NUMBER [ci skip]"'
            sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git'
            sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
            sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
          }
          
        }
        
        archiveArtifacts 'Yona/BuildOutput/**/*.ipa'
      }
      post {
        always {
          junit 'Yona/BuildOutput/**/*.xml'
          
        }
        
      }
    }
  }
}