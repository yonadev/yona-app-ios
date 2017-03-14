 //
//  UserRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


//MARK: - User APIService
class UserRequestManager{

    var newUser: Users?

    let APIService = APIServiceManager.sharedInstance
    
    static let sharedInstance = UserRequestManager()
    
    private init() {}
    
    private func genericUserRequest(httpmethodParam: httpMethods, path: String, userRequestType: userRequestTypes, body: BodyDataDictionary?, onCompletion: APIUserResponse){
        
        ///now post updated user data
        APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam, onCompletion: { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil)
                    return
                }
                //only update our user body on get, post or update
                if userRequestType == userRequestTypes.getUser || userRequestType == userRequestTypes.postUser || userRequestType == userRequestTypes.updateUser {
                    self.newUser = Users.init(userData: json)
                }
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.newUser)
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil)
            }
        })
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
     - parameter confirmCode: String? Confirm code required to post a new body if the user has lost the phone and is sent a confirm code to update their account
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func postUser(body: BodyDataDictionary, confirmCode: String?, onCompletion: APIUserResponse) {
        var path = YonaConstants.commands.users //not in user body need to hardcode
        //if user lost phone then we need to set a confirm code
        if let confirmCodeUnwrap = confirmCode {
            path = YonaConstants.commands.users + YonaConstants.commands.userRequestOverrideCode + confirmCodeUnwrap
        }
        genericUserRequest(httpMethods.post, path: path, userRequestType: userRequestTypes.postUser, body: body, onCompletion: onCompletion)
    }
    
    
    func informServerAppIsOpen(user: Users, success: () -> Void) {
        let path = YonaConstants.commands.appOpened.stringByReplacingOccurrencesOfString("{id}", withString: user.userID)
        print(path)
        genericUserRequest(httpMethods.post, path: path, userRequestType: userRequestTypes.postUser, body: BodyDataDictionary(), onCompletion: { _ in
            success()
        })
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
            if let editLink = self.newUser?.editLink {
                ///now post updated user data
                genericUserRequest(httpMethods.put, path: editLink, userRequestType: userRequestTypes.updateUser, body: body, onCompletion: onCompletion)
            } else {
                //Failed to retrive details for POST user details request
                onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.ok200), nil)
            }
    }
    
    /**
     V.important method called every time we need to access the user specific API, using the selfLink stored in the Keychain we can access the users details and returne this in a DAO user object in the response.
     
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     - parameter userRequestType: GetUserRequest, This can be allowed (so we will allow an API call to the User Request) or not allowed (we will not allow whoever is call ing this to call the API for get User, but just return the stored User body). This changes depending on where we call the get user in the code
     */
    func getUser(userRequestType: GetUserRequest, onCompletion: APIUserResponse) {
        if let selfUserLink = KeychainManager.sharedInstance.getUserSelfLink() {
            if self.newUser == nil || NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isBlocked) || userRequestType == GetUserRequest.allowed { //if blocked because of pinreset
                #if DEBUG
                    print("***** Get User API call ******")
                #endif
                genericUserRequest(httpMethods.get, path: selfUserLink, userRequestType: userRequestTypes.getUser, body: nil, onCompletion: onCompletion)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                onCompletion(true, YonaConstants.serverMessages.OK, String(responseCodes.ok200), self.newUser)
                })
            }
        } else {
            //Failed to retrive details for GET user details request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode), nil)
        }
    }
    
    /**
     Deletes the user, first get the user then use the edit link to delete the user
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func deleteUser(onCompletion: APIResponse) {
            //get the get user link...
        if let editLink = self.newUser?.editLink {
            genericUserRequest(httpMethods.delete, path: editLink, userRequestType: userRequestTypes.deleteUser, body: nil, onCompletion: { (success, message, code, nil) in
                if success {
                    KeychainManager.sharedInstance.clearKeyChain()
                }
                onCompletion(success, message, code)
            })

        } else {
            //Failed to retrive details for delete user request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode))
        }
    }
    
    /**
     Resends the One Time Password (OTP) code that is sent to the user when they are required to confirm their account

     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func otpResendMobile(onCompletion: APIResponse) {
        if let selfUserLink = KeychainManager.sharedInstance.getUserSelfLink() {
            genericUserRequest(httpMethods.get, path: selfUserLink, userRequestType: userRequestTypes.getUser, body: nil) {(success, message, code, user) in
                if let otpResendMobileLink = user?.otpResendMobileLink{
                    self.genericUserRequest(httpMethods.post, path: otpResendMobileLink, userRequestType: userRequestTypes.resendMobileConfirmCode, body: nil, onCompletion: { (success, message, code, user) in
                        onCompletion(success, message, code)
                    })
                } else {
                    //Failed to retrive details for otp resend request
                    onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveOTP, String(responseCodes.internalErrorCode))
                }
            }
        }
        
//        if let otpResendMobileLink = self.newUser?.otpResendMobileLink{
//            genericUserRequest(httpMethods.post, path: otpResendMobileLink, userRequestType: userRequestTypes.resendMobileConfirmCode, body: nil, onCompletion: { (success, message, code, user) in
//                onCompletion(success, message, code)
//            })
//        } else {
//            //Failed to retrive details for otp resend request
//            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveOTP, String(responseCodes.internalErrorCode))
//        }
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
        if let confirmMobileLink = self.newUser?.confirmMobileLink {
            genericUserRequest(httpMethods.post, path: confirmMobileLink, userRequestType: userRequestTypes.confirmMobile, body: body, onCompletion: { (success, message, code, user) in
                if success {
                    //if we confirmed successfully get the user as new links need to be parsed
                    self.genericUserRequest(httpMethods.get, path: KeychainManager.sharedInstance.getUserSelfLink()!, userRequestType: userRequestTypes.getUser, body: nil) { (success, message, code, user) in
                        onCompletion(success, message, code)
                    }
                } else {
                    onCompletion(success, message, code)
                }
            })
        } else {
            //Failed to retrive details for confirm mobile request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode))
        }
    }
    
    func getMobileConfigFile( onCompletion: APIMobileConfigResponse) {
        if let mobileConfigURL = self.newUser?.mobilConfigFileURL {
           APIServiceManager.sharedInstance.callRequestWithAPIMobileConfigResponse(nil, path: mobileConfigURL, httpMethod: httpMethods.get, onCompletion: onCompletion)
            
//            Manager.sharedInstance.makeFileRequest(mobileConfigURL, body: nil, httpMethod: httpMethods.get
//                , httpHeader: <#T##[String : String]#>, onCompletion: <#T##APIMobileConfigResponse##APIMobileConfigResponse##(Bool, String?, ServerCode?) -> Void#>)
//            
//            genericUserRequest(httpMethods.get, path:mobileConfigURL, userRequestType: userRequestTypes.getConfigFile, body: ["":""], onCompletion: { (success, message, code, user) in
//                if success {
//                    onCompletion(success, nil, code)
//                }
//                else {
//                    onCompletion(success, nil, code)
//                }
//            })
        }
    }
}
