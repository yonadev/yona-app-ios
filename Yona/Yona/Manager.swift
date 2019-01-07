 //
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias budgetGoals = Array<Goal>?
typealias timezoneGoals = Array<Goal>?
typealias nogoGoals = Array<Goal>?


typealias APIMobileConfigResponse = (Bool, Data?, ServerCode?) -> Void

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
typealias NSURLRequestResponse = (Bool, ServerMessage?, ServerCode?, URLRequest?, NSError?) -> Void
typealias SortedGoals = (Bool, budgetGoals , timezoneGoals, nogoGoals) -> Void

typealias APIActivityTimeLineResponse = (Bool, ServerMessage?, ServerCode?, [TimeLineDayActivityOverview]?, NSError?) -> Void

typealias APITimeLineUserGoalsRespons = (Bool) -> Void

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:BodyDataDictionary = [:]

    fileprivate override init() {
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
    func setupRequest(_ path: String, body: BodyDataDictionary?, httpHeader: [String:String], httpMethod: httpMethods) throws -> URLRequest {
        let urlString = path.hasPrefix(EnvironmentManager.baseUrlString()) ? path : EnvironmentManager.baseUrlString() + path
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]

        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions(rawValue: 0))
        }
    
        request.timeoutInterval = 30
        
        request.httpMethod = httpMethod.rawValue
        
        return request as URLRequest
    }

    
    /**
     Helper method to create an NSURLRequest with it's required httpHeader, httpBody and the httpMethod request and return it to be executed
     
     - parameter path: String,
     - parameter body: NSData,
     - parameter httpHeader: [String:String],
     - parameter httpMethod: httpMethods
     - parameter NSURLRequest, the request created to be executed by makeRequest
     */
    func setupDataRequest(_ path: String, body: Data?, httpHeader: [String:String], httpMethod: httpMethods) throws -> URLRequest {
        let urlString = path.hasPrefix(EnvironmentManager.baseUrlString()) ? path : EnvironmentManager.baseUrlString() + path
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]
        
        if let body = body {
            request.httpBody = body
        }
        
        request.timeoutInterval = 30
        
        request.httpMethod = httpMethod.rawValue
        
        return request as URLRequest
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
    func makeRequest(_ path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: @escaping APIServiceResponse)
    {
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async {
                        onCompletion(false, nil, error as NSError?)
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.count > 0{ //don't try to parse 0 data, even tho it isn't nil
                        do{
                            
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            print(jsonData)
                            let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(jsonData  as? BodyDataDictionary, response: response as? HTTPURLResponse, error: error as NSError?)
                            let userInfo = [
                                NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                            ]
                            let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                            
                            DispatchQueue.main.async {
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, omdbError)
                            }
                        } catch let error as NSError{
                            DispatchQueue.main.async {
                                onCompletion(false, nil, error)
                                return
                            }
                        }
                    } else {
                        let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(nil, response: response as? HTTPURLResponse, error: error as NSError?)
                        //This passes back the errors we retrieve, looks in the different optionals which may or may not be nil
                        let userInfo = [
                            NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                        ]
                        let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                        DispatchQueue.main.async {
                            onCompletion(requestResult.success, nil, omdbError)
                        }
                    }
                }
            })
            task.resume()
        } catch let error as NSError{
            DispatchQueue.main.async {
                onCompletion(false, nil, error)
            }
            
        }
    }


    func makeFileUpload(_ path: String, file: UIImage, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: @escaping APIMobileConfigResponse)
        
    {
        
        do{
            
            var headers: [String: String] = [:]
            headers["Content-Type"] = "multipart/form-data; boundary=\(generateBoundaryString())"
            
            httpHeader.forEach { (k,v) in headers[k] = v }
            
            let data = multipartDataFromFile(file)
            let request = try setupDataRequest(path, body: data, httpHeader: headers, httpMethod: httpMethod)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async {
                        onCompletion(false, nil, "")
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.count > 0{ //don't try to parse 0 data, even tho it isn't nil
                        DispatchQueue.main.async {
                            onCompletion(true, data , "")
                        }
                    } else {
                        DispatchQueue.main.async {
                            onCompletion(false, nil, "")
                        }
                    }
                }
            })
            task.resume()
        } catch _ as NSError{
            DispatchQueue.main.async {
                onCompletion(false, nil, "")
            }
            
        }
    }

    
    
    func makeFileRequest(_ path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: @escaping APIMobileConfigResponse)
        
    {
        
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil{
                    DispatchQueue.main.async {
                            onCompletion(false, nil, error?.localizedDescription)
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.count > 0{ //don't try to parse 0 data, even tho it isn't nil
                            DispatchQueue.main.async {
//                                NSLog("-----------------------------YONA")
//                                NSLog("makeFileRequest : data size %f", data!.length)

//                                onCompletion(true, data , "")
                        onCompletion(true, data , "")

                        }
                    } else {
                        DispatchQueue.main.async {
                                onCompletion(false, nil, "File downloaded was empty")
                            
                        }
                    }
                }
            })
            task.resume()
        } catch _ as NSError{
            DispatchQueue.main.async {
                onCompletion(false, nil, "")
            }
            
        }
    }

    fileprivate func multipartDataFromFile(_ img: UIImage) -> Data {
        let body = NSMutableData()
        

        let mimetype = "image/*"
        let boundary = generateBoundaryString()
        guard let image_data = img.pngData() else {
            return Data()
        }
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

        return body as Data
    }
    
    func generateBoundaryString() -> String
    {
        return "--gc0p4Jq0M2Yt08jU534c0p--"
    }

}
