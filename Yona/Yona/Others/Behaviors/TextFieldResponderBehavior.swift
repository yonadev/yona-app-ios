//
//  TextfieldBehavior.swift
//  ConsumerApp
//
//  Created by Adriana Ormaetxea Arregi on 20/10/15.
//  Copyright © 2015 Adriana Ormaetxea Arregi. All rights reserved.
//

import Foundation
import UIKit

public class TextFieldResponderBehavior : Behavior {
    
    @IBOutlet weak var textField: UITextField? {
        willSet {
            textField?.removeTarget(self, action:
                #selector(TextFieldResponderBehavior.b_textFieldShouldReturn),
                forControlEvents: .EditingDidEndOnExit
            )
        }
        
        didSet {
            textField?.addTarget(self, action:
                #selector(TextFieldResponderBehavior.b_textFieldShouldReturn),
                forControlEvents: .EditingDidEndOnExit
            )
        }
    }
    
    @IBOutlet weak var nextTextField: UITextField?
    
    func b_textFieldShouldReturn() {
        nextTextField?.becomeFirstResponder()
    }
}