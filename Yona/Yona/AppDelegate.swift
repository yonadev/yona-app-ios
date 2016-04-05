//
//  AppDelegate.swift
//  Yona
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        hockeyAppSetup()

        return true
    }

    private func hockeyAppSetup() {
        var keys: NSDictionary?
        
        if let path = NSBundle.mainBundle().pathForResource("SecretKeys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        } else {
            assertionFailure("You need the SecretKeys.plist file")
        }
        
        if let dict = keys {
            let secretKey = dict["hockeyapp"] as! String
            
            BITHockeyManager.sharedHockeyManager().configureWithIdentifier(secretKey)
            // Do some additional configuration if needed here
            BITHockeyManager.sharedHockeyManager().testIdentifier()
            BITHockeyManager.sharedHockeyManager().startManager()
            BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        }
    }

}

