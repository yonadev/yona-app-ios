//
//  WelcomeViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
    }
    
    private func setupUI() {
        
        setViewControllerToDisplay("Welcome", key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        
        self.signUpButton.setTitle(NSLocalizedString("welcome.button.signup", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.loginButton.setTitle(NSLocalizedString("welcome.button.login", comment: "").uppercaseString, forState: UIControlState.Normal)
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        if let signupStoryboard = R.storyboard.signUp.signUpFirstStepViewController {
            navigationController?.pushViewController(signupStoryboard, animated: true)
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        if let loginStoryboard = R.storyboard.login.loginStoryboard {
            navigationController?.pushViewController(loginStoryboard, animated: true)
        }
    }
}
