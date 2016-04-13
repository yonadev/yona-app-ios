//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = (Bool, BodyDataDictionary?, NSError?) -> Void
typealias APIResponse = (Bool) -> Void
typealias APIGoalResponse = (Bool, BodyDataDictionary?, Goal?, NSError?) -> Void
typealias APIGoalArrayResponse = (Bool, BodyDataDictionary?, Array<Goal>?) -> Void
typealias APIActivitiesArrayResponse = (Bool, BodyDataDictionary?, Array<Activities>?) -> Void
typealias APIActivityResponse = (Bool, BodyDataDictionary?, Activities?, NSError?) -> Void

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:BodyDataDictionary = [:]

    private override init() {
        print("Only initialised once only")
    }
    
    func setupRequest(path: String, body: BodyDataDictionary?, httpHeader: [String:String], httpMethod: String) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]
        do {
            if let body = body {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
            }
        } catch {
            print("Error")
        }
        
        request.HTTPMethod = httpMethod
        
        return request
    }
    
}

//MARK: - User Manager methods
extension Manager {
    
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse){
        let request = setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let response = response, let httpResponse = response as? NSHTTPURLResponse {
                let code = httpResponse.statusCode
                do {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    print(jsonObject)

                    if case YonaConstants.responseCodes.ok200 ... YonaConstants.responseCodes.ok204 = code { // successful you get 200 to 204 back, anything else...Houston we gotta a problem
                        if let dict = jsonObject as? [String: AnyObject] {
                            self.userInfo = dict
                            onCompletion(true, dict , error)
                        }
                    } else {
                        print("error Code: \(code)")
                        print("error Code: \(code)")
                        if let dict = jsonObject as? [String: AnyObject] {
                            onCompletion(false, dict, error)
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                    if case YonaConstants.responseCodes.ok200 ... YonaConstants.responseCodes.ok204 = code {
                        onCompletion(true, [:], nil)
                    } else {
                        print("error Code: \(code)")
                        onCompletion(false, [:], nil)
                        
                    }
                }
            }
        })
        task.resume()
    }
    
}