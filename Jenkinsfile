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
        dir ('Yona') {
            xcodebuild 'archive', [
                workspace: 'Yona.xcworkspace',
                scheme: 'Yona', 
                archivePath: 'Yona.xcarchive',
                derivedDataPath: './BuildOutput'
            ]
            archive 'Yona.xcarchive/**' 
        }
    }
}
