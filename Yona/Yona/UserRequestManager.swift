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
    
    fileprivate init() {}
    
    fileprivate func saveUserDetail(_ json: BodyDataDictionary) {
        do {
            let userData =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let userDataString = String(data: userData, encoding: String.Encoding.utf8)
            UserDefaults.standard.set(userDataString, forKey: YonaConstants.nsUserDefaultsKeys.savedUser)
        } catch let jsonError {
            print(jsonError)
        }
        self.newUser = Users.init(userData: json)
    }
    
    fileprivate func genericUserRequest(_ httpmethodParam: httpMethods, path: String, userRequestType: userRequestTypes, body: BodyDataDictionary?, onCompletion: @escaping APIUserResponse){
        ///now post updated user data
        APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam, onCompletion: { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil)
                    return
                }
                //only update our user body on get, post, update or confirm mobile number
                if userRequestType == userRequestTypes.getUser || userRequestType == userRequestTypes.postUser || userRequestType == userRequestTypes.updateUser || userRequestType == userRequestTypes.confirmMobile {
                    self.saveUserDetail(json)
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
    func postUser(_ body: BodyDataDictionary, confirmCode: String?, onCompletion: @escaping APIUserResponse) {
        var path = YonaConstants.commands.users //not in user body need to hardcode
        //if user lost phone then we need to set a confirm code
        if let confirmCodeUnwrap = confirmCode {
            path = YonaConstants.commands.users + YonaConstants.commands.userRequestOverrideCode + confirmCodeUnwrap
        }
        genericUserRequest(httpMethods.post, path: path, userRequestType: userRequestTypes.postUser, body: body, onCompletion: onCompletion)
    }
    
    
    func postOpenAppEvent(_ user: Users, onCompletion: @escaping APIResponse) {
        let openAppEventLinkPath = user.devices.first(where: { $0.isRequestingDevice! }).map {$0.openAppEventLink}
        if let path = openAppEventLinkPath, let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String, let appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String {
            let bodyForOpenAppEvent = ["operatingSystem": "IOS", "appVersion": appVersion, "appVersionCode":appVersionCode] as BodyDataDictionary
            genericUserRequest(httpMethods.post, path: path!, userRequestType: userRequestTypes.postUser, body: bodyForOpenAppEvent, onCompletion: { (success, message, code, nil) in
                onCompletion(success, message, code)
            })
        } else {
            //Failed to retrive details for open app event
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(describing: responseCodes.internalErrorCode))
        }
    }
    
    /**users
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
    
    
    func updateUser(_ body: BodyDataDictionary, onCompletion: @escaping APIUserResponse) {
//        NSLog("----------------------- YONA")
//        NSLog("----------------------- updateUser")
//        NSLog("           ")
//        NSLog("           ")
//        NSLog("self.newUser? %@",self.newUser!.firstName)

            if let editLink = self.newUser?.editLink {
                ///now post updated user data
                genericUserRequest(httpMethods.put, path: editLink, userRequestType: userRequestTypes.updateUser, body: body, onCompletion: onCompletion)
            } else {
                //Failed to retrive details for POST user details request
                onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(describing: responseCodes.ok200), nil)
            }
    }
    
    /**
     V.important method called every time we need to access the user specific API, using the selfLink stored in the Keychain we can access the users details and returne this in a DAO user object in the response.
     
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     - parameter userRequestType: GetUserRequest, This can be allowed (so we will allow an API call to the User Request) or not allowed (we will not allow whoever is call ing this to call the API for get User, but just return the stored User body). This changes depending on where we call the get user in the code
     */
    func getUser(_ userRequestType: GetUserRequest, onCompletion: @escaping APIUserResponse) {
        
        if var selfUserLink = KeychainManager.sharedInstance.getUserSelfLink(){
            selfUserLink = correctUserFetchUrlIfNeeded(storedUserUrl: selfUserLink)
            if self.newUser == nil || UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isBlocked) || userRequestType == GetUserRequest.allowed { //if blocked because of pinreset
                #if DEBUG
                    print("***** Get User API call ******")
                #endif
                genericUserRequest(httpMethods.get, path: selfUserLink, userRequestType: userRequestTypes.getUser, body: nil, onCompletion: onCompletion)
            } else {
                DispatchQueue.main.async(execute: {
                onCompletion(true, YonaConstants.serverMessages.OK, String(describing: responseCodes.ok200), self.newUser)
                })
            }
        } else {
            //Failed to retrive details for GET user details request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(describing: responseCodes.internalErrorCode), nil)
        }
    }
    
    func correctUserFetchUrlIfNeeded(storedUserUrl: String) -> String {
        return correctUserFetchUrlIfNeeded(userURLStr: getSavedUserFromUserDefaults().getSelfLink!, environmentBaseURLStr: EnvironmentManager.baseUrlString()!,storedUserUrlStr: storedUserUrl)    }
    
    func correctUserFetchUrlIfNeeded(userURLStr:String, environmentBaseURLStr:String, storedUserUrlStr:String) -> String {
        let userURL = URL(string: userURLStr)
        let environmentBaseURL = URL(string: environmentBaseURLStr)
        if userURL?.scheme != environmentBaseURL?.scheme {
            let formattedURLString = userURL?.absoluteString.deletePrefix((userURL?.scheme)!)
            return environmentBaseURL!.scheme! + formattedURLString!
        }
        return storedUserUrlStr //return as there is no mess up of URLs which is cause of the issue YD-621
    }
    
    func getSavedUserFromUserDefaults() -> Users {
        if let savedUser = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.savedUser), let user = convertToDictionary(text: savedUser as! String) {
            return Users.init(userData: user as BodyDataDictionary)
        }
        return Users.init(userData: [:])
    }
    
    /**
     Deletes the user, first get the user then use the edit link to delete the user
     
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func deleteUser(_ onCompletion: @escaping APIResponse) {
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
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(describing: responseCodes.internalErrorCode))
        }
    }
    
    /**
     Resends the confirmation code that is sent to the user when they are required to confirm their account

     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func resendConfirmationCodeMobile(_ onCompletion: @escaping APIResponse) {
        if let selfUserLink = KeychainManager.sharedInstance.getUserSelfLink() {
            genericUserRequest(httpMethods.get, path: selfUserLink, userRequestType: userRequestTypes.getUser, body: nil) {(success, message, code, user) in
                if let resendConfirmationCodeMobileLink = user?.resendConfirmationCodeMobileLink{
                    self.genericUserRequest(httpMethods.post, path: resendConfirmationCodeMobileLink, userRequestType: userRequestTypes.resendMobileConfirmCode, body: nil, onCompletion: { (success, message, code, user) in
                        onCompletion(success, message, code)
                    })
                } else {
                    //Failed to retrive details for confirmation code resend request
                    onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveConfirmationCode, String(describing: responseCodes.internalErrorCode))
                }
            }
        }
    }
    
    /**
     Called when the user is required to confirm their mobile number after signup, they are sent a text with the confimation code in which they have to enter, this code is then sent through in the body and then the request can be made to confirm this mobile, if the code is wrong the server sends back messages saying as much...they have 5 attempts, after which the app is locked
     
     - parameter body: BodyDataDictionary?, The body must take the form of this, the code is the confirmation code sent by text
                     {
                     "code": "1234"
                     }
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func confirmMobileNumber(_ body: BodyDataDictionary?, onCompletion: @escaping APIResponse) {
        if let confirmMobileLink = self.newUser?.confirmMobileNumberLink {
            genericUserRequest(httpMethods.post, path: confirmMobileLink, userRequestType: userRequestTypes.confirmMobile, body: body, onCompletion: { (success, message, code, user) in
                onCompletion(success, message, code)
            })
        } else if let savedUser = UserDefaults.standard.object(forKey: YonaConstants.nsUserDefaultsKeys.savedUser) {
            let user = convertToDictionary(text: savedUser as! String)
            self.newUser = Users.init(userData: user! as BodyDataDictionary)
            if let confirmMobileLink = self.newUser?.confirmMobileNumberLink {
                genericUserRequest(httpMethods.post, path: confirmMobileLink , userRequestType: userRequestTypes.confirmMobile, body: body, onCompletion: { (success, message, code, user) in
                    onCompletion(success, message, code)
                })
            }
        }else {
            //Failed to retrive details for confirm mobile request
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(describing: responseCodes.internalErrorCode))
        }
    }
    
    func getMobileConfigFile( _ onCompletion: @escaping APIMobileConfigResponse) {
        let mobileConfigFileURL = self.newUser?.devices.first(where: { $0.isRequestingDevice! }).map {$0.mobileConfigLink}
        if let mobileConfigURL = mobileConfigFileURL {
            APIServiceManager.sharedInstance.callRequestWithAPIMobileConfigResponse(nil, path: mobileConfigURL!, httpMethod: httpMethods.get, onCompletion: onCompletion)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
