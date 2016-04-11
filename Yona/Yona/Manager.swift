//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias APIServiceResponse = (Bool, UserData?, NSError?) -> Void
typealias APIResponse = (Bool) -> Void

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:UserData = [:]

    private override init() {
        print("Only initialised once only")
    }
    
    func setupRequest(path: String, body: UserData?, httpHeader: [String:String], httpMethod: String) -> NSURLRequest {
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