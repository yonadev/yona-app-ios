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
    
    // MARK: - IBOutlet
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView:UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var yonaAppStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var openVPNStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var profileStatusView : YonaVPNProgressIconView!
    @IBOutlet weak var finalShowInstructionsButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var nextLaterButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var nextButtonLaterSpace: NSLayoutConstraint!
    @IBOutlet weak var topTitleConstarint: NSLayoutConstraint!
    @IBOutlet weak var spacerView1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var spacerView1 : UIView!
    @IBOutlet weak var spacerView2 : UIView!
    
    // MARK: - List of Variable
    var demoCounter = 0
    var mobileconfigData : Data?
    var currentProgress : VPNSetupStatus = .yonaAppInstalled
    var customView : UIView  = UIView(frame: CGRect.zero)
    var firstTime = true
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(removeScreen), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaVPNFlowMainViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetAllViews()
        dispatcher()
    }
    
    // MARK: - SetUp UI Methods
    func resetAllViews() {
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()
        progressLabel.text = ""
        infoLabel.text = ""
        yonaAppStatusView.alpha = 0.0
        yonaAppStatusView.isHidden = false
        openVPNStatusView.alpha = 0.0
        openVPNStatusView.isHidden = false
        profileStatusView.alpha = 0.0
        profileStatusView.isHidden = false
        nextButton.alpha = 0.0
        laterButton.alpha = 0.0
        progressView.alpha = 0.0
        finalShowInstructionsButton.alpha = 0.0
        let  cur = UserDefaults.standard.integer(forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = VPNSetupStatus(rawValue: cur)!
    }
    
    @objc func removeScreen() {
        //TODO: NEXT 2 LINES TO BE REMOVED AFTER CODE COMPLETIONS
        if currentProgress != VPNSetupStatus.configurationInstalled {
            UserDefaults.standard.set(VPNSetupStatus.yonaAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            currentProgress = .yonaAppInstalled
        }
        dismiss(animated: false, completion: {})
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.yiGrapeColor()
        navigationItem.title = NSLocalizedString("vpnflowmainscreen.title.text", comment: "")
        
        let viewWidth = self.view.frame.size.width
        customView.frame = CGRect(x: 0, y: 0, width: (viewWidth-60)/4, height: 2)
        customView.backgroundColor = UIColor.yiDarkishPinkColor()
        progressView.addSubview(customView)
        
        nextButton.backgroundColor = UIColor.yiDarkishPinkColor()
        nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), for: .normal)
        nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), for: UIControl.State.disabled)
        
        laterButton.backgroundColor = UIColor.yiDarkishPinkColor()
        laterButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.later", comment: ""), for: .normal)
        laterButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.later", comment: ""), for: UIControl.State.disabled)
        
        openVPNStatusView.isHidden = true
        profileStatusView.isHidden = true
        nextButton.alpha = 0.0
        
        if view.frame.size.height < 500 {
            topTitleConstarint.constant = 0
            spacerView1HeightConstraint.constant = 0
            spacerView1.layoutIfNeeded()
            spacerView2.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is YonaVPNFlowInstructionsMobileConfigViewController {
            let controller = segue.destination as! YonaVPNFlowInstructionsMobileConfigViewController
            controller.delegate = self
        }
    }
    
    // MARK: - IBAction Methods
    @IBAction func finalInstrucsionsButtonAction (_ sender :UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "finalInstrucsionsButtonAction", label: "Last instruction button tapped", value: nil).build() as! [AnyHashable: Any])
        DispatchQueue.main.async(execute: {
            self.navigationItem.hidesBackButton = true
            self.performSegue(withIdentifier: R.segue.yonaVPNFlowMainViewController.mobileInstruction, sender: self)
        })
    }
    
    @IBAction func laterAction (_ sender :UIButton) {
        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
        UserDefaults.standard.set(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        UserDefaults.standard.set(true,   forKey: "SIMULATOR_OPENVPN")
        self.dismiss(animated: true, completion: {})
        return
    }
    
    @IBAction func buttonAction (_ sender :UIButton) {
        if currentProgress == .openVPNAppNotInstalledShow {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "VPNInstallButton", label: "Open VPN app not installed", value: nil).build() as! [AnyHashable: Any])
            DispatchQueue.main.async(execute: {
                UserDefaults.standard.set(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                self.currentProgress = .openVPNAppNotInstalledSetup
                self.navigationItem.hidesBackButton = true
                self.performSegue(withIdentifier: R.segue.yonaVPNFlowMainViewController.showVPNInstructions, sender: self)
            })
            return
        }
        if currentProgress == .openVPNAppInstalledStep3 {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "VPNInstallButton", label: "Open VPN app installed step 3", value: nil).build() as! [AnyHashable: Any])
            downloadFileFromServer()
            return
        }
        if currentProgress == .configurationInstalled {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "VPNInstallButton", label: "Configuration final installed", value: nil).build() as! [AnyHashable: Any])
            UserDefaults.standard.set(true, forKey:YonaConstants.nsUserDefaultsKeys.vpncompleted)
            self.dismiss(animated: true, completion: {})
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
            DispatchQueue.main.async(execute: {
                self.handleOpenVPNAppNotInstalledSetup()
            })
        case .openVPNAppNotInstalledShow:
            DispatchQueue.main.async(execute: {
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
            UserDefaults.standard.set(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            currentProgress = .yonaAppInstalled
            resetAllViews()
            handleyonaAppInstalled()
        }
    }
    
    func testForOpenVPN() {
        #if (arch(i386) || arch(x86_64))
        if UserDefaults.standard.bool( forKey: "SIMULATOR_OPENVPN"){
            if currentProgress.rawValue < VPNSetupStatus.openVPNAppInstalledStep2.rawValue {
                UserDefaults.standard.set(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                currentProgress = .openVPNAppInstalled
                UserDefaults.standard.set(currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            }
        }
        return
        #else
        let installed = UIApplication.shared.canOpenURL( NSURL(string: "openvpn://")! as URL )
        if installed && currentProgress.rawValue < VPNSetupStatus.openVPNAppInstalledStep2.rawValue {
            UserDefaults.standard.set(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            currentProgress = .openVPNAppInstalled
            UserDefaults.standard.set(currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        }
        #endif
    }
    
    //MARK: - each step animator
    func handleyonaAppInstalled () {
        progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress.text", comment: "")
        infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info.text", comment: "")
        progressView.alpha = 1.0
        
        var frame = nextButton.frame
        frame.size.width = view.frame.size.width/2
        nextButton.frame=frame
        
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        yonaAppStatusView.alpha = 1.0
        
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: false)
        openVPNStatusView.alpha = 0.0
        openVPNStatusView.isHidden = false
        
        profileStatusView.confugureView(progressIconEnum.profile, completed: false)
        profileStatusView.alpha = 0.0
        profileStatusView.isHidden = false
        
        UIView.animate(withDuration: 0.6, delay: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.openVPNStatusView.alpha = 1.0
        }, completion:  {
            completed   in
            UIView.animate(withDuration: 0.6, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.profileStatusView.alpha = 1.0
            }, completion:  {
                completed   in
                UIView.animate(withDuration: 0.6, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.nextButton.alpha = 1.0
                    self.laterButton.alpha = 1.0
                }, completion:  {
                    completed   in
                })
            })
        })
        UserDefaults.standard.set(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .openVPNAppNotInstalledSetup
    }
    
    func handleOpenVPNAppNotInstalledSetup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.progressLabel.alpha = 0.0
            self.infoLabel.alpha = 0.0
            self.nextButton.titleLabel?.alpha = 0.0
            self.laterButton.titleLabel?.alpha = 0.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 0.4
            self.profileStatusView.alpha = 0.4
        }, completion: {
            completed in
            DispatchQueue.main.async(execute: {
                self.handleOpenVPNAppNotInstalledShow()
            })
        })
    }
    
    func handleOpenVPNAppNotInstalledShow () {
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress1.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info1.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button1.next", comment: ""), for: .normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button1.next", comment: ""), for: UIControl.State.disabled)
        self.nextButton.isEnabled = false
        self.openVPNStatusView.setText(NSLocalizedString("YonaVPNProgressView.openvpn1.text", comment: ""))
        UserDefaults.standard.set(VPNSetupStatus.openVPNAppNotInstalledSetup.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        currentProgress = .openVPNAppNotInstalledShow
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.titleLabel?.alpha = 1.0
            self.laterButton.titleLabel?.alpha = 1.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 1.0
            self.profileStatusView.alpha = 0.4
        }, completion: {
            completed in
            self.nextButton.isEnabled = true
        })
    }
    
    func handleOpenVPNAppInstalled () {
        let viewWidth = self.progressView.frame.size.width
        customView.frame =  CGRect(x: 0, y: 0, width: (viewWidth-60), height: 2)
        progressView.alpha = 1.0
        
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress2.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info2.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), for: .normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button.next", comment: ""), for: UIControl.State.disabled)
        self.nextButton.isEnabled = false
        self.openVPNStatusView.setText(NSLocalizedString("YonaVPNProgressView.openvpn.text", comment: ""))
        
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        yonaAppStatusView.alpha = 1.0
        
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: true)
        openVPNStatusView.alpha = 0.0
        openVPNStatusView.isHidden = false
        
        profileStatusView.confugureView(progressIconEnum.profile, completed: false)
        profileStatusView.alpha = 0.0
        profileStatusView.isHidden = false
        
        UIView.animate(withDuration: 0.6, delay: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.openVPNStatusView.alpha = 1.0
        }, completion:  {
            completed   in
            UIView.animate(withDuration: 0.6, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.profileStatusView.alpha = 1.0
            }, completion:  {
                completed   in
                UIView.animate(withDuration: 0.6, delay: 0.2, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.nextButton.alpha = 1.0
                    self.laterButton.alpha = 1.0
                }, completion:  {
                    completed   in
                    self.nextButton.isEnabled = true
                    self.currentProgress = .openVPNAppInstalledStep2
                    UserDefaults.standard.set(self.currentProgress.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                })
            })
        })
    }
    
    func handleOpenVPNAppInstalledStep2 () {
        UIView.animate(withDuration: 0.3, animations: {
            self.progressLabel.alpha = 0.0
            self.infoLabel.alpha = 0.0
            self.nextButton.titleLabel?.alpha = 0.0
            self.laterButton.titleLabel?.alpha = 0.0
            
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 0.4
            self.profileStatusView.alpha = 0.4
            
        }, completion: {
            completed in
            self.currentProgress = .openVPNAppInstalledStep3
            UserDefaults.standard.set(VPNSetupStatus.openVPNAppInstalledStep3.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            DispatchQueue.main.async(execute: {
                self.handleOpenVPNAppInstalledStep3()
            })
        })
    }
    
    func handleOpenVPNAppInstalledStep3 () {
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress3.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info3.text", comment: "")
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button3.next", comment: ""), for: .normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button3.next", comment: ""), for: UIControl.State.disabled)
        
        self.finalShowInstructionsButton.setTitle(NSLocalizedString("vpnflowmainscreen.finalInstructions.button", comment: ""), for: .normal)
        self.finalShowInstructionsButton.setTitle(NSLocalizedString("vpnflowmainscreen.finalInstructions.button", comment: ""), for: UIControl.State.disabled)
        
        self.nextButton.isEnabled = false
        
        var frame = nextButton.frame
        frame.size.width = view.frame.size.width/2
        nextButton.frame=frame
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.titleLabel?.alpha = 1.0
            self.laterButton.titleLabel?.alpha = 1.0
            self.yonaAppStatusView.alpha = 0.4
            self.openVPNStatusView.alpha = 0.4
            self.profileStatusView.alpha = 1.0
            self.finalShowInstructionsButton.alpha = 1.0
        }, completion: {
            completed in
            self.nextButton.isEnabled = true
        })
    }
    
    func handleConfigurationInstalled() {
        let viewWidth = self.progressView.frame.size.width
        customView.frame =  CGRect(x: 0, y: 0, width: viewWidth, height: 2)
        progressView.alpha = 1.0
        self.laterButton.alpha = 0.0
        self.nextButton.isEnabled = false
        self.progressLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.progress4.text", comment: "")
        self.infoLabel.text = NSLocalizedString("vpnflowmainscreen.appinstalled.info4.text", comment: "")
        
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button4.next", comment: ""), for: .normal)
        self.nextButton.setTitle(NSLocalizedString("vpnflowmainscreen.button4.next", comment: ""), for: UIControl.State.disabled)
        yonaAppStatusView.confugureView(progressIconEnum.yonaApp, completed: true)
        openVPNStatusView.confugureView(progressIconEnum.openVPN, completed: true)
        profileStatusView.confugureView(progressIconEnum.profile, completed: true)
        
        nextButton.setNeedsLayout()
        nextButtonConstraint.constant = view.frame.size.width
        nextButton.setNeedsLayout()
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,  animations: {
            self.progressLabel.alpha = 1.0
            self.infoLabel.alpha = 1.0
            self.nextButton.alpha = 1.0
            self.laterButton.alpha = 1.0
            self.yonaAppStatusView.alpha = 1.0
            self.openVPNStatusView.alpha = 1.0
            self.profileStatusView.alpha = 1.0
            self.finalShowInstructionsButton.alpha = 0.0
        }, completion: {
            completed in
            self.nextButton.isEnabled = true
        })
    }
    
    //MARK: - mobilconfigurationfile
    
    func serverSetup() {
        Loader.Show()
        let resourceDocPath = NSHomeDirectory() + "/Documents/user.mobileconfig"
        mobileconfigData = try? Data(contentsOf: URL(fileURLWithPath: resourceDocPath))
        (UIApplication.shared.delegate as! AppDelegate).startServer()
    }
    
    func handleMobileconfigRootRequest (_ request :RouteRequest,  response :RouteResponse ) {
        print("handleMobileconfigRootRequest");
        let txt = "<HTML><HEAD><title>Profile Install</title></HEAD><script>function load() { window.location.href='http://localhost:8089/load/'; }var int=self.setInterval(function(){load()},2000);</script><BODY></BODY></HTML>"
        response.respond(with: txt)
    }
    
    func handleMobileconfigLoadRequest (_ request : RouteRequest ,response : RouteResponse ) {
        if firstTime  {
            print("handleMobileconfigLoadRequest, first time")
            firstTime = false
            let resourceDocPath = NSHomeDirectory() + "/Documents/user.mobileconfig"
            mobileconfigData = try? Data(contentsOf: URL(fileURLWithPath: resourceDocPath))
            response.setHeader("Content-Type", value: "application/x-apple-aspen-config")
            response.respond(with: mobileconfigData)
        } else {
            print("handleMobileconfigLoadRequest, NOT first time")
            response.statusCode = 302
            //TODO: must change yonaApp: to the id choosen by Yona and add a path to override pincode.... (security???)
            if #available(iOS 9, *) {
                response.setHeader("Location", value: "https://www.yona.nl/yonaapp/")
            } else {
                response.setHeader("Location", value: "yonaApp://yonaapp/")
            }
            currentProgress = .configurationInstalled
            UserDefaults.standard.set(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        }
    }
    
    func downloadFileFromServer() {
        Loader.Show()
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
            if success {
                UserRequestManager.sharedInstance.getMobileConfigFile() { (succes,data,code) in
                    Loader.Hide()
                    if data != nil {
                        let resourceDocPath = NSHomeDirectory() + "/Documents/user.mobileconfig"
                        unlink(resourceDocPath)
                        do {
                            try? data?.write(to: URL(fileURLWithPath: resourceDocPath), options: [.atomic])
                        }
                        catch {
                        }
                        self.serverSetup()
                        self.testForServerAndContinue()
                    } else {
                        var co = ""
                        if code != nil {co = code!}
                        let txt = "Error getting the mobile.config file from server: '\(co)'"
                        let alertController = UIAlertController(title: "ERROR", message: txt, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                            void in
                            DispatchQueue.main.async(execute: {
                                self.dispatcher()
                            })
                        })
                        alertController.addAction(cancelAction)
                        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                        if let navigationController = rootViewController as? UINavigationController {
                            rootViewController = navigationController.viewControllers.first
                        }
                        if let tabBarController = rootViewController as? UITabBarController {
                            rootViewController = tabBarController.selectedViewController
                        }
                        rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func testForServerAndContinue () {
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC * 4)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime){
            if let running = (UIApplication.shared.delegate as! AppDelegate).httpServer?.isRunning() {
                if  running {
                    print("SERVER IS STARTED : \((UIApplication.shared.delegate as! AppDelegate).httpServer?.isRunning())")
                    if let url = URL(string:"http://localhost:8089/start/") {
                        UIApplication.shared.openURL(url)
                    }
                    // new
                    self.currentProgress = .configurationInstalled
                    UserDefaults.standard.set(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
                    return
                        DispatchQueue.main.async(execute: {
                            self.dispatcher()
                        })
                    // end
                } else {
                    print("SERVER IS NOT STARTED : \((UIApplication.shared.delegate as! AppDelegate).httpServer?.isRunning())")
                    print("re-trying")
                    self.testForServerAndContinue()
                }
            }
        }
    }
    
    // called from instructions view
    func installMobileProfile() {
        navigationController?.popViewController(animated: true)
        downloadFileFromServer()
    }
}

