//
//  StringExtensions.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension String {
    fileprivate func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
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
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    //validate PhoneNumber
    var isPhoneNumber: Bool {
        
        let character  = CharacterSet(charactersIn: "+0123456789").inverted
        var filtered:String!
        let inputString:NSArray = self.components(separatedBy: character) as NSArray
        filtered = inputString.componentsJoined(by: "") as String?
        
        return  self == filtered
        
    }
    
    func formatNumber(prefix: String) -> String {
        var number = self
        if !prefix.isEmpty && !prefix.hasPrefix("+")  {
            number = "+" + number
        }
        return number.removeWhitespace().removeBrackets().formatDutchCountryCodePrefix()
    }
    
    func isValidMobileNumber() -> Bool {
        let phoneNumberRegex = "^\\+[0-9]{6,20}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneTest.evaluate(with: self)
    }
    
    func formatDutchCountryCodePrefix()->String{
        var mobileNumber = self
        let wrongDutchPrefix = "+310"
        if mobileNumber.hasPrefix(wrongDutchPrefix) {
            mobileNumber = mobileNumber.deletePrefix(wrongDutchPrefix)
            mobileNumber = "+31" + mobileNumber
        }
        return mobileNumber
    }
    
    func deletePrefix(_ prefix: String) -> String {
        return String(self.dropFirst(prefix.count))
    }
    
    func randomAlphaNumericString() -> String {
        let length = 6
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        print(randomString)
        return randomString
    }
    
    func convertFromISO8601Duration() -> (Int, Int, Int){
        
        var displayedString: String?
        var hasHitTimeSection = false
        var isSingular = false
        
        var hours = 0
        var minutes = 0
        var seconds = 0
        
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
                if let safeDisplayedString = displayedString as String!, displayedString!.characters.count > 0 && val == "1" {
                    
                    let lastIndex = safeDisplayedString.characters.count - 1
                    
                    let lastChar = safeDisplayedString[safeDisplayedString.characters.index(safeDisplayedString.startIndex, offsetBy: lastIndex)]
                    
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
                        minutes = Int(displayedString!)!
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
                    seconds = Int(displayedString!)!
                    break
                    
                default:
                    break
                }
                displayedString = ""
                // reset our singular flag, since we're starting a new duration.
                isSingular = false
            }
        }
        #if DEBUG
            print("hour\(hours)")
            print("minute\(minutes)")
            print("seconds\(seconds)")
        #endif
        return (hours, minutes, seconds)
        
    }
    
    func dashRemoval() -> Array<String> {
        return self.characters.split{$0 == "-"}.map(String.init)
    }
    
    func heightForWithFont(_ font: UIFont, width: CGFloat, insets: UIEdgeInsets) -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width + insets.left + insets.right, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        
        label.sizeToFit()
        return label.frame.height + insets.top + insets.bottom
    }
}
