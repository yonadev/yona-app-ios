//
//  KeychainManager.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

final class KeychainManager {
    static let sharedInstance = KeychainManager()
    
    private let keychain = KeychainSwift()
    
    private init() {}
}

//MARK: - getYonaPassword
extension KeychainManager {
    func createYonaPassword() {
        let password = NSUUID().UUIDString
        
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
    }
    
    func getYonaPassword() -> String? {
        guard let password = keychain.get(YonaConstants.keychain.yonaPassword) else { return nil }
        
        return password
    }
}

//MARK: - PIN Code
extension KeychainManager {
    func savePINCode(pinCode: String) {
        keychain.set(pinCode, forKey: YonaConstants.keychain.PINCode)
    }
    
    func getPINCode() -> String? {
        guard let pin = keychain.get(YonaConstants.keychain.PINCode) else { return nil }
        
        return pin
    }
}