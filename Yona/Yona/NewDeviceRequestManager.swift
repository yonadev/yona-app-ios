 //
//  NewDeviceRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

//MARK: - New Device Requests APIService
class NewDeviceRequestManager {
    
    let APIService = APIServiceManager.sharedInstance
    static let sharedInstance = NewDeviceRequestManager()
    private var newUser: Users?

    private init() {}

    func genericHelper(httpMethod: httpMethods, addDeviceCode: String?, mobileNumber: String?, onCompletion: APIUserResponse) {
        self.APIService.getUser{ (success, message, code, user) in
            switch httpMethod {
            case httpMethods.put:
                    if let path = user?.newDeviceRequestsLink {
                        var bodyNewDevice: BodyDataDictionary?
                        if let password = addDeviceCode {
                            bodyNewDevice = ["newDeviceRequestPassword": password]
                        }
                        self.APIService.callRequestWithAPIServiceResponse(bodyNewDevice, path: path, httpMethod: httpMethods.put, onCompletion: { (success, json, error) in
                            onCompletion(success, self.APIService.serverMessage, self.APIService.serverCode, nil)
                        })
                    }
                
            case httpMethods.get:
                let langId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
                let countryId = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
                let language = "\(langId)-\(countryId)"
                //need to call manager directly because of different response header
                if let password = addDeviceCode {
                    let httpHeader = ["Content-Type": "application/json", "Accept-Language": language, "Yona-NewDeviceRequestPassword": password]
                    //need to create the new device request URL on the other device as we only have the mobile number to get the device request, also user needs to enter password that appears on their other device
                    if let mobileNumber = mobileNumber {
                        let path = YonaConstants.environments.testUrl + YonaConstants.commands.newDeviceRequests + mobileNumber.replacePlusSign() //non are optional here so you cannot put in check (the if let bit)
                        Manager.sharedInstance.makeRequest(path, body: nil, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: { success, dict, error in
                                guard success == true else {
                                    onCompletion(success, self.APIService.serverMessage, self.APIService.serverCode, nil)
                                    return
                                }
                                //Update user details locally
                                if let json = dict {
                                    self.newUser = Users.init(userData: json)
                                }
                                //send back user object
                                onCompletion(success, self.APIService.serverMessage, self.APIService.serverCode, self.newUser)
                        })
                    }
                }
                
            case httpMethods.delete:
                if let path = user?.newDeviceRequestsLink {
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethod, onCompletion: { (success, json, error) in
                        onCompletion(success, self.APIService.serverMessage, self.APIService.serverCode, self.newUser)

                    })
                }
            default:
                break
            }
        }
    }
    
    /**
     Add a new device from device A by calling this, password generated randomly, will be sent to device B
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     - return none
     */
    func putNewDevice(onCompletion: APIGetDeviceResponse) {
        let addDevicePassCode = String(100000 + arc4random_uniform(100000)) //generate random number password between of 5 random digits
        self.genericHelper(httpMethods.put, addDeviceCode: addDevicePassCode, mobileNumber: nil) { (success, message, code, nil) in
            if success {
                onCompletion(true, message, code, addDevicePassCode)
            } else {
                onCompletion(false, message, code, addDevicePassCode)
            }
        }
    }
    
    /**
     Device B gets the password, user enters password, UI calls this method passing in password, response is the user info generated from the already created account...used to get more user info when requested as the SELF link is tored
     
     - parameter password: String Password sent from device A to this device B
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     - return none
     */
    func getNewDevice(password: String, mobileNumber: String, onCompletion: APIUserResponse) {
        //create a password for the user
        self.genericHelper(httpMethods.get, addDeviceCode: password, mobileNumber: mobileNumber) { (success, message, code, user) in
            if success {
                onCompletion(true, message, code, user)
            } else {
                onCompletion(false, message, code, nil)
            }
        }
    }
    
    /**
     Used to delete new device request after it has been verified, passes back success or fail
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     - return none
     */
    func deleteNewDevice(onCompletion: APIResponse) {
        self.genericHelper(httpMethods.delete, addDeviceCode: nil, mobileNumber: nil) { (success, message, code, nil) in
            if success {
                onCompletion(true, message, code)
            } else {
                onCompletion(false, message, code)
            }
        }
    }
}