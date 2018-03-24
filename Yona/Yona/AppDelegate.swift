//
//  AppDelegate.swift
//  Yona
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
import HockeySDK

protocol AppLifeCylcleConsumer: UIApplicationDelegate {
    func appDidEnterForeground()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,NSURLSessionDelegate {
    static let sharedApp = UIApplication.sharedApplication().delegate as! AppDelegate
    var window: UIWindow?
    static var firstTime = true
    var httpServer : RoutingHTTPServer?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var timer: NSTimer?
    static var instance: AppLifeCylcleConsumer!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
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
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
        
        updateEnvironmentSettings()
        //check for goals, no go go
        if BaseTabViewController.userHasGoals() == false {
            setTimeBucketTabToDisplay(.budget, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        }
        hockeyAppSetup()
		updateEnvironmentSettings()
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        //set universal settings for our navigation bar
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
        NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        
        //get rid of the pixel line in the nav bar
        
        let barAppearace = UIBarButtonItem.appearance()
        barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
        
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            forBarPosition: .Any,
            barMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        Loader.setup()
        return true
        
    }
        
    func applicationWillResignActive(application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Loader.Hide()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        if  !NSUserDefaults.standardUserDefaults().boolForKey(YonaConstants.nsUserDefaultsKeys.vpncompleted) {
            print ("STARTING BACKGROUND TASK")
            self.doBackgroundTask()
        }
        
        //doTestCycleForVPN()

    }
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
 
    func doBackgroundTask() {
        Loader.Hide()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.beginBackgroundUpdateTask()
            
            // Do something with the result.
            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(AppDelegate.printServerStatus), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
            
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }

    func applicationWillEnterForeground(application: UIApplication) {
        Loader.Hide()
        updateEnvironmentSettings()
       // doTestCycleForVPN()
        
        //AppDelegate.instance.appDidEnterForeground()
        
    }
    
    private func hockeyAppSetup() {
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
    
    func printServerStatus() {
        print("SERVER IS STARTED : \(self.httpServer?.isRunning())")
        
    }
    
    func handleMobileconfigRootRequest (request :RouteRequest,  response :RouteResponse ) {
        RootRequestHelper().handleMobileconfigRootRequest(request, response: response)
        
    }
    
    /** Catches first and second attempts to load config file, and then inserts an address into safari to switch back to the app
     */
    func handleMobileconfigLoadRequest (request : RouteRequest ,response : RouteResponse ) {
        if AppDelegate.firstTime  {
//            NSLog("handleMobileconfigLoadRequest, first time")
//            NSLog("request %@", request.url())
            AppDelegate.firstTime = false
            let resourceDocPath = NSHomeDirectory().stringByAppendingString("/Documents/user.mobileconfig")
            let mobileconfigData: NSData? = NSData(contentsOfFile: resourceDocPath)

            
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
            response.respondWithData(mobileconfigData)
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
            
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            print("stopping server")
            timer?.invalidate()
            httpServer?.stop()
        }
    }
    
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)
        
    }
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
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
        NSUserDefaults.standardUserDefaults().removeObjectForKey(YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        NSUserDefaults.standardUserDefaults().synchronize()
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
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.vpncompleted)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
            NSUserDefaults.standardUserDefaults().setBool(false,   forKey: "SIMULATOR_OPENVPN")
            
            return
        }
        
        testForVpnEnabled()
    }
    
    
    func testForVpnEnabled() {
            if let url = NSURL(string: "https://10.110.0.1:442") {
                let request:NSURLRequest = NSURLRequest(URL:url)
                let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                let que = NSOperationQueue()
                config.timeoutIntervalForResource = 5
                let session = NSURLSession(configuration: config, delegate: self, delegateQueue: que)
                let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                    if let aError = error {
                        Loader.Hide()
                        let trxt = " No access through vpn \(aError.code), \(aError.localizedDescription)"
                        let xtx = NSLocalizedString("vpnerror.notrunning.message.text",comment:"")
                        
                        let alert = UIAlertController(title: NSLocalizedString("vpnerror.notrunning.title.text", comment:""), message: xtx, preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: {
                            void in
                            self.handleOpenVPNNotRuning()
                        })
                        alert.addAction(cancelAction)
                        var rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
                        if let navigationController = rootViewController as? UINavigationController {
                            rootViewController = navigationController.viewControllers.first
                        }
                        if let tabBarController = rootViewController as? UITabBarController {
                            rootViewController = tabBarController.selectedViewController
                        }
                        rootViewController?.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                });
                
                task.resume()
            }
    }
    func alertView( alertView: UIAlertView,clickedButtonAtIndex buttonIndex: Int){
        
        if buttonIndex == 1 {
            handleOpenVPNNotRuning()
        }
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.host == "10.110.0.1" {
                if let trus = challenge.protectionSpace.serverTrust {
                        let cred = NSURLCredential(forTrust: trus)
                        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential,cred)
                } else {
                    completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge,nil)
                }
            } else {
                completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge,nil)
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
