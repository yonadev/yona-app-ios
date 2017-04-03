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
    
    
    func turnOffVPN() {
        if UIApplication.sharedApplication().canOpenURL( NSURL(string: "openvpn://")! ) {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: NSLocalizedString("turn-off-vpn-alert", comment:""), message: nil, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("turn-off-vpn-alert-cancel-action", comment:""), style: .Cancel, handler: { _ in
                    // nothing to handle
                })
                
                let openVpnAction = UIAlertAction(title: NSLocalizedString("turn-off-vpn-alert-action", comment:""), style: .Default, handler: { _ in
                    UIApplication.sharedApplication().openURL(NSURL(string: "openvpn://")!)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(openVpnAction)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
}
