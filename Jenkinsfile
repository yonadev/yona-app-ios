node  {
    checkout scm
    stage ("Build"){
        dir ('Yona') { 
            sh 'xcodebuild -list' 
            sh 'xcodeBuild allowFailingBuildResults: false, appURL: '', assetPackManifestURL: '', buildDir: 'BuildOutput', buildIpa: true, bundleID: '', bundleIDInfoPlistPath: '', cfBundleShortVersionStringValue: '', cfBundleVersionValue: '', changeBundleID: false, cleanBeforeBuild: true, cleanTestReports: false, compileBitcode: true, configuration: 'Release', developmentTeamID: 'KMR2VE49BG', developmentTeamName: '', displayImageURL: '', embedOnDemandResourcesAssetPacksInBundle: true, fullSizeImageURL: '', generateArchive: true, interpretTargetAsRegEx: false, ipaExportMethod: 'app-store', ipaName: '${VERSION}-${BUILD_DATE}', ipaOutputDirectory: 'BuildOutput', logfileOutputDirectory: '', manualSigning: true, noConsoleLog: false, onDemandResourcesAssetPacksBaseURL: '', provideApplicationVersion: false, provisioningProfiles: [[provisioningProfileAppId: 'nl.yonafoundation.yona', provisioningProfileUUID: 'af203df1-1b65-4526-b60c-205737697b0a']], sdk: '', symRoot: '', target: 'Yona', thinning: '', unlockKeychain: true, uploadBitcode: false, uploadSymbols: true, xcodeProjectFile: '', xcodeProjectPath: '', xcodeSchema: 'Yona', xcodeWorkspaceFile: 'Yona', xcodebuildArguments: '''
        }
    }
}
