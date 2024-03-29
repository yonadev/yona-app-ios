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
    
    fileprivate init() {}
    
    
    /**
     Calls the manager to make a standard http request using the httpHeader json type, this requires the users password that is stored in the keychain:
     ["Content-Type": "application/json", "Yona-Password": yonaPassword]
     
     - parameter body: BodyDataDictionary?, the body of the req uest required by some calls, can be nil
     - parameter path: String, the path to the API service call
     - parameter httpMethod: httpMethods, the httpmethod enum (post, get , put, delete)
     - parameter onCompletion:APIMobileConfigResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func uploadPhoto(_ img: UIImage, path: String, httpMethod: httpMethods, onCompletion:@escaping APIMobileConfigResponse){
        
        
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        let countryId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let language = "\(langId)-\(countryId)"
        
        
        var httpHeader = ["Accept-Language": language]
        
        if let yonaPassword = KeychainManager.sharedInstance.getYonaPassword() {
            httpHeader = ["Accept-Language": language, "Yona-Password": yonaPassword]
        }
        
        
        Manager.sharedInstance.makeFileUpload(path, file: img, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: onCompletion)
    }

    
    
    /**
     Calls the manager to make a standard http request using the httpHeader json type, this requires the users password that is stored in the keychain:
        ["Content-Type": "application/json", "Yona-Password": yonaPassword]
     
     - parameter body: BodyDataDictionary?, the body of the req uest required by some calls, can be nil
     - parameter path: String, the path to the API service call
     - parameter httpMethod: httpMethods, the httpmethod enum (post, get , put, delete)
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func callRequestWithAPIServiceResponse(_ body: BodyDataDictionary?, path: String, httpMethod: httpMethods, onCompletion:@escaping APIServiceResponse){
        
        
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        let countryId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let language = "\(langId)-\(countryId)"
        
        
        var httpHeader = ["Content-Type": "application/json", "Accept-Language": language]
        
        if let yonaPassword = KeychainManager.sharedInstance.getYonaPassword() {
            httpHeader = ["Content-Type": "application/json", "Accept-Language": language, "Yona-Password": yonaPassword]
        }
        
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: onCompletion)
    }

    func callRequestWithAPIMobileConfigResponse(_ body: BodyDataDictionary?, path: String, httpMethod: httpMethods, onCompletion:@escaping APIMobileConfigResponse){
        
        guard let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword() else {
//            NSLog("-----------------------------YONA")
//            NSLog("callRequestWithAPIMobileConfigResponse : NO USER PASSWORD")
            onCompletion(false,nil, "")
            return
        }
        
        let langId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
        let countryId = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let language = "\(langId)-\(countryId)"
        
        let httpHeader = ["Content-Type": "application/json", "Accept-Language": language, "Yona-Password": yonaPassword]
        Manager.sharedInstance.makeFileRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: onCompletion)
    }

    
    /**
     Setups up the messages from the server so the UI knows what is going wrong or right
     
     - parameter json:BodyDataDictionary?, the body of the messages from server, if there is an error then there is a message or code key in response
     - parameter error: NSError?, the http response code we need to check (200-204 success, other is fail
     - return requestResult A struct used for error requests containing our codes and messages of the error
     */
    func setServerCodeMessage(_ json:BodyDataDictionary?, response: HTTPURLResponse? ,error: NSError?) -> requestResult{
        //If there is a json response and we have the key Error then we know there is and
        if (response?.statusCode)! <= responseCodes.ok299.rawValue {
            return requestResult.init(isSuccess: true, errorMessage: responseMessages.success.rawValue, errorCode: responseCodes.ok200.rawValue, domain: errorDomains.successDomain.rawValue)
        } else if let jsonUnwrapped = json, let message = jsonUnwrapped[YonaConstants.serverResponseKeys.message] as? String, let serverCode = jsonUnwrapped[YonaConstants.serverResponseKeys.code] as? String{
            return requestResult.init(isSuccess: false, errorMessage: message, errorCode: responseCodes.yonaErrorCode.rawValue, domain: serverCode)
        } else if let error = error {
            //for any error between 500 to 599 return server problem, else return network error
            if case responseCodes.serverProblem500.rawValue ... responseCodes.serverProblem599.rawValue = error.code {
                return requestResult.init(isSuccess: false, errorMessage: responseMessages.serverProblem.rawValue, errorCode: error.code, domain: errorDomains.networkErrorDomain.rawValue)
            } else {
                //if there is possibly any other just return the systems error
                return requestResult.init(isSuccess: false, errorMessage: responseMessages.networkConnectionProblem.rawValue, errorCode: error.code, domain: errorDomains.networkErrorDomain.rawValue)
            }
        }
        return requestResult.init(isSuccess: false, errorMessage: responseMessages.YonaError.rawValue, errorCode: (response?.statusCode)!, domain: errorDomains.yonaErrorDomain.rawValue)
    }
    
    

    /**
     This determines the title of the error from the error code so the user is presented this in a friendly way
     
     - parameter error: NSError? the error object
     - return The error string from the error code, this will either be a Yona error, so something failed on their side to do with the requets or a network problem
     */
    func determineErrorCode(_ error: NSError?) -> String {
        var errorString = ""
        if case responseCodes.yonaErrorCode.rawValue = error!.code {
            //if we have a yona error then it's error code string will be it's domain which is passed back from YONA and is used to determine how UI works
            errorString = (error?.domain)!
        } else if case responseCodes.internalErrorCode.rawValue = error!.code {
            errorString = responseMessages.internalErrorMessage.rawValue
        } else if case responseCodes.connectionFail400.rawValue ... responseCodes.serverProblem599.rawValue = error!.code {
            errorString = responseMessages.networkConnectionProblem.rawValue
        } else if case -1103 ... -998 = error!.code {
            errorString = responseMessages.networkConnectionProblem.rawValue
        }else {
            errorString = responseMessages.success.rawValue
        }
        return errorString
    } 
}
