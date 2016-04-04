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
    
    private init() {
        self.createYonaPassword()
    }
    
    private func createYonaPassword() {
        let password = NSUUID().UUIDString
        
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
    }
}

extension KeychainManager {
    func getYonaPassword() -> String? {
        guard let password = keychain.get(YonaConstants.keychain.yonaPassword) else { return nil }
        
        return password
    }
}