//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias budgetGoals = Array<Goal>?
typealias timezoneGoals = Array<Goal>?
typealias nogoGoals = Array<Goal>?


typealias APIMobileConfigResponse = (Bool, NSData?, ServerCode?) -> Void

typealias APIServiceResponse = (Bool, BodyDataDictionary?, NSError?) -> Void
typealias APIResponse = (Bool, ServerMessage?, ServerCode?) -> Void
typealias APICommentResponse = (Bool, Comment?, Array<Comment>?, ServerMessage?, ServerCode?) -> Void
typealias APIPinResetResponse = (Bool, PinCode?, ServerMessage?, ServerCode?) -> Void
typealias APIGetDeviceResponse = (Bool, ServerMessage?, ServerCode?, AddDeviceCode?) -> Void
typealias APIGoalSizeResponse = (Int) -> Void
typealias APIActivityLinkResponse = (Bool, String?, ServerMessage?, ServerCode?) -> Void
typealias APIUserResponse = (Bool, ServerMessage?, ServerCode?, Users?) -> Void
typealias APIGoalResponse = (Bool, ServerMessage?, ServerCode?, Goal?, Array<Goal>?, NSError?) -> Void
typealias APIActivitiesArrayResponse = (Bool, ServerMessage?, ServerCode?, Array<Activities>?, NSError?) -> Void
typealias APIActivityResponse = (Bool, ServerMessage?, ServerCode?, Activities?, NSError?) -> Void
typealias APIActivityApps = (Bool, ServerMessage?, ServerCode?, String?, NSError?) -> Void
typealias APIActivityGoalResponse = (Bool, ServerMessage?, ServerCode?, [DayActivityOverview]?, NSError?) -> Void
typealias APIActivityWeekResponse = (Bool, ServerMessage?, ServerCode?, [WeekActivityGoal]?, NSError?) -> Void

typealias APIActivityWeekDetailResponse = (Bool, ServerMessage?, ServerCode?, WeekSingleActivityDetail?, NSError?) -> Void
typealias APIActivityDayDetailResponse = (Bool, ServerMessage?, ServerCode?, DaySingleActivityDetail?, NSError?) -> Void

typealias APIActivitiesGoalsArrayResponse = (Bool, ServerMessage?, ServerCode?, Array<Activities>?, Array<Goal>?, NSError?) -> Void
typealias APIActivitiesGoalsExcludeArrayResponse = (Bool, ServerMessage?, ServerCode?, Array<Activities>?,Array<Activities>?,Array<Activities>?, Array<Goal>?, NSError?) -> Void

typealias APIMessageResponse = (Bool, ServerMessage?, ServerCode?, Message?, Array<Message>?) -> Void
typealias APIBuddiesResponse = (Bool, ServerMessage?, ServerCode?, Buddies?, Array<Buddies>?) -> Void
typealias NSURLRequestResponse = (Bool, ServerMessage?, ServerCode?, NSURLRequest?, NSError?) -> Void
typealias SortedGoals = (Bool, budgetGoals , timezoneGoals, nogoGoals) -> Void

typealias APIActivityTimeLineResponse = (Bool, ServerMessage?, ServerCode?, [TimeLineDayActivityOverview]?, NSError?) -> Void

typealias APITimeLineUserGoalsRespons = (Bool) -> Void

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
        let urlString = path.hasPrefix(EnvironmentManager.baseUrlString()) ? path : EnvironmentManager.baseUrlString() + path
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]

        if let body = body {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        }
    
        request.timeoutInterval = 30
        
        request.HTTPMethod = httpMethod.rawValue
        
        return request
    }
    
}

//MARK: - User Manager methods
extension Manager {
    
    /**
     This is a generic method that can make any request to YONA API. It creates a request with the given parameters and an NSURLSession, then executes the session and gets the responses passing it back as a dictionary and a success or fail of the operation. The body is optional as some request do not require it.
     
     - parameter path: String, The required path to the API service that the user wants to access
     - parameter body: BodyDataDictionary?, The data dictionary of [String: AnyObject] type
     - parameter httpMethod: httpMethods, the http methods that you can do on the API stored in the enum
     - parameter httpHeader:[String:String], the header set to a JSON type
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse)
    {
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil{
                    dispatch_async(dispatch_get_main_queue()) {
                        onCompletion(false, nil, error)
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.length > 0{ //don't try to parse 0 data, even tho it isn't nil
                        do{
                            
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            print(jsonData)
                            let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(jsonData  as? BodyDataDictionary, error: error)
                            let userInfo = [
                                NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                            ]
                            let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, omdbError)
                            }
                        } catch let error as NSError{
                            dispatch_async(dispatch_get_main_queue()) {
                                onCompletion(false, nil, error)
                                return
                            }
                        }
                    } else {
                        let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                        //This passes back the errors we retrieve, looks in the different optionals which may or may not be nil
                        let userInfo = [
                            NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                        ]
                        let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                        dispatch_async(dispatch_get_main_queue()) {
                            onCompletion(requestResult.success, nil, omdbError)
                        }
                    }
                }
            })
            task.resume()
        } catch let error as NSError{
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(false, nil, error)
            }
            
        }
    }


    func makeFileRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIMobileConfigResponse)
        
    {
        
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil{
                    dispatch_async(dispatch_get_main_queue()) {
                        onCompletion(false, nil, "")
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.length > 0{ //don't try to parse 0 data, even tho it isn't nil
                            dispatch_async(dispatch_get_main_queue()) {
                                onCompletion(true, data , "")
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            onCompletion(false, nil, "")
                        }
                    }
                }
            })
            task.resume()
        } catch _ as NSError{
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(false, nil, "")
            }
            
        }
    }

}
