pipeline {
  agent {
    node {
      label 'mac-os'
    }
  }
  stages {
    stage('Build and test') {
      when {
        not { changelog '.*\\[ci skip\\].*' }
      }
      environment {
        GIT = credentials('65325e52-5ec0-46a7-a937-f81f545f3c1b')
        LC_ALL = 'en_US.UTF-8'
        LANG = 'en_US.UTF-8'
        KEYCHAIN = '/Users/yonabuild/Library/Keychains/login.keychain-db'
      }
      steps {
        dir(path: 'Yona') {
          withCredentials(bindings: [string(credentialsId: 'FabricApiKey', variable: 'FABRIC_API_KEY'), string(credentialsId: 'FabricBuildSecret', variable: 'FABRIC_BUILD_SECRET'), string(credentialsId: 'KeychainPass', variable: 'KEYCHAIN_PASS')]) {
            writeFile file: "fabric.apikey", text: "$FABRIC_API_KEY"
            sh '/usr/local/bin/pod install'
            sh 'set -o pipefail && xcodebuild -workspace Yona.xcworkspace -scheme Yona -sdk iphonesimulator -destination \'platform=iOS Simulator,name=iPhone 6,OS=11.4\' -derivedDataPath ./BuildOutput clean build test | /usr/local/bin/xcpretty --report junit --output ./BuildOutput/Report/testreport.xml'
            incrementVersion("1.1")
            sh 'security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k $KEYCHAIN_PASS ${KEYCHAIN}'
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
        success {
          slackSend color: 'good', channel: '#dev', message: "iOS app build ${env.BUILD_NUMBER} on branch ${BRANCH_NAME} succeeded"
        }
        failure {
          slackSend color: 'bad', channel: '#dev', message: "iOS app build ${env.BUILD_NUMBER} on branch ${BRANCH_NAME} failed"
        }
      }
    }
  }
}

def incrementVersion(release) {
  def versionPropsFileName = "version.properties"
  def versionProps = readProperties file: versionPropsFileName
  def newVersionCode = versionProps['VERSION_CODE'].toInteger() + 1
  versionProps['VERSION_CODE']=newVersionCode.toString()
  def versionPropsString = "#" + new Date() + "\n";
  def toKeyValue = {
    it.collect { "$it.key=$it.value" } join "\n"
  }
  versionPropsString += toKeyValue(versionProps)
  writeFile file: "version.properties", text: versionPropsString

  def marketingVersion = "${release}.${env.BUILD_NUMBER}" + (env.BRANCH_NAME == "master" ? "" : ".${env.BRANCH_NAME.length()}")
  sh "xcrun agvtool new-version -all ${newVersionCode}"
  sh "xcrun agvtool new-marketing-version ${marketingVersion}"
}
