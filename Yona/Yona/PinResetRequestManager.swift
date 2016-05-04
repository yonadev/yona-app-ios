//
//  pinResetRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
//MARK: - New Device Requests APIService
extension APIServiceManager {
    
    /**
     Generic method to request, verify or clear pin requests
     
     - parameter httpmethodParam: httpMethods, The httpmethod enum, POST GET etc
     - parameter pinRequestType: pinRequestTypes, enum of different pin requests depending on if we verify, reset or clear a pin
     - parameter body: BodyDataDictionary?, body that is needed in a POST call, can be nil
     - parameter onCompletion: APIPinResetResponse, Sends back the pin ISO code (optional) and also the server messages and success or fail of the request
     */
    private func pinResetHelper(httpmethodParam: httpMethods, pinRequestType: pinRequestTypes, body: BodyDataDictionary?, onCompletion: APIPinResetResponse){
        self.getUser{ (success, message, code, user) in
            
            switch pinRequestType
            {
            case .resetRequest:
                if let path = user?.requestPinResetLink {
                    self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                        if success {
                            if let jsonUnwrap = json,
                                let pincode = jsonUnwrap[YonaConstants.jsonKeys.pinResetDelay] as? PinCode {
                                onCompletion(true, pincode , self.serverMessage, self.serverCode)
                            }
                        } else {
                            onCompletion(false, nil , self.serverMessage, self.serverCode)
                        }
                    }
                } else {
                    onCompletion(false, nil , self.serverMessage, self.serverCode)
                }
            case .verifyRequest:
                if let path = user?.requestPinVerifyLink{
                    self.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                        if success {
                            onCompletion(true , nil, self.serverMessage, self.serverCode)
                        } else {
                            onCompletion(false , nil, self.serverMessage, self.serverCode)
                        }
                    }
                } else {
                    onCompletion(false, nil , self.serverMessage, self.serverCode)
                }
                
            case .clearRequest:
                if let path = user?.requestPinClearLink{
                    self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpmethodParam) { (success, json, error) in
                        if success {
                            onCompletion(true , nil, self.serverMessage, self.serverCode)
                        } else {
                            onCompletion(false , nil, self.serverMessage, self.serverCode)
                        }
                    }
                } else {
                    onCompletion(false, nil , self.serverMessage, self.serverCode)
                }
            }
        }
    }
    
    /**
     Resets the pin when the user enters their pin (password) wrong 5 times
     
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResetRequest(onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.resetRequest, body: nil) { (success, ISOCode, serverMessage, serverCode) in
            if success {
                onCompletion(true, ISOCode, serverMessage, serverCode)
            } else {
                onCompletion(false, nil, serverMessage, serverCode)
            }
        }
    }
    
    /**
     Called when the user enters the OTP sent to them after 24 hours so that the reset password can be verified
     
     - parameter body: BodyDataDictionary, Body containing the OTP sent by text to user
     - parameter onCompletion: APIPinResetResponse, Returns the pincode in ISO (if available as optional) format so UI knows how long the user has to wait, also success, fail and server messages
     */
    func pinResetVerify(body: BodyDataDictionary, onCompletion: APIPinResetResponse) {
        pinResetHelper(httpMethods.post, pinRequestType: pinRequestTypes.verifyRequest, body: body) { (success, nil, serverMessage, serverCode) in
            if success {
                onCompletion(true, nil, serverMessage, serverCode)
            } else {
                onCompletion(false, nil, serverMessage, serverCode)
            }
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