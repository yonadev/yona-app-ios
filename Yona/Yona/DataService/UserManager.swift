//
//  APILoginManager.swift
//  Yona
//
//  Created by Ben Smith on 30/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = ([String: AnyObject]?, NSError?) -> Void
typealias APIResponse = (Bool) -> Void

class UserManager: NSObject {
    static let sharedInstance = UserManager()
    
    private var userInfo:[String: AnyObject] = [:]
    
    private override init() {
        print("Only initialised once only")
    }
    
    func makePostRequest(path: String, password: String, body: [String: AnyObject], onCompletion: APIServiceResponse) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Yona-Password": password]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        } catch {
            print("Error")
        }
        
        request.HTTPMethod = "POST"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let dict = jsonObject as? [String: AnyObject] {
                    self.userInfo = dict
                    onCompletion(dict, nil)
                }
            } catch {
                print("error serializing JSON: \(error)")
                onCompletion(nil, nil)
            }
        })
        task.resume()
    }
    

    func makeDeleteRequest(path: String, password: String, userID: String, onCompletion: APIResponse){
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.allHTTPHeaderFields = ["Content-Type": "application/json", "Yona-Password": password, "id": userID]
        request.HTTPMethod = "DELETE"
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let response = response, let httpResponse = response as? NSHTTPURLResponse {
                let code = httpResponse.statusCode
                if(code == 200) {
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            }
        })
        task.resume()
    }
    
}