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
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(UIColor(white: 0, alpha: 0.7))
        SVProgressHUD.setForegroundColor(UIColor(white: 1, alpha: 1))
        
    }
    
    class func Show(_ message:String = "loading..."){
        DispatchQueue.main.async(execute: {
            SVProgressHUD.show(withStatus: message)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        })
        
        
    }
    
    class func Hide(){
        DispatchQueue.main.async(execute: {
            SVProgressHUD.dismiss()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        })
    }
}
