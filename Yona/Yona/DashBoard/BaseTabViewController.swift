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
    }
    
    override func viewDidAppear(animated: Bool) {
        if let viewControllerName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
            self.view.window?.rootViewController?.presentViewController(getScreen(viewControllerName), animated: false, completion: nil)
        }
    }

    /* This method returns the view controller we ask for as a string
     
     - parameter viewControllerName: String, this is the name the view controller we want to display
     - return UIViewController, UIViewController instance returned according to the parameter passed in
     */
    func getScreen(viewControllerName: String) -> UIViewController{
        var rootController: UIViewController!
        
        switch viewControllerName {
        case ViewControllerTypeString.smsValidation.rawValue:
            rootController = R.storyboard.sMSValidation.sMSValidationViewController
        case ViewControllerTypeString.passcode.rawValue:
            rootController = R.storyboard.passcode.passcodeStoryboard
        case ViewControllerTypeString.login.rawValue:
            rootController = R.storyboard.login.loginStoryboard
        case ViewControllerTypeString.welcome.rawValue:
            rootController = R.storyboard.welcome.welcomeStoryboard
        case ViewControllerTypeString.dashboard.rawValue:
            rootController = R.storyboard.dashboard.initialViewController
            
        default:
            rootController = R.storyboard.welcome.welcomeStoryboard
            
        }
        return rootController
    }

    func presentLoginScreen() {
        self.presentViewController(R.storyboard.login.initialViewController!, animated: false) {
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
