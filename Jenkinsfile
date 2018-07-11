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
          sh '''xcodeBuild allowFailingBuildResults: false, appURL: \'\', assetPackManifestURL: \'\', buildDir: \'${WORKSPACE}/build\', buildIpa: true, bundleID: \'\', bundleIDInfoPlistPath: \'\', cfBundleShortVersionStringValue: \'\', cfBundleVersionValue: \'\', changeBundleID: false, cleanBeforeBuild: true, cleanTestReports: false, compileBitcode: true, configuration: \'Debug\', developmentTeamID: \'\', developmentTeamName: \'\', displayImageURL: \'\', embedOnDemandResourcesAssetPacksInBundle: true, fullSizeImageURL: \'\', generateArchive: false, interpretTargetAsRegEx: false, ipaExportMethod: \'development\', ipaName: \'\', ipaOutputDirectory: \'\', keychainName: \'\', keychainPath: \'\', keychainPwd: \'\', logfileOutputDirectory: \'\', manualSigning: false, noConsoleLog: false, onDemandResourcesAssetPacksBaseURL: \'\', provideApplicationVersion: true, provisioningProfiles: [[provisioningProfileAppId: \'com.yona.cmi\', provisioningProfileUUID: \'\']], sdk: \'\', symRoot: \'\', target: \'Yona\', thinning: \'\', unlockKeychain: false, uploadBitcode: true, uploadSymbols: true, xcodeProjectFile: \'\', xcodeProjectPath: \'\', xcodeSchema: \'Yona\', xcodeWorkspaceFile: \'Yona.xcworkspace\', xcodebuildArguments: \'\'
'''
        }
        
      }
    }
  }
}