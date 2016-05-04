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
    
    /**
     This is a generic method that can make any request to YONA's API. It creates a request with the given parameters and an NSURLSession, then executes the session and gets the responses passing it back as a dictionary and a success or fail of the operation. The body is optional as some request do not require it.
     
     - parameter path: String, The required path to the API service that the user wants to access
     - parameter body: BodyDataDictionary?, The data dictionary of [String: AnyObject] type
     - parameter httpMethod: httpMethods, the http methods that you can do on the API stored in the enum
     - parameter httpHeader:[String:String], the header set to a JSON type
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        
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
                                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                                print(jsonObject)
                                APIServiceManager.sharedInstance.setServerCodeMessage(jsonObject as? [String: AnyObject], code: httpResponse.statusCode)
                                
                                if case responseCodes.ok200.rawValue ... responseCodes.ok204.rawValue = code { // successful you get 200 to 204 back, anything else...Houston we gotta a problem
                                    if let dict = jsonObject as? [String: AnyObject] {
                                        self.userInfo = dict
                                        onCompletion(true, dict , error)
                                    }
                                } else {
                                    if let dict = jsonObject as? [String: AnyObject] {
                                        onCompletion(false, dict, error)
                                    }
                                }
                            } catch { //if serialisation fails send back messages saying so
                                if case responseCodes.ok200.rawValue ... responseCodes.ok204.rawValue = code {
                                    onCompletion(true, nil, NSError.init(domain: "No Data returned but request succeeded as data body not required", code: code, userInfo: nil))
                                } else {
                                    print("error Code: \(code)")
                                    onCompletion(false, nil, YonaConstants.YonaErrorTypes.JsonObjectSerialisationFail)
                                }
                            }
                        } else {
                            onCompletion(false, nil, error)
                        }
                    })
                    task.resume()
                } catch {
                    onCompletion(false, nil, YonaConstants.YonaErrorTypes.NSURLRequestSetupFail)
                }
            } else {
                onCompletion(false, nil, YonaConstants.YonaErrorTypes.NetworkFail)
            }
        }
    }
}