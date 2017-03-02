//
//  AVTouchIDHelper.swift
//  Yona
//
//  Created by Angel Vasa on 02/03/17.
//  Copyright © 2017 Yona. All rights reserved.
//

import Foundation
import LocalAuthentication

typealias Success = () -> ()
typealias Failure = (NSError) -> ()

class AVTouchIDHelper: NSObject {    
    private var context: LAContext!
    
    
    override init() {
        super.init()
        context = LAContext()
    }
    
    func isBiometricSupported() -> Bool {
        var error: NSError?
        guard context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        return true
    }
    
    func authenticateUser(withDesc desc: String, success: Success, failure: Failure) {
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
            dispatch_async(dispatch_get_main_queue(), {
                failure(error!)
            })
            return
        }
        
        
        context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
                               localizedReason: desc,
                               reply: { (status, error) in
                                if status {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        success()
                                    })
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        failure(error!)
                                    })
                                }
        })
    }
}
