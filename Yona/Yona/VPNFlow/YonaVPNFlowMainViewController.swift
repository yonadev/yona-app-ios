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
    var httpServer : RoutingHTTPServer?
    var mobileconfigData : NSData?
    var currentProgress : VPNSetupStatus = .yonaAppInstalled
    var customView : UIView  = UIView(frame: CGRectZero)
    var firstTime = true
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
        
        
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
                                                            NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()

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
        let  cur = NSUserDefaults.standardUserDefaults().integerForKey(YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = VPNSetupStatus(rawValue: cur)!

    }
    
    
    func removeScreen() {
        //TODO: NEXT 2 LINES TO BE REMOVED AFTER CODE COMPLETIONS
        
        if currentProgress != VPNSetupStatus.configurationInstalled {
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.yonaAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            currentProgress = .yonaAppInstalled
        }
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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is YonaVPNFlowInstructionsMobileConfigViewController {
            let controller = segue.destinationViewController as! YonaVPNFlowInstructionsMobileConfigViewController
            controller.delegate = self
        }
    }
    
    
    @IBAction func finalInstrucsionsButtonAction (sender :UIButton) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationItem.hidesBackButton = true
            self.performSegueWithIdentifier(R.segue.yonaVPNFlowMainViewController.mobileInstruction, sender: self)
        })

        
    }
    
    @IBAction func buttonAction (sender :UIButton) {
        
        if currentProgress == .openVPNAppNotInstalledShow {
            dispatch_async(dispatch_get_main_queue(), {
                NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                self.currentProgress = .openVPNAppNotInstalledSetup
            
                self.navigationItem.hidesBackButton = true
                self.performSegueWithIdentifier(R.segue.yonaVPNFlowMainViewController.showVPNInstructions, sender: self)
                })
            return
        }
        if currentProgress == .openVPNAppInstalledStep3 {
            downloadFileFromServer()
        
            return
        }
        if currentProgress == .configurationInstalled {
            httpServer?.stop()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey:YonaConstants.nsUserDefaultsKeys.vpncompleted)
            self.dismissViewControllerAnimated(true, completion: {})
            return
        }

        dispatcher()
        
    }
    
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
        case .configurationInstaling:
            downloadFileFromServer()
        
        case .configurationInstalled:
            handleConfigurationInstalled()
        default:
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            currentProgress = .yonaAppInstalled

            resetAllViews()
            handleyonaAppInstalled()
        }
    }
  
    
    func testForOpenVPN() {
        
        #if (arch(i386) || arch(x86_64))
            if NSUserDefaults.standardUserDefaults().boolForKey( "SIMULATOR_OPENVPN"){
                if currentProgress.rawValue < VPNSetupStatus.openVPNAppInstalledStep2.rawValue {
                    NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                    
                    currentProgress = .openVPNAppInstalled
                    NSUserDefaults.standardUserDefaults().setInteger(currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                    
                }
            }
            return
        #endif

        
        
        let installed = UIApplication.sharedApplication().canOpenURL( NSURL(string: "openvpn://")! )
        

        if installed && currentProgress.rawValue < VPNSetupStatus.openVPNAppInstalledStep2.rawValue {
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)

            currentProgress = .openVPNAppInstalled
            NSUserDefaults.standardUserDefaults().setInteger(currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)

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
                                NSUserDefaults.standardUserDefaults().setInteger(self.currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)


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

    
    func handleConfigurationInstalled() {
        let viewWidth = self.progressView.frame.size.width
        customView.frame =  CGRectMake(0, 0, viewWidth, 2)
        progressView.alpha = 1.0

        self.nextButton.enabled = false
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress4.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info4.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button4.next", comment: ""), forState: UIControlState.Normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button4.next", comment: ""), forState: UIControlState.Disabled)

        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: true)
        profileStatusView.confugureView(progressIconEnum.profile, completed: true)

        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.alpha = 1.0
            self.yonaAppStatusView.alpha = 1.0
            self.openVPNStatusView.alpha = 1.0
            self.profileStatusView.alpha = 1.0
            self.finalShowInstructionsButton.alpha = 0.0
            }, completion: {
                completed in
                self.nextButton.enabled = true
        })
   
    }
    
    //MARK: - mobilconfigurationfile
    func serverSetup() {
        
        httpServer = RoutingHTTPServer()
        httpServer?.setPort(8000)
        
        httpServer?.handleMethod("GET", withPath: "/start", target: self, selector: #selector(handleMobileconfigRootRequest))
        httpServer?.handleMethod("GET", withPath: "/load", target: self, selector: #selector(handleMobileconfigLoadRequest))
        let resourceDocPath = NSHomeDirectory().stringByAppendingString("/Documents/user.mobileconfig")
        mobileconfigData = NSData(contentsOfFile: resourceDocPath)

        
        
        do {
           try  self.httpServer?.start()
            print("SERVER STARTET")
        } catch {
            return
        }
    }
    
    func handleMobileconfigRootRequest (request :RouteRequest,  response :RouteResponse ) {
        print("handleMobileconfigRootRequest");
        let txt = "<HTML><HEAD><title>Profile Install</title></HEAD><script>function load() { window.location.href='http://localhost:8000/load/'; }var int=self.setInterval(function(){load()},400);</script><BODY></BODY></HTML>"
        response.respondWithString(txt)
}

    func handleMobileconfigLoadRequest (request : RouteRequest ,response : RouteResponse ) {
        if firstTime  {
            print("handleMobileconfigLoadRequest, first time")
            firstTime = false
        
            response.setHeader("Content-Type", value: "application/x-apple-aspen-config")
            response.respondWithData(mobileconfigData)
        } else {
            print("handleMobileconfigLoadRequest, NOT first time")
            response.statusCode = 302
            //TODO: must change yonaApp: to the id choosen by Yona and add a path to override pincode.... (security???)
            response.setHeader("Location", value: "yonaApp://")
            
            currentProgress = .configurationInstalled
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)

        }
    }
    
    
    func downloadFileFromServer() {
        Loader.Show()
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            if success {
                
                #if (arch(i386) || arch(x86_64))
                    self.currentProgress = .configurationInstalled
                    NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        Loader.Hide()
                        self.dispatcher()
                    })
                    
                    return
                #endif
                
                if let url = NSURL(string:"http://www.simusoft.dk/test.mobileconfig") {
                    if let configfile = NSData(contentsOfURL: url) {
                        let resourceDocPath = NSHomeDirectory().stringByAppendingString("/Documents/user.mobileconfig")
                        unlink(resourceDocPath)
                        configfile.writeToFile(resourceDocPath, atomically: true)
                        
                        self.serverSetup()
                        Loader.Hide()
                        if let url = NSURL(string:"http://localhost:8000/start/") {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                }
                
            } else {
                // ALERT USER TRYAGAIN LATER
                
            }
        }
    }


    // called from instructions view
    func installMobileProfile() {
        navigationController?.popViewControllerAnimated(true)
        downloadFileFromServer()
    }

}

