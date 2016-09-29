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
    func displayAlertOption(alertTitle:String, cancelButton: Bool, alertDescription:String, onCompletion: DisplayAlertResponse) -> Void {
        if #available(iOS 8.0, *) {
            let errorAlert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { (action) in
                onCompletion(alertButtonType.OK)
                return
            }
            
            if cancelButton {
                let CANCELAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Default) { (action) in
                    onCompletion(alertButtonType.cancel)
                    return
                }
                errorAlert.addAction(CANCELAction)
            }
            errorAlert.addAction(OKAction)
            

            self.presentViewController(errorAlert, animated: true) {
                return
            }

        } else {
            // Fallback on earlier versions
        }
        return
    }
}