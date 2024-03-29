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
        GIT = credentials('github-yonabuild')
        LC_ALL = 'en_US.UTF-8'
        LANG = 'en_US.UTF-8'
        KEYCHAIN = '/Users/yonabuild/Library/Keychains/login.keychain-db'
      }
      steps {
        checkout scm
        dir(path: 'Yona') {
          slackSend color: 'good', channel: '#dev', message: "<${currentBuild.absoluteUrl}|iOS app build ${env.BUILD_NUMBER}> on branch ${BRANCH_NAME} is awaiting release notes input to start the build"
          script {
            def enReleaseNotes = input message: 'User input required',
                submitter: 'authenticated',
                parameters: [[$class: 'TextParameterDefinition', defaultValue: '', description: 'Paste the English release notes', name: 'English']]
            enReleaseNotes.length() >= 500 && error("Release notes can be at most 500 characters") // Not sure for Apple
            def nlReleaseNotes = input message: 'User input required',
                submitter: 'authenticated',
                parameters: [[$class: 'TextParameterDefinition', defaultValue: '', description: 'Paste the Dutch release notes', name: 'Dutch']]
            nlReleaseNotes.length() >= 500 && error("Release notes can be at most 500 characters") // Not sure for Apple
            echo "English release notes: ${enReleaseNotes}"
            echo "Dutch release notes: ${nlReleaseNotes}"
            writeFile file: "fastlane/metadata/en-US/release_notes.txt", text: "${enReleaseNotes}"
            writeFile file: "fastlane/metadata/nl-NL/release_notes.txt", text: "${nlReleaseNotes}"
          }
          withCredentials(bindings: [string(credentialsId: 'FabricApiKey', variable: 'FABRIC_API_KEY'),
              string(credentialsId: 'FabricBuildSecret', variable: 'FABRIC_BUILD_SECRET'),
              string(credentialsId: 'KeychainPass', variable: 'KEYCHAIN_PASS')]) {
            writeFile file: "fabric.apikey", text: "$FABRIC_API_KEY"
            sh '/usr/local/bin/pod install'
            sh 'set -o pipefail && xcodebuild -workspace Yona.xcworkspace -scheme Yona -sdk iphonesimulator -destination \'platform=iOS Simulator,name=iPhone 6,OS=12.1\' -derivedDataPath ./BuildOutput clean build test | /usr/local/bin/xcpretty --report junit --output ./BuildOutput/Report/testreport.xml'
            incrementVersion("1.2")
            sh 'security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k $KEYCHAIN_PASS ${KEYCHAIN}'
            sh 'xcodebuild -allowProvisioningUpdates -workspace Yona.xcworkspace -configuration Debug -scheme Yona archive -archivePath ./BuildOutput/Yona-Debug.xcarchive'
            sh 'xcodebuild -exportArchive -archivePath ./BuildOutput/Yona-Debug.xcarchive -exportPath ./BuildOutput/Yona-Debug.ipa -exportOptionsPlist ./ExportOptions/ExportOptionsDebug.plist'
            sh 'xcodebuild -allowProvisioningUpdates -workspace Yona.xcworkspace -configuration Production -scheme Yona archive -archivePath ./BuildOutput/Yona-Production.xcarchive'
            sh 'xcodebuild -exportArchive -archivePath ./BuildOutput/Yona-Production.xcarchive -exportPath ./BuildOutput/Yona-Production.ipa -exportOptionsPlist ./ExportOptions/ExportOptionsProduction.plist'
            sh 'git config --global user.email build@yona.nu'
            sh 'git config --global user.name yonabuild'
            sh 'git add -u'
            sh 'git commit -m "Build $BUILD_NUMBER updated versionCode to $NEW_VERSION_CODE [ci skip]"'
            sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git HEAD:$BRANCH_NAME'
            sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
            sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
            script {
              env.BUILD_NUMBER_TO_DEPLOY = env.BUILD_NUMBER
            }
          }
        }
        archiveArtifacts 'Yona/BuildOutput/**/*.ipa'
      }
      post {
        always {
          junit 'Yona/BuildOutput/**/*.xml'
        }
        success {
          slackSend color: 'good', channel: '#dev', message: "<${currentBuild.absoluteUrl}|iOS app build ${env.BUILD_NUMBER}> on branch ${BRANCH_NAME} succeeded"
        }
        failure {
          slackSend color: 'danger', channel: '#dev', message: "<${currentBuild.absoluteUrl}|iOS app build ${env.BUILD_NUMBER}> on branch ${BRANCH_NAME} failed"
        }
      }
    }
    stage('Upload to TestFlight') {
      when {
        allOf {
          not { changelog '.*\\[ci skip\\].*' }
          anyOf {
            branch 'develop'
            branch 'master'
          }
        }
      }
      environment {
        LC_ALL = 'en_US.UTF-8'
        LANG = 'en_US.UTF-8'
      }
      steps {
        dir(path: 'Yona') {
          withCredentials(bindings: [string(credentialsId: 'YonaBuildApplePassword', variable: 'FASTLANE_PASSWORD')]) {
            sh 'export PATH="/usr/local/bin:$PATH" && bundle exec fastlane --verbose alpha'
          }
        }
      }
      post {
        success {
          slackSend color: 'good', channel: '#dev', message: "<${currentBuild.absoluteUrl}|iOS app build ${env.BUILD_NUMBER_TO_DEPLOY}> on branch ${BRANCH_NAME} successfully uploaded to TestFlight"
        }
        failure {
          slackSend color: 'danger', channel: '#dev', message: "<${currentBuild.absoluteUrl}|iOS app build ${env.BUILD_NUMBER_TO_DEPLOY}> on branch ${BRANCH_NAME} failed to upload to TestFlight"
        }
      }
    }
  }
}

def incrementVersion(release) {
  def versionPropsFileName = "version.properties"
  def versionProps = readProperties file: versionPropsFileName
  env.NEW_VERSION_CODE = versionProps['VERSION_CODE'].toInteger() + 1
  versionProps['VERSION_CODE']=env.NEW_VERSION_CODE
  def versionPropsString = "#" + new Date() + "\n";
  def toKeyValue = {
    it.collect { "$it.key=$it.value" } join "\n"
  }
  versionPropsString += toKeyValue(versionProps)
  writeFile file: "version.properties", text: versionPropsString

  sh "xcrun agvtool new-version -all ${env.NEW_VERSION_CODE}"
  sh "xcrun agvtool new-marketing-version ${release}"
}
