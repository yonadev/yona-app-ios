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
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(WelcomeViewController.longPressed(sender:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        print("longpressed")
        showEnvironmentSwitchUI(sender: sender)
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
    
    var didEditTextField = false
    @objc func textFieldDidChange(textField: UITextField) {
        self.didEditTextField = true
    }
    
    @IBAction func showEnvironmentSwitchUI(sender: AnyObject) {
        let currentBaseURLString = EnvironmentManager.baseUrlString()
        //1. Create the alert controller.
        let alert = UIAlertController(title: "", message: "Enter a text", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = currentBaseURLString
            textField.addTarget(self, action: #selector(WelcomeViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak alert] (action) -> Void in
            
            let textField = alert!.textFields![0] as UITextField
            print("Text field: \(String(describing: textField.text))")
            let newEnvironmentURL = textField.text;
            EnvironmentManager.updateEnvironment(withURLString: newEnvironmentURL)
            self.didEditTextField = false
            if currentBaseURLString != newEnvironmentURL{
                ActivitiesRequestManager.sharedInstance.getActivityDefaultCategories(onCompletion: { (success, message, code, activitiesReturned, error) in
                    if success {
                        EnvironmentManager.updateEnvironment(withURLString: newEnvironmentURL)
                        
                    }else{
                        EnvironmentManager.updateEnvironment(withURLString: currentBaseURLString)
                    }
                })
            }else{
                if (self.didEditTextField && currentBaseURLString != newEnvironmentURL){
                    let sameEnvironmentAlert = UIAlertController(title: "", message: "You are in the same Environment", preferredStyle: .alert)
                    self.didEditTextField = false
                    
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .cancel, handler: { _ in
                        // nothing to handle
                    })
                    sameEnvironmentAlert.addAction(cancelAction)
                    
                    // 4. Present the alert.
                    self.present(sameEnvironmentAlert, animated: true, completion: nil)
                }
            }
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
