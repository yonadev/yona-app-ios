//
//  WelcomeViewController.swift
//  Yona
//
//  Created by Chandan on 05/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    // MARK: - List of Variable
    var didEditTextField = false
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        setupUI()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(WelcomeViewController.longPressed(sender:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "WelcomeViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Switch Environment UI
    fileprivate func setupUI() {
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.didEditTextField = true
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        showEnvironmentSwitchUI(sender: sender)
    }
    
    fileprivate func showEnvironmentSwitchUI(sender: AnyObject) {
        let currentBaseURLString = EnvironmentManager.baseUrlString()
        let alert = UIAlertController(title: NSLocalizedString("environment-alert-title", comment:""), message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = currentBaseURLString
            textField.addTarget(self, action: #selector(WelcomeViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        })
        addAlertAction(alert, currentBaseURLString)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func addAlertAction(_ alert: UIAlertController, _ currentBaseURLString: String?) {
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .default, handler: {[weak alert] (action) -> Void in
            let textField = alert!.textFields![0] as UITextField
            let strURL = self.removeWhitespaceFromURL(url: textField.text!)
            self.processEnvironmentURL(newEnvironmentURL: strURL, currentEnvironmentURL: currentBaseURLString!)
        }))
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
    
    fileprivate func processEnvironmentURL(newEnvironmentURL:String, currentEnvironmentURL:String) {
        EnvironmentManager.updateEnvironment(withURLString: newEnvironmentURL)
        if currentEnvironmentURL != newEnvironmentURL {
            ActivitiesRequestManager.sharedInstance.getActivityDefaultCategories(onCompletion: { (success, message, code, activitiesReturned, error) in
                if success {
                    EnvironmentManager.updateEnvironment(withURLString: newEnvironmentURL)
                    self.showEnvironmentChangedAlert(message: NSLocalizedString("environment-success", comment: "") + newEnvironmentURL)
                } else {
                    EnvironmentManager.updateEnvironment(withURLString: currentEnvironmentURL)
                    self.showEnvironmentChangedAlert(message: NSLocalizedString("environment-failure", comment: "") + currentEnvironmentURL)
                }
            })
        } else if self.didEditTextField {
            self.showSameEnvironmentURLAlert()
        }
    }
    
    // MARK: - Custom Alert
    fileprivate func showSameEnvironmentURLAlert() {
        let sameEnvironmentAlert = UIAlertController(title: "", message: NSLocalizedString("environment-same", comment: ""), preferredStyle: .alert)
        self.didEditTextField = false
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .cancel, handler: { _ in
            // nothing to handle
        })
        sameEnvironmentAlert.addAction(cancelAction)
        self.present(sameEnvironmentAlert, animated: true, completion: nil)
    }
    
    fileprivate func showEnvironmentChangedAlert(message: String) {
        let environmentChangedAlert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.didEditTextField = false
        let cancelAction = UIAlertAction(title: NSLocalizedString("Ok", comment:""), style: .cancel, handler: { _ in
            // nothing to handle
        })
        environmentChangedAlert.addAction(cancelAction)
        self.present(environmentChangedAlert, animated: true, completion: nil)
    }
    
    func removeWhitespaceFromURL(url: String) -> String {
         return url.replacingOccurrences(of: " ", with: "")
    }
}
