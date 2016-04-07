//
//  StringExtensions.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension String {
    private func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func removeBrackets() -> String {
        return self.replace("(0)", replacement: "")
    }
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let character  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = self.componentsSeparatedByCharactersInSet(character)
        filtered = inputString.componentsJoinedByString("")
        
        return  self == filtered
        
    }
    
    func validate() -> Bool {
        
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(self)
        
        if result {
            let character  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
            var filtered:NSString!
            let inputString:NSArray = self.componentsSeparatedByCharactersInSet(character)
            filtered = inputString.componentsJoinedByString("")
            return self == filtered
        } else {
            return false
        }
    }
}