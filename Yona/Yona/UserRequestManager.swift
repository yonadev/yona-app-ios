//
//  UserRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

private var newUser: Users?

//MARK: - User APIService
extension APIServiceManager {
    
    private func genericUserRequest(httpmethodParam: httpMethods, userRequestType: userRequestTypes, body: BodyDataDictionary?, onCompletion: APIUserResponse){
        
    }
    
    /**
     Posts a new user to the server, part of the create new user flow, give a body with all the details such as mobile number (that must be unique) and then respond with new user object
     
     - parameter body: BodyDataDictionary, pass in a user body like this, mobile must be unique:
                         {
                         "firstName": "Ben",
                         "lastName": "Quin",
                         "mobileNumber": "+3161333999999",
                         "nickname": "RQ"
                         }
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func postUser(body: BodyDataDictionary, onCompletion: APIUserResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                //create a password for the user
                KeychainManager.sharedInstance.createYonaPassword()
                //set the path to post
                self.callRequestWithAPIServiceResponse(body, path: YonaConstants.environments.testPostUserLink, httpMethod: httpMethods.post, onCompletion: { success, json, err in
                    if let json = json {
                        guard success == true else {
                            onCompletion(false, self.serverMessage, self.serverCode,nil)
                            return
                        }
                        newUser = Users.init(userData: json)
                        onCompletion(true, self.serverMessage, self.serverCode, newUser)
                    } else {
                        //response from request failed
                        onCompletion(false, self.serverMessage, self.serverCode,nil)
                    }
                })
            } else {
                //network fail
                onCompletion(false, message, code, nil)
            }
        }
    }
    
    /**
     Updates the user by getting the current user, then passing in the edit link for that user with the new body of details to update
     
     - parameter body: BodyDataDictionary, pass in the body as below on how you want to update the user
             {
             "firstName": "Richard",
             "lastName": "Quin",
             "mobileNumber": "+31612345678",
             "nickname": "RQ"
             }
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func updateUser(body: BodyDataDictionary, onCompletion: APIUserResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser({ (success, message, code, user) in
                    //get the get user link...
                    if let editLink = user?.editLink {
                        ///now post updated user data
                        self.callRequestWithAPIServiceResponse(body, path: editLink, httpMethod: httpMethods.put, onCompletion: { success, json, err in
                            if let json = json {
                                guard success == true else {
                                    onCompletion(false, self.serverMessage, self.serverCode, nil)
                                    return
                                }
                                //parses new user into object to pass back
                                newUser = Users.init(userData: json)
                                onCompletion(true, self.serverMessage, self.serverCode, newUser)
                                
                            } else {
                                //response from request failed
                                onCompletion(false, self.serverMessage, self.serverCode, nil)
                            }
                        })
                    } else {
                        //Failed to retrive details for POST user details request
                        self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveUpdateUserDetails,
                            YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveUpdateUserDetails], code: 1)
                        onCompletion(false, self.serverMessage, self.serverCode, nil)
                    }
                })
            } else {
                onCompletion(false, message, code, nil)
            }
        }
    }
    
    /**
     V.important method called every time we need to access the user specific API, using the selfLink stored in the Keychain we can access the users details and returne this in a DAO user object in the response.
     
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func getUser(onCompletion: APIUserResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                if let selfUserLink = KeychainManager.sharedInstance.getUserSelfLink() {
                    self.callRequestWithAPIServiceResponse(nil, path: selfUserLink, httpMethod: httpMethods.get, onCompletion: { success, json, err in
                        if let json = json {
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode,nil)
                                return
                            }
                            newUser = Users.init(userData: json)
                            onCompletion(true, self.serverMessage, self.serverCode, newUser)
                        } else {
                            //response from request failed
                            onCompletion(false, self.serverMessage, self.serverCode,nil)
                        }
                    })
                } else {
                    //Failed to retrive details for GET user details request
                    self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveGetUserDetails,
                        YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveGetUserDetails], code: 1)
                    onCompletion(false, self.serverMessage, self.serverCode,nil)
                }
            } else {
                onCompletion(false, message, code,nil)
            }
        }
    }
    
    /**
     Deletes the user, first get the user then use the edit link to delete the user
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func deleteUser(onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success{
                self.getUser{ (success, message, code, user) in
                    //get the get user link...
                    if let editLink = user?.editLink {
                        self.callRequestWithAPIServiceResponse(nil, path: editLink, httpMethod: httpMethods.delete) { success, json, err in
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode)
                                return
                            }
                            KeychainManager.sharedInstance.clearKeyChain()
                            onCompletion(true, self.serverMessage, self.serverCode)
                        }
                    } else {
                        //Failed to retrive details for delete user request
                        self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveUserDetailsForDeleteUser,
                            YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveUserDetailsForDeleteUser], code: 1)
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                }
            } else {
                onCompletion(false, message, code)
            }
        }
    }
    
    /**
     Resends the One Time Password (OTP) code that is sent to the user when they are required to confirm their account

     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func otpResendMobile(onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser({ (success, message, code, user) in
                    if let otpResendMobileLink = user?.otpResendMobileLink{
                        #if DEBUG
                            print(otpResendMobileLink)
                        #endif
                        
                        self.callRequestWithAPIServiceResponse(nil, path: otpResendMobileLink, httpMethod: httpMethods.post) { success, json, err in
                            guard success == true else {
                                onCompletion(false, self.serverMessage, self.serverCode)
                                return
                            }
                            onCompletion(true, self.serverMessage, self.serverCode)
                        }
                    } else {
                        //Failed to retrive details for otp resend request
                        self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveOTP,
                            YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveOTP], code: 1)
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                })
                
            } else {
                //no network connection
                onCompletion(false, self.serverMessage, self.serverCode)
            }
        }
    }
    
    /**
     Called when the user is required to confirm their mobile number after signup, they are sent a text with the One Time Password (OTP) code in which they have to enter, this code is then sent through in the body and then the request can be made to confirm this mobile, if the code is wrong the server sends back messages saying as much...they have 5 attempts, after which the app is locked
     
     - parameter body: BodyDataDictionary?, The body must take the form of this, the code is the OTP sent by text
                     {
                     "code": "1234"
                     }
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func confirmMobileNumber(body: BodyDataDictionary?, onCompletion: APIResponse) {
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser{ (success, message, code, user) in
                    if let confirmMobileLink = user?.confirmMobileLink{
                        #if DEBUG
                            print(confirmMobileLink)
                        #endif
                        
                        self.callRequestWithAPIServiceResponse(body, path: confirmMobileLink, httpMethod: httpMethods.post) { success, json, err in
                            guard success == true else {
                                print(err)
                                onCompletion(false, self.serverMessage, self.serverCode)
                                return
                            }
                            onCompletion(true, self.serverMessage, self.serverCode)
                        }
                    } else {
                        //Failed to retrive details for confirm mobile request
                        self.setServerCodeMessage([YonaConstants.serverResponseKeys.message: YonaConstants.serverCodes.FailedToRetrieveConfirmMobile,
                            YonaConstants.serverResponseKeys.code: YonaConstants.serverCodes.FailedToRetrieveConfirmMobile], code: 1)
                        onCompletion(false, self.serverMessage, self.serverCode)
                    }
                }
                
            } else {
                //network fail
                onCompletion(false, self.serverMessage, self.serverCode)
            }
        }
    }
}