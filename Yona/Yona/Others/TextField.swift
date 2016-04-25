//
//  TextField.swift
//  Yona
//
//  Created by Chandan on 25/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func addKeyboardAvoiding()  {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UITextField.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UITextField.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.superview!.frame.origin.y -= keyboardSize.height
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.superview!.frame.origin.y += keyboardSize.height
        }
    }
    
    
    
}