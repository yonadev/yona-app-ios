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

        setupUI()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "WelcomeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
    }
    
}
