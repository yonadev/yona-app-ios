node('mac-os') {
    // as before
    checkout scm
    stage "Build Pex"
        dir ('Yona') { 
          sh '/usr/local/bin/pod deintegrate'
          sh '/usr/local/bin/pod repo update'
          sh '/usr/local/bin/pod install'
          sh 'success'
    }
}
