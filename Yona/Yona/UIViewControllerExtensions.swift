//
//  Extensions.swift
//  Yona
//
//  Created by Alessio Roberto on 04/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

typealias DisplayAlertResponse = (alertButtonType) -> Void

extension UIViewController {
    func resetTheView(position: CGFloat, scrollView: UIScrollView, view: UIView) -> CGFloat? {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
        if (position > 0) {
            view.frame.origin.y += position
            return 0.0
        }
        
        return nil
    }
    
    /**
     Extends functionality of viewcontroller so that a message can be displayed, also defines action to happen on OK (to go back to previous view if on detailview, when there is not network connection
     - parameter alertTitle:String title of message
     - parameter alertDescription:String detailed message description
     - return none
     */
    func displayAlertMessage(alertTitle:String, alertDescription:String) -> Void {
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    /**
     Extends functionality of viewcontroller so that a message can be displayed, also defines action to happen on OK (to go back to previous view if on detailview, when there is not network connection
     - parameter alertTitle:String title of message
     - parameter alertDescription:String detailed message description
     - parameter userData: BodyDataDictionary? Optional data of the user that is trying to be posted
     - return none
     */
    func displayAlertOption(alertTitle:String, alertDescription:String, onCompletion: DisplayAlertResponse) -> Void {
        if #available(iOS 8.0, *) {
            let errorAlert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                onCompletion(alertButtonType.OK)
                return
            }
            
            let CANCELAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                onCompletion(alertButtonType.cancel)
                return
            }
            errorAlert.addAction(OKAction)
            errorAlert.addAction(CANCELAction)

            self.presentViewController(errorAlert, animated: true) {
                return
            }

        } else {
            // Fallback on earlier versions
        }
        return
    }
}

func setViewControllerToDisplay(value: String, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(value, forKey: key)
    defaults.synchronize()
}


func getViewControllerToDisplay(key: String)-> AnyObject? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    if (defaults.objectForKey(key) == nil) && (key == YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
        setViewControllerToDisplay("WalkThrough",key: key)
    }
    return defaults.objectForKey(key)
}

func setTimeBucketTabToDisplay(value: String, key: String) {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(value, forKey: key)
    defaults.synchronize()
}

func getTimeBucketToDisplay(key: String)-> AnyObject? {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.objectForKey(key)
    return defaults.objectForKey(key)
}