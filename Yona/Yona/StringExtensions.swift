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
    
    func replacePlusSign() -> String {
        return self.replace("+", replacement: "%2B")
    }

    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let character  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        var filtered:NSString!
        let inputString:NSArray = self.componentsSeparatedByCharactersInSet(character)
        filtered = inputString.componentsJoinedByString("")
        
        return  self == filtered
        
    }
    
    func validateMobileNumber() -> Bool {
        let character  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        let inputString:NSArray = self.componentsSeparatedByCharactersInSet(character)
        let filtered = inputString.componentsJoinedByString("")
 
        if (self != filtered || self.characters.count == 0 || self.characters.count <= YonaConstants.mobilePhoneLength.netherlands || self == "+31") {
            return false
        } else {
            return true
        }
    }
    
    func convertFromISO8601Duration() -> String? {
        
        var displayedString: String?
        var hasHitTimeSection = false
        var isSingular = false
        
        var hours = 0
        var days = 0
        
        displayedString = String()
        
        for val in self.characters {
            
            if val == "P" {
                // Do nothing when parsing the 'P'
                continue
                
            }else if val == "T" {
                // Indicate that we are now dealing with the 'time section' of the ISO8601 duration, then carry on.
                hasHitTimeSection = true
                continue
            }
            
            var tempString = String()
            
            if val >= "0" && val <= "9" {
                
                // We need to know whether or not the value is singular ('1') or not ('11', '23').
                if let safeDisplayedString = displayedString as String!
                    where displayedString!.characters.count > 0 && val == "1" {
                    
                    let lastIndex = safeDisplayedString.characters.count - 1
                    
                    let lastChar = safeDisplayedString[safeDisplayedString.startIndex.advancedBy(lastIndex)]
                    
                    //test if the current last char in the displayed string is a space (" "). If it is then we will say it's singular until proven otherwise.
                    if lastChar == " " {
                        isSingular = true
                    } else {
                        isSingular = false
                    }
                }
                else if val == "1" {
                    // if we are just dealing with a '1' then we will say it's singular until proven otherwise.
                    isSingular = true
                }
                else {
                    // ...otherwise it's a plural duration.
                    isSingular = false
                }
                
                tempString += "\(val)"
                
                displayedString! += tempString
                
            } else {
                
                // handle the duration type text. Make sure to use Months & Minutes correctly.
                switch val {
                    
                case "Y", "y":
                    
                    if isSingular {
                        tempString += " Year "
                    } else {
                        tempString += " Years "
                    }
                    
                    break
                    
                case "M", "m":
                    
                    if hasHitTimeSection {
                        
                        if isSingular {
                            tempString += " Minute "
                        } else {
                            tempString += " Minutes "
                        }
                    }
                    else {
                        
                        if isSingular {
                            tempString += " Month "
                        } else {
                            tempString += " Months "
                        }
                    }
                    
                    break
                    
                case "W", "w":
                    
                    if isSingular {
                        tempString += " Week "
                    } else {
                        tempString += " Weeks "
                    }
                    
                    break
                    
                case "D", "d":
                    
                    if isSingular {
                        tempString += " Day "
                    } else {
                        tempString += " Days "
                    }
                    days = Int(displayedString!)!
                    break
                    
                case "H", "h":
                    
                    if isSingular {
                        tempString += " Hour "
                    } else {
                        tempString += " Hours "
                    }
                    hours = Int(displayedString!)!
                    break
                    
                case "S", "s":
                    
                    if isSingular {
                        tempString += " Second "
                    } else {
                        tempString += " Seconds "
                    }
                    
                    break
                    
                default:
                    break
                    
                }
                // reset our singular flag, since we're starting a new duration.
                isSingular = false
            }
            
        }
        let timeToDisplay = String(hours + (days * 24))
        return timeToDisplay
    }
}