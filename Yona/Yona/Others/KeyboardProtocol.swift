//
//  KeyboardProtocol.swift
//  Yona
//
//  Created by Alessio Roberto on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardProtocol:class {
    var posi:CGFloat {get set}
    
    func keyboardWasShown(notification: NSNotification)
    func keyboardWillBeHidden(notification: NSNotification)
}