//
//  APILoginManager.swift
//  Yona
//
//  Created by Ben Smith on 30/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

extension Manager {

    func makeUserRequest(path: String, body: UserData?, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse) {
        let request = setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let dict = jsonObject as? [String: AnyObject] {
                    if dict.count == 2 { //we get a response of 2 items if there is nothing returned
                        onCompletion(false, dict, nil)
                    } else {
                        self.userInfo = dict
                        #if DEBUG
                        print(">>>>>>>>>>>> SMS Confimation code: " + "(1234)" + "<<<<<<<<<<<<<")
                        #endif
                        onCompletion(true, dict, nil)
                    }
                }
            } catch {
                print("error serializing JSON: \(error)")
                onCompletion(false, [:], nil)
            }
        })
        task.resume()
    }
    
    func makeRequest(path: String, body: UserData?, httpMethod: String, httpHeader:[String:String], onCompletion: APIServiceResponse){
        let request = setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if let response = response, let httpResponse = response as? NSHTTPURLResponse {
                let code = httpResponse.statusCode
                do {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    print(jsonObject)
                    if let error = error {
                        print(error.description)
                    }
                    
                    if(code == 200) { // successful you get 200 back, anything else...Houston we gotta a problem
                        if let dict = jsonObject as? [String: AnyObject] {
                            onCompletion(true, dict , error)
                        }
                    } else {
                        if let dict = jsonObject as? [String: AnyObject] {
                            onCompletion(false, dict, error)
                        }
                    }
                } catch {
                    if(code == 200) {
                        onCompletion(true, [:], nil)
                    } else {
                        onCompletion(false, [:], nil)

                    }
                }
                

            }
            
        })
        task.resume()
    }

}