//
//  BaseTabViewController.swift
//  Yona
//
//  Created by Chandan on 17/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

let selectedTab = "selectedTab"
enum Tab: Int {
    case profile = 0
    case friends = 1
    case challenges = 2
    case settings = 3
}

class BaseTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedIndex()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseTabViewController.presentLoginScreen), name: UIApplicationWillEnterForegroundNotification, object: nil)
        self.presentView()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.presentView()
    }

    
    func presentView(){
        if let viewControllerName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
            let viewControllerToShow = getScreen(viewControllerName)
            
            //if the user is not logged in then show login window
            if !NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isLoggedIn) {
                self.view.window?.rootViewController?.presentViewController(viewControllerToShow, animated: false, completion: nil)
            }
        }
    }
    /* This method returns the view controller we ask for as a string
     
     - parameter viewControllerName: String, this is the name the view controller we want to display
     - return UIViewController, UIViewController instance returned according to the parameter passed in
     */
    func getScreen(viewControllerName: String) -> UIViewController{
        var navController: UINavigationController?
        var rootController: UIViewController?

        switch viewControllerName {
        case ViewControllerTypeString.smsValidation.rawValue:
            rootController = R.storyboard.login.sMSValidationViewController
            navController = R.storyboard.login.initialViewController
            
        case ViewControllerTypeString.passcode.rawValue:
            rootController = R.storyboard.login.passcodeViewController
            navController = R.storyboard.login.initialViewController

        case ViewControllerTypeString.login.rawValue:
            rootController = R.storyboard.login.loginViewController
            navController = R.storyboard.login.initialViewController
            
        case ViewControllerTypeString.welcome.rawValue:
            rootController = R.storyboard.welcome.welcomeViewController
            navController = R.storyboard.welcome.initialViewController

        case ViewControllerTypeString.walkThrough.rawValue:
            rootController = R.storyboard.walkThrough.walkThroughViewController
            navController = R.storyboard.walkThrough.initialViewController
            
        default:
            rootController = R.storyboard.welcome.welcomeViewController
            navController = R.storyboard.welcome.initialViewController
            
        }
        
        if let rootController = rootController {
            navController?.pushViewController(rootController, animated: false)
        }
        return navController ?? rootController!
    }

    func presentLoginScreen() {
        let viewControllerToShow = getScreen(ViewControllerTypeString.login.rawValue)
        self.view.window?.rootViewController?.presentViewController(viewControllerToShow, animated: false) {
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    func updateSelectedIndex() {
        if userHasGaols(){
            self.selectedIndex = Tab.profile.rawValue
        }else{
            self.selectedIndex = Tab.challenges.rawValue
        }
    }
    
    func userHasGaols() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.isGoalsAdded);
    }
}
