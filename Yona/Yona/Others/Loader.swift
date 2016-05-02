//
//  Loader.swift
//  Yona
//
//  Created by Chandan on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class Loader:  NSObject {
    
    class func Show(message:String = "loading...",delegate:UIViewController){
        var load : MBProgressHUD = MBProgressHUD()
        load = MBProgressHUD.showHUDAddedTo(delegate.view, animated: true)
        load.mode = MBProgressHUDMode.Indeterminate
        load.label.text = message;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    class func Hide(delegate:UIViewController){
        MBProgressHUD.hideHUDForView(delegate.view, animated: true)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    
    class func Show(message:String = "loading..."){
        var load : MBProgressHUD = MBProgressHUD()
        load = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow!, animated: true)
        load.mode = MBProgressHUDMode.Indeterminate
        load.label.text = message;
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    class func Hide(){
        MBProgressHUD.hideHUDForView(UIApplication.sharedApplication().keyWindow!, animated: true)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
