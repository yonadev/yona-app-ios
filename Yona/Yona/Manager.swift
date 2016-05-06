//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = (Bool, BodyDataDictionary?, NSError?) -> Void
typealias APIResponse = (Bool, ServerMessage?, ServerCode?) -> Void
typealias APIPinResetResponse = (Bool, PinCode?, ServerMessage?, ServerCode?) -> Void
typealias APIGetDeviceResponse = (Bool, ServerMessage?, ServerCode?, AddDeviceCode?) -> Void
typealias APIGoalSizeResponse = (Int) -> Void
typealias APIActivityLinkResponse = (Bool, String?, ServerMessage?, ServerCode?) -> Void
typealias APIUserResponse = (Bool, ServerMessage?, ServerCode?, Users?) -> Void
typealias APIGoalResponse = (Bool, ServerMessage?, ServerCode?, Goal?, Array<Goal>?, NSError?) -> Void
typealias APIActivitiesArrayResponse = (Bool, ServerMessage?, ServerCode?, Array<Activities>?, NSError?) -> Void
typealias APIActivityResponse = (Bool, ServerMessage?, ServerCode?, Activities?, NSError?) -> Void
typealias NSURLRequestResponse = (Bool, ServerMessage?, ServerCode?, NSURLRequest?, NSError?) -> Void

struct requestResult {
    var success: Bool
    var errorMessage: String?
    var errorCode: String?
    var serverMessage: String?
    var serverCode: String?
    
    init(success: Bool, errorMessage: String, errorCode: String?, serverMessage: String?, serverCode: String?)
    {
        self.success = success
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.serverMessage = serverMessage
        self.serverCode = serverCode
    }
}

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:BodyDataDictionary = [:]

    private override init() {
        print("Only initialised once only")
    }
    /**
     Helper method to create an NSURLRequest with it's required httpHeader, httpBody and the httpMethod request and return it to be executed
     
     - parameter path: String,
     - parameter body: BodyDataDictionary?,
     - parameter httpHeader: [String:String],
     - parameter httpMethod: httpMethods
     - parameter NSURLRequest, the request created to be executed by makeRequest
     */
    func setupRequest(path: String, body: BodyDataDictionary?, httpHeader: [String:String], httpMethod: httpMethods) throws -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]
        

        if let body = body {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        }
    
        request.timeoutInterval = 2
        
        request.HTTPMethod = httpMethod.rawValue
        
        return request
    }
    
}

//MARK: - User Manager methods
extension Manager {
    
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse)
    {
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil{
                    onCompletion(false, nil, error)
                    return
                }
                if response != nil{
                    if data != nil{
                        do{
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(jsonData as? BodyDataDictionary, error: error)
                            if requestResult.success == false{
                                //This passes back the errors we retrieve, looks in the different optionals which may or may not be nil
                                let userInfo = [
                                    NSLocalizedDescriptionKey: requestResult.serverMessage ?? requestResult.errorMessage ??  "Unknown Error"
                                ]
                      //          [NSLocalizedDescriptionKey: requestResult.serverMessage ?? requestResult.serverCode ?? requestResult.errorMessage ?? requestResult.errorCode ?? "Unknown Error"]
                                let yonaError = NSError(domain: requestResult.serverCode ?? requestResult.errorCode ?? "None", code: 600, userInfo: userInfo)
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, yonaError)
                            }
                        } catch let error as NSError{
                            onCompletion(false, nil, error)
                            return
                        }
                        
                    }
                }
            })
            task.resume()
        } catch let error as NSError{
            onCompletion(false, nil, error)
            
        }
    }
    
    /**
     This is a generic method that can make any request to YONA's API. It creates a request with the given parameters and an NSURLSession, then executes the session and gets the responses passing it back as a dictionary and a success or fail of the operation. The body is optional as some request do not require it.
     
     - parameter path: String, The required path to the API service that the user wants to access
     - parameter body: BodyDataDictionary?, The data dictionary of [String: AnyObject] type
     - parameter httpMethod: httpMethods, the http methods that you can do on the API stored in the enum
     - parameter httpHeader:[String:String], the header set to a JSON type
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func makeRequestOLD(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        
        APIServiceManager.sharedInstance.APIServiceCheck { (success, message, code) in
            if success {
                do {
                    let request = try self.setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
                    //execute our session
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                        if let response = response,
                            let httpResponse = response as? NSHTTPURLResponse {
                            //get the code of the response so we can notify the APIServices
                            let code = httpResponse.statusCode
                            do {
                                //try to create json object from the data returned
                                if let data = data where data.length != 0 {
                                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)

                                    if case responseCodes.ok200.rawValue ... responseCodes.ok399.rawValue = code { // successful you get 200 to 204 back, anything else...Houston we gotta a problem
                                        if let dict = jsonObject as? [String: AnyObject] {
                                            APIServiceManager.sharedInstance.setServerCodeMessage(dict, error: error)
                                            onCompletion(true, dict , nil)
                                        }
                                    } else {
                                        if let dict = jsonObject as? [String: AnyObject] {
                                            APIServiceManager.sharedInstance.setServerCodeMessage(dict, error: error)
                                            onCompletion(false, dict, error)
                                        }
                                    }
                                } else {
                                    APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                                    onCompletion(true, nil, error)
                                }
                            } catch let error as NSError { //if serialisation fails send back messages saying so
                                APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                                onCompletion(false, nil, error)
                            }
                        } else {
                            APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                            onCompletion(false, nil, error)
                        }
                    })
                    task.resume()
                } catch let error as NSError {
                    APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                    onCompletion(false, nil, error)
                }
            } else {
                APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: NSError.init(domain: message!, code: 400, userInfo: nil))
                onCompletion(false, nil, NSError.init(domain: message!, code: 400, userInfo: nil))
            }
        }
    }
}