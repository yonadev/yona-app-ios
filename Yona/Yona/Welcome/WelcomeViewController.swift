//
//  WelcomeViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
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
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        performSegueWithIdentifier(R.segue.welcomeViewController.signUpFirstStepViewController, sender: self)
    }
    
    @IBAction func login(sender: AnyObject) {
        if let addDeviceStoryboard = R.storyboard.addDeviceViewController.addDeviceStoryboard {
            navigationController?.pushViewController(addDeviceStoryboard, animated: true)
        }
    }
}
