//
//  pinResetRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
//MARK: - New Device Requests APIService
class PinResetRequestManager {
    
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance

    static let sharedInstance = PinResetRequestManager()
    
    private init() {}
    
    /**
     Generic method to request, verify or clear pin requests
     
     - parameter httpmethodParam: httpMethods, The httpmethod enum, POST GET etc
     - parameter pinRequestType: pinRequestTypes, enum of different pin requests depending on if we verify, reset or clear a pin
     - parameter body: BodyDataDictionary?, body that is needed in a POST call, can be nil
     - parameter onCompletion: APIPinResetResponse, Sends back the pin ISO code (optional) and also the server messages and success or fail of the request
     */
    private func pinResetHelper(httpmethodParam: httpMethods, pinRequestType: pinRequestTypes, body: BodyDataDictionary?, onCompletion: APIPinResetResponse){

        switch pinRequestType
        {
        case .resetRequest:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
                //success so get the user?
                if success {
                    if let path = user?.requestPinResetLink {
                        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                            if success {
                                if let jsonUnwrap = json,
                                    let pincode = jsonUnwrap[YonaConstants.jsonKeys.pinResetDelay] as? PinCode {
                                    onCompletion(true, pincode, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                                }
                            } else {
                                onCompletion(false, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                            }
                        }
                    } else {
                        onCompletion(false, nil , YonaConstants.serverMessages.FailedToGetResetPinLink, String(responseCodes.internalErrorCode))
                    }
                } else {
                    onCompletion(false, nil , YonaConstants.serverMessages.FailedToRetrieveUpdateUserDetails, String(responseCodes.internalErrorCode))
                }
            }
        case .resendResetRequest:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
                //success so get the user?
                if success {
                    if let path = user?.resendRequestPinResetLinks{
                        self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                            onCompletion(success, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                        }
                    } else {
                        onCompletion(false, nil , YonaConstants.serverMessages.FailedToGetResendResetRequestLink, String(responseCodes.internalErrorCode))
                    }
                } else {
                    onCompletion(false, nil , YonaConstants.serverMessages.FailedToRetrieveUpdateUserDetails, String(responseCodes.internalErrorCode))
                }
            }
        case .verifyRequest:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
                //success so get the user?
                if success {
                    if let path = user?.requestPinVerifyLink{
                        self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                            onCompletion(success, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                        }
                    } else {
                        onCompletion(false, nil , YonaConstants.serverMessages.FailedToGetResetPinVerifyLink, String(responseCodes.internalErrorCode))
                    }
                } else {
                    onCompletion(false, nil , YonaConstants.serverMessages.FailedToRetrieveUpdateUserDetails, String(responseCodes.internalErrorCode))
                }
            }
        case .clearRequest:
            UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
                //success so get the user?
                if success {
                    if let path = user?.requestPinClearLink{
                        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                            onCompletion(success, nil, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error))
                        }
                    } else {
                        onCompletion(false, nil , YonaConstants.serverMessages.FailedToGetResetPinVerifyLink, String(responseCodes.internalErrorCode))
                    }
                }
            }
        }
    }
    
    /**
     Resends the pin reset request, clears and requests making it simpler
     
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResendResetRequest(onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.resendResetRequest, body: nil) { (success, ISOCode, serverMessage, serverCode) in
            onCompletion(success, ISOCode, serverMessage, serverCode)
        }
    }
    
    /**
     Resets the pin when the user enters their pin (password) wrong 5 times
     
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResetRequest(onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.resetRequest, body: nil) { (success, ISOCode, serverMessage, serverCode) in
            onCompletion(success, ISOCode, serverMessage, serverCode)
        }
    }
    
    /**
     Called when the user enters the OTP sent to them after 24 hours so that the reset password can be verified
     
     - parameter body: BodyDataDictionary, Body containing the OTP sent by text to user
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResetVerify(body: BodyDataDictionary, onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.verifyRequest, body: body) { (success, nil, serverMessage, serverCode) in
            onCompletion(success, nil, serverMessage, serverCode)

        }
    }
    
    /**
     Called after a successful verify message so that the pin reset is cleared
     
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResetClear(onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.clearRequest, body: nil) { (success, nil, serverMessage, serverCode) in
            if success {
                onCompletion(true, nil, serverMessage, serverCode)
            } else {
                onCompletion(false, nil, serverMessage, serverCode)
            }
        }
    }
}