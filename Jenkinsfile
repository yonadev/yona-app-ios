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
          script {
            xcodeBuild {
              allowFailingBuildResults: false,
              appURL: ''
              assetPackManifestURL: ''
              buildDir: ''
              buildIpa: false
              bundleID: ''
              bundleIDInfoPlistPath: ''
              cfBundleShortVersionStringValue: ''
              cfBundleVersionValue: ''
              changeBundleID: false
              cleanBeforeBuild: false
              cleanTestReports: false
              compileBitcode: true
              configuration: 'Release'
              developmentTeamID: ''
              developmentTeamName: ''
              displayImageURL: ''
              embedOnDemandResourcesAssetPacksInBundle: true
              fullSizeImageURL: ''
              generateArchive: false
              interpretTargetAsRegEx: false
              ipaExportMethod: 'ad-hoc'
              ipaName: ''
              ipaOutputDirectory: ''
              keychainName: ''
              keychainPath: ''
              keychainPwd: ''
              logfileOutputDirectory: ''
              manualSigning: false
              noConsoleLog: false
              onDemandResourcesAssetPacksBaseURL: ''
              provideApplicationVersion: false
              provisioningProfiles: [[provisioningProfileAppId: ''
              provisioningProfileUUID: '']]
              sdk: ''
              symRoot: ''
              target: ''
              thinning: ''
              unlockKeychain: false
              uploadBitcode: true
              uploadSymbols: true
              xcodeProjectFile: ''
              xcodeProjectPath: ''
              xcodeSchema: ''
              xcodeWorkspaceFile: ''
              xcodebuildArguments: ''
            }
		  }
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
      }
    }
  }
}
