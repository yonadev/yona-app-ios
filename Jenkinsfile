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
              buildIpa(true)
              generateArchive(true)
              cleanBeforeBuild(true)      
              cleanTestReports(true)
              configuration('Debug ')
              target('')
              sdk('')
              xcodeProjectPath('')
              xcodeProjectFile('')
              xcodebuildArguments('')
              embeddedProfileFile('')
              cfBundleVersionValue('')
              cfBundleShortVersionStringValue('')
              unlockKeychain(true)
              keychainName('')
              keychainPath('')
              keychainPwd('')
              symRoot('')
              xcodeWorkspaceFile('Yona.xcworkspace')
              xcodeSchema('Yona ')
              configurationBuildDir('')
              codeSigningIdentity('')
              allowFailingBuildResults(true)
              ipaName('')
              provideApplicationVersion(true)
              ipaOutputDirectory('')
              changeBundleID(true)
              bundleID('')
              bundleIDInfoPlistPath('')
              ipaManifestPlistUrl('')
              interpretTargetAsRegEx(true)
            }
		  }
          sh 'git tag -a $BRANCH_NAME-build-$BUILD_NUMBER -m "Jenkins"'
          sh 'git push https://${GIT_USR}:${GIT_PSW}@github.com/yonadev/yona-app-ios.git --tags'
        }
      }
    }
  }
}
