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
    fileprivate var context: LAContext!
    
    
    override init() {
        super.init()
        context = LAContext()
    }
    
    func isBiometricSupported() -> Bool {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        return true
    }
    
    func authenticateUser(withDesc desc: String, success: @escaping Success, failure: @escaping Failure) {
        
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async(execute: {
                failure(error!)
            })
            return
        }
        
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: desc,
                               reply: { (status, error) in
                                if status {
                                    DispatchQueue.main.async(execute: {
                                        success()
                                    })
                                } else {
                                    DispatchQueue.main.async(execute: {
                                        failure(error! as NSError)
                                    })
                                }
        })
    }
}
