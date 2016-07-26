//
//  YonaVPNFlowMainViewController.swift
//  Yona
//
//  Created by Anders Liebl on 25/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum VPNSetupStatus : Int {
    case yonaAppInstalled
    case openVPNAppNotInstalledSetup
    case openVPNAppNotInstalledShow
    case openVPNAppInstalled
    case configurationInstalled
    case configurationNOtInstalled
}

class YonaVPNFlowMainViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView:UIView!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var yonaAppStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var openVPNStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var profileStatusView : YonaVPNProgressIconView!

    @IBOutlet weak var nextButton: UIButton!
    
    var currentProgress : VPNSetupStatus = .yonaAppInstalled
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(removeScreen), name: UIApplicationDidEnterBackgroundNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatcher()
    }
    
    func removeScreen() {
        //TODO: NEXT 2 LINES TO BE REMOVED AFTER CODE COMPLETIONS
        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .yonaAppInstalled

        dismissViewControllerAnimated(false, completion: {})
    }
    
    func setupUI() {

        view.backgroundColor = UIColor.yiGrapeColor()
        navigationItem.title = NSLocalizedString("vpnflowmainscreen.title.text", comment: "")
    
        let viewWidth = self.view.frame.size.width
        let customView = UIView(frame: CGRectMake(0, 0, (viewWidth-60)/4, 2))
        customView.backgroundColor = UIColor.yiDarkishPinkColor()
        progressView.addSubview(customView)
    
        nextButton.backgroundColor = UIColor.yiDarkishPinkColor()
        nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), forState: UIControlState.Normal)
        openVPNStatusView.hidden = true
        profileStatusView.hidden = true
        nextButton.alpha = 0.0
    }

    @IBAction func buttonAction (sender :UIButton) {
        
        if currentProgress == .openVPNAppNotInstalledShow {
            performSegueWithIdentifier(R.segue.yonaVPNFlowMainViewController.showVPNInstructions, sender: self)
            return
        }
        dispatcher()
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is YonaVPNFlowInstructionsVPNViewController {
            
            
        }
    }
    
    
    //MARK: - view displaymethods
    func dispatcher() {
    
        switch currentProgress {
        case .yonaAppInstalled:
            handleyonaAppInstalled()

        case .openVPNAppNotInstalledSetup:
            handleOpenVPNAppNotInstalledSetup()
        case .openVPNAppNotInstalledShow:
            handleOpenVPNAppNotInstalledShow()

        default:
            handleyonaAppInstalled()
        }
    }
  
    //MARK: - each step animator
    
    func handleyonaAppInstalled () {
        progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress.text", comment: "")
        infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info.text", comment: "")
   
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: false)
        openVPNStatusView.alpha = 0.0
        openVPNStatusView.hidden = false
        
        profileStatusView.confugureView(progressIconEnum.profile, completed: false)
        profileStatusView.alpha = 0.0
        profileStatusView.hidden = false
        
        UIView.animateWithDuration(0.6, delay: 1.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.openVPNStatusView.alpha = 1.0
            }, completion:  {
                completed   in
                UIView.animateWithDuration(0.6, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.profileStatusView.alpha = 1.0
                    }, completion:  {
                        completed   in
                        UIView.animateWithDuration(0.6, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                            self.nextButton.alpha = 1.0
                            }, completion:  {
                                completed   in
                                
                        })
                })
        })
        
        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .openVPNAppNotInstalledSetup
    }
    
    func handleOpenVPNAppNotInstalledSetup() {
        UIView.animateWithDuration(0.3, animations: {
                self.progressLabel.alpha = 0.0
                self.infoLabel.alpha = 0.0
                self.nextButton.titleLabel?.alpha = 0.0
                self.yonaAppStatusView.alpha = 0.4
                self.openVPNStatusView.alpha = 0.4
                self.profileStatusView.alpha = 0.4

            }, completion: {
            completed in
                self.handleOpenVPNAppNotInstalledShow()
        })
    }
    
    func handleOpenVPNAppNotInstalledShow () {
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress1.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info1.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button1.next", comment: ""), forState: UIControlState.Normal)
        self.openVPNStatusView.setText(NSLocalizedString("YonaVPNProgressView.openvpn1.text", comment: ""))
        
        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .openVPNAppNotInstalledShow
        
        UIView.animateWithDuration(0.5, animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.titleLabel?.alpha = 1.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 1.0
            self.profileStatusView.alpha = 0.4
        })

    }
}