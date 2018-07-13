node('mac-os')  {
    stage('checkout') { 
            checkout scm 
        }
    stage('cocoapods') {
        dir ('Yona') { 
            sh '/usr/local/bin/pod deintegrate'
            sh '/usr/local/bin/pod repo update'
            sh '/usr/local/bin/pod install'
        }
        }
    stage ("Build"){
        require 'rubygems' require 'xcodebuilder
         xCodeBuilder = XcodeBuilder::XcodeBuilder.new do |config|
    config.app_name = "Yona"
  end
        dir ('Yona') {
           
             xCodeBuilder {
      buildIpa(true)
      generateArchive(true)
      cleanBeforeBuild(true)      
      cleanTestReports(true)
      configuration('')
      target('Yona')
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
      xcodeWorkspaceFile('Yona')
      xcodeSchema('Yona')
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
    }
}
