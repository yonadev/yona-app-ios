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
          step([$class: 'XCodeBuilder', allowFailingBuildResults: true, buildDir: '', buildIpa: true, bundleID: '', bundleIDInfoPlistPath: '', cfBundleShortVersionStringValue: 	'', cfBundleVersionValue: '', changeBundleID: false, cleanBeforeBuild: false, cleanTestReports: false, configuration: 'Debug', developmentTeamID: '', 			developmentTeamName: 'none (specify one below)', generateArchive: false, interpretTargetAsRegEx: false, ipaExportMethod: 'development', ipaManifestPlistUrl: '', 	ipaName: 'Yona', ipaOutputDirectory: '', keychainName: 'none (specify one below)', keychainPath: '', keychainPwd: '', provideApplicationVersion: false, sdk: 		iphonesimulator, symRoot: '', target: 'all', unlockKeychain: false, xcodeProjectFile: '', xcodeProjectPath: '', xcodeSchema: 'Yona', xcodeWorkspaceFile: 	'Yona.xcworkspace', xcodebuildArguments: ''])
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
        
      }
    }
  }
}