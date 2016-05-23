//
//  AppDelegate.swift
//  Yona
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var rootController : UINavigationController
        rootController = getScreenNameToDisplay()
        if let window = self.window {
            window.backgroundColor = UIColor.whiteColor()
            window.rootViewController = rootController
        }
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
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
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: User Methods
    func getScreenNameToDisplay() -> UINavigationController{
        var rootController: UIViewController = UINavigationController.init()
        if let viewName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) as? String {
            switch viewName {
            case YonaConstants.screenNames.smsValidation:
                rootController = R.storyboard.sMSValidation.sMSValidationViewController! as LoginSignupValidationMasterView
            case YonaConstants.screenNames.passcode:
                rootController = R.storyboard.passcode.passcodeStoryboard! as SetPasscodeViewController
            case YonaConstants.screenNames.login:
                rootController = R.storyboard.login.loginStoryboard! as LoginViewController
            case YonaConstants.screenNames.welcome:
                rootController = R.storyboard.welcome.welcomeStoryboard! as WelcomeViewController
                
            default:
                rootController = R.storyboard.walkThrough.walkThroughStoryboard! as WalkThroughViewController
            }
            return UINavigationController(rootViewController: rootController)
        }
        return UINavigationController(rootViewController: rootController)
    }
}
