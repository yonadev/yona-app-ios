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
        
        //ADDing the nav bar programitcally to overcome problems with navbar
        //DashBoard
        
        var  controller = viewControllers
        let storyBoard: UIStoryboard = UIStoryboard(name:"MeDashBoard", bundle: Bundle.main)
        let navi = storyBoard.instantiateViewController(withIdentifier: "DashBoardMainNavigationController") as! UINavigationController
        navi.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "icnMe"),
            tag: 1)
        navi.tabBarItem.selectedImage = UIImage(named: "icnMeActive")
        navi.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        controller![0] = navi
        setViewControllers(controller, animated: false)

        
        updateSelectedIndex()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseTabViewController.presentLoginScreen), name: UIApplication.willEnterForegroundNotification, object: nil)
        self.presentView()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentView()
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn) && !UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted) {
            if let navController : UINavigationController = R.storyboard.vpnFlow.vpnNavigationController(()) {
                navController.modalPresentationStyle = UIModalPresentationStyle.currentContext
                DispatchQueue.main.async(execute: {
                    self.present(navController, animated: false, completion: nil)
                })
                
            }
        }

    }
    

    func presentView(){
        if let viewControllerName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) {
            let viewControllerToShow = getScreen(viewControllerName)
            
            //if the user is not logged in then show login window
            if !UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn) {

                self.view.window?.rootViewController?.present(viewControllerToShow, animated: false, completion: nil)
            }
        }

        if !BaseTabViewController.userHasGoals() {
            updateSelectedIndex()
            return
        }

    }
    /* This method returns the view controller we ask for as a string
     
     - parameter viewControllerName: String, this is the name the view controller we want to display
     - return UIViewController, UIViewController instance returned according to the parameter passed in
     */
    func getScreen(_ viewControllerName: String) -> UIViewController{
        var navController: UINavigationController?
        var rootController: UIViewController?

        switch viewControllerName {
        case ViewControllerTypeString.confirmMobileNumberValidation.rawValue:
            rootController = R.storyboard.login.confirmationCodeValidationViewController(())
            navController = R.storyboard.login.instantiateInitialViewController()
            
        case ViewControllerTypeString.pinResetValidation.rawValue:
            rootController = R.storyboard.login.pinResetValidationController(())
            navController = R.storyboard.login.instantiateInitialViewController()
            
        case ViewControllerTypeString.adminOverrideValidation.rawValue:
            rootController = R.storyboard.login.adminOverrideValidationViewController(())
            navController = R.storyboard.login.instantiateInitialViewController()
            
        case ViewControllerTypeString.setPin.rawValue:
            rootController = R.storyboard.login.setPinViewController(())
            navController = R.storyboard.login.instantiateInitialViewController()

        case ViewControllerTypeString.login.rawValue:
            rootController = R.storyboard.login.loginViewController(())
            navController = R.storyboard.login.instantiateInitialViewController()
            
        case ViewControllerTypeString.welcome.rawValue:
            rootController = R.storyboard.welcome.welcomeViewController(())
            navController = R.storyboard.welcome.instantiateInitialViewController()

        case ViewControllerTypeString.walkThrough.rawValue:
            rootController = R.storyboard.walkThrough.walkThroughViewController(())
            navController = R.storyboard.walkThrough.instantiateInitialViewController()
            
        case ViewControllerTypeString.userProfile.rawValue:
            rootController = R.storyboard.meDashBoard.profileStoryboard(())
            navController = R.storyboard.login.instantiateInitialViewController()
            
        case ViewControllerTypeString.signUp.rawValue:
            rootController = R.storyboard.welcome.signUpSecondStepViewController(())
            navController = R.storyboard.welcome.instantiateInitialViewController()
            
        default:
            rootController = R.storyboard.welcome.welcomeViewController(())
            navController = R.storyboard.welcome.instantiateInitialViewController()
            
        }

        if let rootController = rootController {
            navController?.pushViewController(rootController, animated: false)
        }
        return navController ?? rootController!
    }

    @objc func presentLoginScreen() {
        let viewControllerToShow = getScreen(ViewControllerTypeString.login.rawValue)
        self.view.window?.rootViewController?.present(viewControllerToShow, animated: false) {
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSelectedIndex() {
        if BaseTabViewController.userHasGoals(){
            self.selectedIndex = Tab.profile.rawValue
        }else{
            self.selectedIndex = Tab.challenges.rawValue
        }
    }
    
    class func userHasGoals() -> Bool {
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.fromAddressBook) {
            return true
        }
        return UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
    }

}
