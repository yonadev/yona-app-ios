//
//  AppDelegate.swift
//  Yona
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import HockeySDK
import IQKeyboardManagerSwift
import Fabric
import Crashlytics

protocol AppLifeCylcleConsumer: UIApplicationDelegate {
    func appDidEnterForeground()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,URLSessionDelegate {
    static let sharedApp = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    static var firstTime = true
    var httpServer : RoutingHTTPServer?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var timer: Timer?
    static var instance: AppLifeCylcleConsumer!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
//        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
//        NSUserDefaults.standardUserDefaults().setBool(false,   forKey: "SIMULATOR_OPENVPN")
//       
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
        
        updateEnvironmentSettings()
        //check for goals, no go go
        if BaseTabViewController.userHasGoals() == false {
            setTimeBucketTabToDisplay(.budget, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        }
        hockeyAppSetup()
		updateEnvironmentSettings()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        //set universal settings for our navigation bar
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.yiWhiteColor(),
        NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        
        
        let barAppearace = UIBarButtonItem.appearance()
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), for:UIBarMetrics.default)
        
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        Loader.setup()
        initializeCrashlytics()
        return true
        
    }
    
    func initializeCrashlytics(){
        var fabricAPIKey: String? = nil
        if let filepath = Bundle.main.path(forResource: "fabric.apikey", ofType: nil) {
            do {
                fabricAPIKey = try String(contentsOfFile: filepath)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
        let whitespaceToTrim = CharacterSet.whitespacesAndNewlines
        let fabricAPIKeyTrimmed = fabricAPIKey?.trimmingCharacters(in: whitespaceToTrim)
        Crashlytics.start(withAPIKey: fabricAPIKeyTrimmed!)
    }
        
    func applicationWillResignActive(_ application: UIApplication) {
    
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Loader.Hide()
        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        if  !UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted) {
            print ("STARTING BACKGROUND TASK")
            self.doBackgroundTask()
        }
    }
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
 
    func doBackgroundTask() {
        Loader.Hide()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.beginBackgroundUpdateTask()
            
            // Do something with the result.
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AppDelegate.printServerStatus), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
            RunLoop.current.run()
            
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Loader.Hide()
        updateEnvironmentSettings()
       // doTestCycleForVPN()
        
        //AppDelegate.instance.appDidEnterForeground()
        
    }
    
    fileprivate func hockeyAppSetup() {
        return  // DONT need hockeyapp as we use testflight
//        var keys: NSDictionary?
//        
//        if let path = NSBundle.mainBundle().pathForResource("SecretKeys", ofType: "plist") {
//            keys = NSDictionary(contentsOfFile: path)
//        } else {
//            assertionFailure("You need the SecretKeys.plist file")
//        }
//        
//        if let dict = keys {
//            if let secretKey = dict["hockeyapp"] as? String {
//                BITHockeyManager.sharedHockeyManager().configureWithIdentifier(secretKey)
//                // Do some additional configuration if needed here
//                BITHockeyManager.sharedHockeyManager().testIdentifier()
//                BITHockeyManager.sharedHockeyManager().startManager()
//                BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
//                #if DEBUG
//                    BITHockeyManager.sharedHockeyManager().updateManager.checkForUpdateOnLaunch = false
//                #else
//                    BITHockeyManager.sharedHockeyManager().updateManager.checkForUpdateOnLaunch = true
//                #endif
//            }
//        }
        
    }
    
    /**
     * Starts the local host for making the safari browser return to the application
     **/
    func startServer() {
        AppDelegate.firstTime = true
        self.httpServer = RoutingHTTPServer()
        self.httpServer?.setPort(8089)
        
        self.httpServer?.handleMethod("GET", withPath: "/start", target: self, selector: #selector(self.handleMobileconfigRootRequest))
        self.httpServer?.handleMethod("GET", withPath: "/load", target: self, selector: #selector(self.handleMobileconfigLoadRequest))
        
        
        
        do {
            try  self.httpServer?.start()
            print("SERVER STARTET \(self.httpServer?.name())")
            
        } catch {
            return
        }
        
        
    }
    
    @objc func printServerStatus() {
        print("SERVER IS STARTED : \(self.httpServer?.isRunning())")
        
    }
    
    @objc func handleMobileconfigRootRequest (_ request :RouteRequest,  response :RouteResponse ) {
        RootRequestHelper().handleMobileconfigRootRequest(request, response: response)
        
    }
    
    /** Catches first and second attempts to load config file, and then inserts an address into safari to switch back to the app
     */
    @objc func handleMobileconfigLoadRequest (_ request : RouteRequest ,response : RouteResponse ) {
        if AppDelegate.firstTime  {
//            NSLog("handleMobileconfigLoadRequest, first time")
//            NSLog("request %@", request.url())
            AppDelegate.firstTime = false
            let resourceDocPath = NSHomeDirectory() + "/Documents/user.mobileconfig"
            let mobileconfigData: Data? = try? Data(contentsOf: URL(fileURLWithPath: resourceDocPath))

            
//            NSLog("----------------------------")
//            NSLog("                            ")
//            NSLog("                            ")
//            NSLog("                            ")
//            NSLog(" size of file \(mobileconfigData?.length)")
//            NSLog("                            ")
//            NSLog("                            ")
//            NSLog("                            ")
//            NSLog("----------------------------")
            response.setHeader("Content-Type", value: "application/x-apple-aspen-config")
            response.respond(with: mobileconfigData)
        } else {
            NSLog("handleMobileconfigLoadRequest, NOT first time")
            response.statusCode = 302
            //TODO: must change yonaApp: to the id choosen by Yona and add a path to override pincode.... (security???)
            //response.setHeader("Location", value: "yonaApp://")
            
            if #available(iOS 9, *) {
                response.setHeader("Location", value: "yonaApp://yonaapp/")
                //response.setHeader("Location", value: "https://beta.prd.yona.nu/yonaapp")
            } else {
                response.setHeader("Location", value: "yonaApp://yonaapp/")
            }
            
            UserDefaults.standard.set(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            print("stopping server")
            timer?.invalidate()
            httpServer?.stop()
        }
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    
    
    //MARK: Handle environment switch
    func updateEnvironmentSettings() -> Bool
    {
        let environemtnSettingsChanged = EnvironmentManager.updateEnvironment()
        if environemtnSettingsChanged{
            logout()
        }
        
        return environemtnSettingsChanged
    }
    
    /** This ius called by the environment settings if we switch to a different environment then the user is returned to the main scree
     */
    func logout()
    {
        UserDefaults.standard.removeObject(forKey: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        UserDefaults.standard.synchronize()
        UserRequestManager.sharedInstance.deleteUser { (success, message, code) in
            //delete user on log out
        }
    }
    
    
    //MARK: - test for enviroment settings
    
    /*
     * When the app starts we will check if vpn is enabled
     * as well as checking if openVPN is installed.
     * If not we will alert the user
     */
    
    
    func doTestCycleForVPN() {
        
        
        // first test if VPN is installed
        if !testForOpenVPNInstalled() {
            UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
            UserDefaults.standard.set(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            UserDefaults.standard.set(false,   forKey: "SIMULATOR_OPENVPN")
            
            return
        }
        
        testForVpnEnabled()
    }
    
    
    func testForVpnEnabled() {
            if let url = URL(string: "https://10.110.0.1:442") {
                let request:URLRequest = URLRequest(url:url)
                let config = URLSessionConfiguration.default
                let que = OperationQueue()
                config.timeoutIntervalForResource = 5
                let session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: que)
                let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
                    if let aError = error {
                        Loader.Hide()
                        let trxt = " No access through vpn \(aError._code), \(aError.localizedDescription)"
                        let xtx = NSLocalizedString("vpnerror.notrunning.message.text",comment:"")
                        
                        let alert = UIAlertController(title: NSLocalizedString("vpnerror.notrunning.title.text", comment:""), message: xtx, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                            void in
                            self.handleOpenVPNNotRuning()
                        })
                        alert.addAction(cancelAction)
                        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                        if let navigationController = rootViewController as? UINavigationController {
                            rootViewController = navigationController.viewControllers.first
                        }
                        if let tabBarController = rootViewController as? UITabBarController {
                            rootViewController = tabBarController.selectedViewController
                        }
                        rootViewController?.present(alert, animated: true, completion: nil)
                        
                    }
                });
                
                task.resume()
            }
    }
    func alertView( _ alertView: UIAlertView,clickedButtonAtIndex buttonIndex: Int){
        
        if buttonIndex == 1 {
            handleOpenVPNNotRuning()
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "10.110.0.1" {
                if let trus = challenge.protectionSpace.serverTrust {
                        let cred = URLCredential(trust: trus)
                        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential,cred)
                } else {
                    completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
                }
            } else {
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge,nil)
            }
        }
    }
    
    func handleOpenVPNNotRuning() {
       // print("I came here")
    }
    
    func testForOpenVPNInstalled () -> Bool {
        return true
    }
}
