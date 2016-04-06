//
//  APILoginManager.swift
//  Yona
//
//  Created by Ben Smith on 30/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = (UserData?, NSError?) -> Void
typealias APIResponse = (Bool) -> Void

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    private var userInfo:UserData = [:]
    
    private override init() {
        print("Only initialised once only")
    }
    
    private func setupRequest(path: String, body: UserData?, httpHeader: [String:String], httpMethod: String) -> NSURLRequest {
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
    
    func makeUserRequest(path: String, body: UserData?, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let request = setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let dict = jsonObject as? [String: AnyObject] {
                    if dict.count == 2 { //we get a response of 2 items if there is nothing returned
                        onCompletion(nil, nil)
                    } else {
                        self.userInfo = dict
                        if let code = dict["mobileNumberConfirmationCode"] { print(">>>>>>>>>>>> SMS Confimation code: " + "\(code)" + "<<<<<<<<<<<<<") }
                        onCompletion(dict, nil)
                    }
                }
            } catch {
                print("error serializing JSON: \(error)")
                onCompletion(nil, nil)
            }
        })
        task.resume()
    }
    
    func makeRequest(path: String, body: UserData?, httpMethod: String, httpHeader:[String:String], onCompletion: APIResponse){
        let request = setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let response = response, let httpResponse = response as? NSHTTPURLResponse {
                let code = httpResponse.statusCode
                if(code == 200) { // successful you get 200 back, anything else...Houston we gotta a problem
                    onCompletion(true)
                } else {
                    do {
                        let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        print(jsonObject)
                        if let error = error {
                            print(error.description)
                        }
                    } catch {
                    }
                    onCompletion(false)
                }
            }
            
        })
        task.resume()
    }

}