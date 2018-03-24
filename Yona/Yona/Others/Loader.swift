//
//  Loader.swift
//  Yona
//
//  Created by Chandan on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class Loader:  NSObject {
    
    
    class func setup()
    {
        SVProgressHUD.setDefaultMaskType(.Black)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.7))
        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        
    }
    
    class func Show(message:String = "loading..."){
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showWithStatus(message)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        })
        
        
    }
    
    class func Hide(){
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.dismiss()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}
