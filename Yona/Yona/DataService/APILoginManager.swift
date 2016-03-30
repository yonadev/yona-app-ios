//
//  APILoginManager.swift
//  Yona
//
//  Created by Ben Smith on 30/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = (AnyObject?, NSError?) -> Void

class APILoginManager: NSObject {
    static let sharedInstance = APILoginManager()
    
    let baseURL = "http://85.222.227.142/"
    
    func postUser(onCompletion: (AnyObject) -> Void) {
        let path = baseURL + "users/"
        let body =
            ["firstName": "Richard",
            "lastName": "Quin",
            "mobileNumber": "+31612345678",
            "nickname": "RQ"]
        makePostRequest(path, body: body, onCompletion: { json, err in
            if let JSONObject = json {
                onCompletion(JSONObject as AnyObject)
            }
        })
    }
    
    func makePostRequest(path: String, body: [String: AnyObject], onCompletion: APIServiceResponse) {
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        } catch {
            print("Error")
        }
        
        request.HTTPMethod = "POST"
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())
                onCompletion(jsonObject, error)
            } catch {
                onCompletion(nil, nil)
            }
        })
        task.resume()
    }
}