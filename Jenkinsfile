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
            xcodeBuild  allowFailingBuildResults: false,
            appURL: '',
            assetPackManifestURL: '',
            buildDir: './BuildOutput',
            buildIpa: true,
            bundleID: '',
            bundleIDInfoPlistPath: '',
            cfBundleShortVersionStringValue: '',
            cfBundleVersionValue: '',
            changeBundleID: false,
            cleanBeforeBuild: false,
            cleanTestReports: false,
            compileBitcode: true,
            configuration: 'Release',
            developmentTeamID: 'KMR2VE49BG',
            developmentTeamName: '',
            displayImageURL: '',
            embedOnDemandResourcesAssetPacksInBundle: true,
            fullSizeImageURL: '',
            generateArchive: false,
            interpretTargetAsRegEx: false,
            ipaExportMethod: 'app-store',
            ipaName: 'Yona',
            ipaOutputDirectory: '',
            keychainName: 'login.keychain-db',
            keychainPath: '${HOME}/Library/Keychains/login.keychain-db',
            keychainPwd: 'HPyQ2Cf9*Clh2p',
            logfileOutputDirectory: '',
            manualSigning: false,
            noConsoleLog: false,
            onDemandResourcesAssetPacksBaseURL: '',
            provideApplicationVersion: false,
            provisioningProfiles: [[provisioningProfileAppId: 'nl.yonafoundation.yona',
            provisioningProfileUUID: 'af203df1-1b65-4526-b60c-205737697b0a']],
            sdk: '',
            symRoot: '',
            target: 'Yona',
            thinning: 'none',
            unlockKeychain: true,
            uploadBitcode: false,
            uploadSymbols: true,
            xcodeProjectFile: '',
            xcodeProjectPath: '',
            xcodeSchema: 'Yona',
            xcodeWorkspaceFile: 'Yona',
            xcodebuildArguments: ''
          }
          
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
        
      }
    }
  }
}