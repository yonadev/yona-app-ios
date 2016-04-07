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
        
        var rootController : UINavigationController

        rootController = getScreenNameToDisplay()
        
        if let window = self.window {
            window.rootViewController = rootController
        }
 
        return true
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
//        getScreenNameToDisplay
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

    //MARK: User Methods
    func getScreenNameToDisplay() -> UINavigationController{
        var rootController: UIViewController = UINavigationController.init()
        if let viewName = getViewControllerToDisplay("ScreenToDisplay") as? String {
            switch viewName {
                case "SMSValidation":
                    rootController = R.storyboard.sMSValidation.sMSValidationViewController! as SMSValidationViewController
                case "Passcode":
                    rootController = R.storyboard.passcode.passcodeStoryboard! as SetPasscodeViewController
                case "Login":
                    rootController = R.storyboard.login.loginStoryboard! as LoginViewController
                default:
                    rootController = R.storyboard.welcome.welcomeStoryboard! as WelcomeViewController
                }
            return UINavigationController(rootViewController: rootController)
        }
        return UINavigationController(rootViewController: rootController)
    }
}

