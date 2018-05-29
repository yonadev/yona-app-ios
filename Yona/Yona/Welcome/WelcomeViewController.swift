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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "WelcomeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    fileprivate func setupUI() {
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
    }
    
    
    func turnOffVPN() {
        if UIApplication.shared.canOpenURL( URL(string: "openvpn://")! ) {
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: NSLocalizedString("turn-off-vpn-alert", comment:""), message: nil, preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("turn-off-vpn-alert-cancel-action", comment:""), style: .cancel, handler: { _ in
                    // nothing to handle
                })
                
                let openVpnAction = UIAlertAction(title: NSLocalizedString("turn-off-vpn-alert-action", comment:""), style: .default, handler: { _ in
                    UIApplication.shared.openURL(URL(string: "openvpn://")!)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(openVpnAction)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
}
