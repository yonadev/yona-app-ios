//
//  DashboardNavigationViewController.swift
//  Yona
//
//  Created by Ahmed Ali on 13/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class DashboardNavigationViewController: UINavigationController, UITabBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(false, animated: false)
        let storyboard = UIStoryboard(name: self.title!, bundle: NSBundle.mainBundle())
        self.viewControllers = [storyboard.instantiateInitialViewController()!]
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let viewController = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) as? String  where viewController != YonaConstants.screenNames.dashboard {
            self.pushViewController(getScreen(viewController), animated: false)
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item)
    }
    
    
    func getScreen(viewControllerName: String) -> UIViewController{
        var rootController: UIViewController!
        
            switch viewControllerName {
            case YonaConstants.screenNames.smsValidation:
                rootController = R.storyboard.sMSValidation.sMSValidationViewController
            case YonaConstants.screenNames.passcode:
                rootController = R.storyboard.passcode.passcodeStoryboard
            case YonaConstants.screenNames.login:
                rootController = R.storyboard.login.loginStoryboard
            case YonaConstants.screenNames.welcome:
                rootController = R.storyboard.welcome.welcomeStoryboard
            case YonaConstants.screenNames.dashboard:
                rootController = R.storyboard.dashboard.initialViewController
                
            default:
                rootController = R.storyboard.welcome.welcomeStoryboard
                
            }
            return rootController
    }

    /*
    // MARK: - Navigation

}
