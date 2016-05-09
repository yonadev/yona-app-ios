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
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, String(error!.code) ?? error!.domain, nil)
                    return
                }
                //only update our user body on get, post or update
                if userRequestType == userRequestTypes.getUser || userRequestType == userRequestTypes.postUser || userRequestType == userRequestTypes.updateUser {
                    self.newUser = Users.init(userData: json)
                }
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, String(error!.code) ?? error!.domain, self.newUser)
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, String(error!.code) ?? error!.domain, nil)
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
        //create a password for the user
        KeychainManager.sharedInstance.createYonaPassword()
        var path = YonaConstants.environments.testUrl + YonaConstants.commands.users //not in user body need to hardcode
        //if user lost phone then we need to set a confirm code
        if let confirmCodeUnwrap = confirmCode {
            path = YonaConstants.environments.testUrl + YonaConstants.commands.users + YonaConstants.commands.userRequestOverrideCode + confirmCodeUnwrap
        }
        genericUserRequest(httpMethods.post, path: path, userRequestType: userRequestTypes.postUser, body: body, onCompletion: onCompletion)
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
                onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode), nil)
            }
    }
    
    /**
     V.important method called every time we need to access the user specific API, using the selfLink stored in the Keychain we can access the users details and returne this in a DAO user object in the response.
     
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func getUser(onCompletion: APIUserResponse) {
        if let selfUserLink = KeychainManager.sharedInstance.getUserSelfLink() {
            genericUserRequest(httpMethods.get, path: selfUserLink, userRequestType: userRequestTypes.getUser, body: nil, onCompletion: onCompletion)
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
                KeychainManager.sharedInstance.clearKeyChain()
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
        if let otpResendMobileLink = self.newUser?.otpResendMobileLink{
            genericUserRequest(httpMethods.post, path: otpResendMobileLink, userRequestType: userRequestTypes.resendMobileConfirmCode, body: nil, onCompletion: { (success, message, code, user) in
                onCompletion(success, message, code)
            })
        } else {
            //Failed to retrive details for otp resend request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveOTP, String(responseCodes.internalErrorCode))
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
        if let confirmMobileLink = self.newUser?.confirmMobileLink{
            genericUserRequest(httpMethods.post, path: confirmMobileLink, userRequestType: userRequestTypes.confirmMobile, body: body, onCompletion: { (success, message, code, user) in
                onCompletion(success, message, code)
            })
        } else {
            //Failed to retrive details for confirm mobile request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode))
        }
    }
}