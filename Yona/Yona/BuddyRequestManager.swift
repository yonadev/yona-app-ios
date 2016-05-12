//
//  BuddyRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class BuddyRequestManager {
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    static let sharedInstance = ActivitiesRequestManager()
    
    private init() {}

    func requestNewbuddy(){
        
    }
}