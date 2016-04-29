//
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias BodyDataDictionary = [String: AnyObject]

class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    
    var serverMessage: ServerMessage?
    var serverCode: ServerCode?
    
    private init() {}
    
    /**
     Calls the manager to make a standard http request using the httpHeader json type, this requires the users password that is stored in the keychain:
        ["Content-Type": "application/json", "Yona-Password": yonaPassword]
     
     - parameters: body: BodyDataDictionary?, the body of the req uest required by some calls, can be nil
     - parameters: path: String, the path to the API service call
     - parameters: httpMethod: httpMethods, the httpmethod enum (post, get , put, delete)
     - return: onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func callRequestWithAPIServiceResponse(body: BodyDataDictionary?, path: String, httpMethod: httpMethods, onCompletion:APIServiceResponse){
        
        guard let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword() else {
            onCompletion(false,nil, YonaConstants.YonaErrorTypes.UserPasswordRequestFail)
            return
        }
        let httpHeader = ["Content-Type": "application/json", "Yona-Password": yonaPassword]
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: { success, dict, err in
            if (success){
                onCompletion(true, dict , err)
            } else {
                onCompletion(false, dict , err)
            }
        })   
    }

    /**
     Setups up the messages from the server so the UI knows what is going wrong or right
     
     - parameter: json:BodyDataDictionary?, the body of the messages from server, if there is an error then there is a message or code key in response
     - parameter: code: Int, the http response code we need to check (200-204 success, other is fail
     - return: none
     */
    func setServerCodeMessage(json:BodyDataDictionary?, code: Int) {
        //check if json is empty
        
        if case responseCodes.ok200.rawValue ... responseCodes.ok204.rawValue = code { // successful you get 200 to 204 back, anything else...Houston we gotta a problem
            self.serverMessage = YonaConstants.serverMessages.OK
            self.serverCode = YonaConstants.serverCodes.OK
        } else {
            if let jsonUnwrapped = json,
                let message = jsonUnwrapped[YonaConstants.serverResponseKeys.message] as? String{
                    self.serverMessage = message
                    if let serverCode = jsonUnwrapped[YonaConstants.serverResponseKeys.code] as? String{
                        self.serverCode = serverCode
                    } else {
                        self.serverCode = String(code)
                    }
                }
        }

    }

    /**
     Check if there is an active network connection for the device
     
     - returns: Network connetion status (Bool)
     */
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    /**
     Checks the network connection and sets the server messages and codes
     
     - return: onCompletion: APIResponse, returns success connected to network or fail and server messages
     */
    func APIServiceCheck(onCompletion: APIResponse) {
        //initialise server code and messages to OK
        self.serverMessage = YonaConstants.serverMessages.OK
        self.serverCode = YonaConstants.serverCodes.OK
        //check for network connection
        guard isConnectedToNetwork() else {
            //if it fails then send messages back saying no connection
            onCompletion(false, YonaConstants.serverMessages.noConnection, YonaConstants.serverCodes.noConnection)
            return
        }
        //if not then return success
        onCompletion(true, self.serverMessage, self.serverCode)
    }

}