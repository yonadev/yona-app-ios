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
    
    fileprivate let keychain = KeychainSwift()
    
    fileprivate init() {}
}

//MARK: - getYonaPassword
extension KeychainManager {
    func setPassword(_ password: String) {
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
    }
    
   /* func createYonaPassword() {
        let password = NSUUID().UUIDString
        keychain.set(password, forKey: YonaConstants.keychain.yonaPassword)
    } */
    
    func getYonaPassword() -> String? {
        guard let password = keychain.get(YonaConstants.keychain.yonaPassword) else { return nil }
        
        return password
    }
}

//MARK: - PIN Code
extension KeychainManager {
    func savePINCode(_ pinCode: String) {
        keychain.set(pinCode, forKey: YonaConstants.keychain.PINCode)
    }
    
    func getPINCode() -> String? {
        guard let pin = keychain.get(YonaConstants.keychain.PINCode) else { return nil }
        return pin
    }
}

//MARK: - USER ID
extension KeychainManager {
    func saveUserID(_ userID: String) {
        keychain.set(userID, forKey: YonaConstants.keychain.userID)
    }
    
    func getUserID() -> String? {
        guard let userID = keychain.get(YonaConstants.keychain.userID) else { return nil }
        
        return userID
    }
}

//MARK: - UserSelfLink, so that we can always get the user from the server
extension KeychainManager {
    func saveUserSelfLink(_ userSelfLink: String) {
        // WARNING this should be removed!
        var link = userSelfLink
        if link.hasPrefix(EnvironmentManager.baseUrlString()){
            let length = EnvironmentManager.baseUrlString().count
            let range = link.startIndex ..< link.index(link.startIndex, offsetBy: length)
            
            link.removeSubrange(range)
        }
        
        
        keychain.set(link, forKey: YonaConstants.keychain.userSelfLink)
    }
    
    func getUserSelfLink() -> String? {
        guard let userSelfLink = keychain.get(YonaConstants.keychain.userSelfLink) else { return nil }
        
        return userSelfLink
    }
}

//MARK: - clear keychain
extension KeychainManager {
    func clearKeyChain() {
        keychain.clear()
    }
    
}
