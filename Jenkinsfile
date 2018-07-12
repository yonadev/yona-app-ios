node('mac-os') {
    checkout scm
    stage ("Build"){
        dir ('Yona') { 
            sh 'xcodebuild -list' 
        }
    }
}
