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
    case openVPNAppInstalledStep2
    case openVPNAppInstalledStep3
    case configurationInstaling
    case configurationInstalled
    case configurationNotInstalled
}

class YonaVPNFlowMainViewController: UIViewController {
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView:UIView!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var yonaAppStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var openVPNStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var profileStatusView : YonaVPNProgressIconView!

    @IBOutlet weak var finalShowInstructionsButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var demoCounter = 0
    
    var currentProgress : VPNSetupStatus = .yonaAppInstalled
    var customView : UIView  = UIView(frame: CGRectZero)
    
    //var webServer : GCDWebUploader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(removeScreen), name: UIApplicationDidEnterBackgroundNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        resetAllViews()
        dispatcher()
    }
    
    func resetAllViews() {
        
        progressLabel.text = ""
        infoLabel.text = ""
        

        yonaAppStatusView.alpha = 0.0
        yonaAppStatusView.hidden = false
        
        openVPNStatusView.alpha = 0.0
        openVPNStatusView.hidden = false
        
        profileStatusView.alpha = 0.0
        profileStatusView.hidden = false

        nextButton.alpha = 0.0
        progressView.alpha = 0.0
        
        finalShowInstructionsButton.alpha = 0.0
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
        customView.frame = CGRectMake(0, 0, (viewWidth-60)/4, 2)
        customView.backgroundColor = UIColor.yiDarkishPinkColor()
        progressView.addSubview(customView)
    
        nextButton.backgroundColor = UIColor.yiDarkishPinkColor()
        nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), forState: UIControlState.Normal)
        nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), forState: UIControlState.Disabled)

        openVPNStatusView.hidden = true
        profileStatusView.hidden = true
        nextButton.alpha = 0.0
    }

    
    @IBAction func finalInstrucsionsButtonAction (sender :UIButton) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationController?.navigationBarHidden = true
        })
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier(R.segue.yonaVPNFlowMainViewController.mobileInstruction, sender: self)
        })

        
    }
    
    @IBAction func buttonAction (sender :UIButton) {
        
        if currentProgress == .openVPNAppNotInstalledShow {
//            dispatch_async(dispatch_get_main_queue(), {
//                self.navigationController?.setNavigationBarHidden(true, animated: false)
//                })
//            dispatch_async(dispatch_get_main_queue(), {
                self.navigationItem.hidesBackButton = true
                self.performSegueWithIdentifier(R.segue.yonaVPNFlowMainViewController.showVPNInstructions, sender: self)
//            })
//            dispatch_async(dispatch_get_main_queue(), {
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
//                dispatch_after(delayTime, dispatch_get_main_queue()){
//
//
//                }
//                })
            return
        }
        if currentProgress == .openVPNAppInstalledStep3 {
            UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
                if success {
                    //THIS MUST BE CHANGED TO A CORRECT PROFILE, once imported from user profile
                    if let url = NSURL(string: "http://www.simusoft.dk/test.mobileconfig") {
                        UIApplication.sharedApplication().openURL(url)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey:YonaConstants.nsUserDefaultsKeys.vpncompleted)
                        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                        
                    }
                } else {
                    // ALERT USER TRYAGAIN LATER
                    
                }
            }
            return
        }
        dispatcher()
        
    }

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.destinationViewController is YonaVPNFlowInstructionsVPNViewController {
//            
//            
//        }
//    }
    
    
    //MARK: - view displaymethods
    func dispatcher() {
    
        testForOpenVPN()
        
        
        switch currentProgress {
        case .yonaAppInstalled:
            handleyonaAppInstalled()

        case .openVPNAppNotInstalledSetup:
            dispatch_async(dispatch_get_main_queue(), {
                self.handleOpenVPNAppNotInstalledSetup()
            })
        case .openVPNAppNotInstalledShow:
            dispatch_async(dispatch_get_main_queue(), {
                self.handleOpenVPNAppNotInstalledShow()
            })
        case .openVPNAppInstalled:
            handleOpenVPNAppInstalled()
            
        case .openVPNAppInstalledStep2:
            handleOpenVPNAppInstalledStep2()
        default:
            handleyonaAppInstalled()
        }
    }
  
    
    func testForOpenVPN() {
        demoCounter += 1
        
        let installed = UIApplication.sharedApplication().canOpenURL( NSURL(string: "openvpn://")! )
        //let status = NSUserDefaults.standardUserDefaults().integerForKey(YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        
        if demoCounter == 3 {
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            
            currentProgress = .openVPNAppInstalled
            return
        }
        if installed && currentProgress.rawValue < VPNSetupStatus.openVPNAppInstalledStep2.rawValue {
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)

            currentProgress = .openVPNAppInstalled
        }
        
        

        
    }

    
    //MARK: - each step animator
    
    func handleyonaAppInstalled () {
        progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress.text", comment: "")
        infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info.text", comment: "")
        
        progressView.alpha = 1.0
        
        
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        yonaAppStatusView.alpha = 1.0
        
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.handleOpenVPNAppNotInstalledShow()
                })

        })
    }
    
    func handleOpenVPNAppNotInstalledShow () {
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress1.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info1.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button1.next", comment: ""), forState: UIControlState.Normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button1.next", comment: ""), forState: UIControlState.Disabled)

        self.nextButton.enabled = false

        self.openVPNStatusView.setText(NSLocalizedString("YonaVPNProgressView.openvpn1.text", comment: ""))
        
        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .openVPNAppNotInstalledShow
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.titleLabel?.alpha = 1.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 1.0
            self.profileStatusView.alpha = 0.4
            }, completion: {
                completed in
                self.nextButton.enabled = true
        })
    }


    func handleOpenVPNAppInstalled () {
        let viewWidth = self.progressView.frame.size.width
        customView.frame =  CGRectMake(0, 0, (viewWidth-60), 2)
        progressView.alpha = 1.0
        
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress2.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info2.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), forState: UIControlState.Normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), forState: UIControlState.Disabled)
        self.nextButton.enabled = false
        self.openVPNStatusView.setText(NSLocalizedString("YonaVPNProgressView.openvpn.text", comment: ""))
        
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        yonaAppStatusView.alpha = 1.0
        
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: true)
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
                                self.nextButton.enabled = true
                                self.currentProgress = .openVPNAppInstalledStep2

                        })
                })
        })
        
    }
  
    func handleOpenVPNAppInstalledStep2 () {
        UIView.animateWithDuration(0.3, animations: {
            self.progressLabel.alpha = 0.0
            self.infoLabel.alpha = 0.0
            self.nextButton.titleLabel?.alpha = 0.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 0.4
            self.profileStatusView.alpha = 0.4
            
            }, completion: {
                completed in
                self.currentProgress = .openVPNAppInstalledStep3
                NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalledStep3.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)

                dispatch_async(dispatch_get_main_queue(), {
                    self.handleOpenVPNAppInstalledStep3()
                })
                
        })
    }

    
    func handleOpenVPNAppInstalledStep3 () {
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress3.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info3.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button3.next", comment: ""), forState: UIControlState.Normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button3.next", comment: ""), forState: UIControlState.Disabled)

        self.finalShowInstructionsButton.setTitle(NSLocalizedString("vpnflowmainscreen.finalInstructions.button", comment: ""), forState: UIControlState.Normal)
        self.finalShowInstructionsButton.setTitle(NSLocalizedString("vpnflowmainscreen.finalInstructions.button", comment: ""), forState: UIControlState.Disabled)

        self.nextButton.enabled = false
        
        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.titleLabel?.alpha = 1.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 0.4
            self.profileStatusView.alpha = 1.0
            self.finalShowInstructionsButton.alpha = 1.0
            }, completion: {
                completed in
                self.nextButton.enabled = true
        })
    }

    
    func serverSetup() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]

        
//        //NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//        webServer = GCDWebUploader(uploadDirectory:documentsPath)
//        webServer?.delegate = self
//        webServer?.allowHiddenItems
//        if webServer!.start() {
//            print( "GCDWebServer running locally on port \(webServer?.port)")
//            
//        } else {
//            print( "GCDWebServer running locally on port \(webServer?.port)")
//        
//        }
/*            [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        _webServer.delegate = self;
        _webServer.allowHiddenItems = YES;
        if ([_webServer start]) {
            _label.text = [NSString stringWithFormat:NSLocalizedString(@"GCDWebServer running locally on port %i", nil), (int)_webServer.port];
        } else {
            _label.text = NSLocalizedString(@"GCDWebServer not running!", nil);
        }
*/
    }
}

