//
//  AppDelegate.swift
//  Yona
//
//  Created by Alessio Roberto on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var firstTime = true
    var httpServer : RoutingHTTPServer?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
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
            setTimeBucketTabToDisplay(.noGo, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        }
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        //set universal settings for our navigation bar
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
        NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UINavigationBar.appearance().barTintColor = UIColor.yiWhiteColor()
        
        //get rid of the pixel line in the nav bar
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
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn)

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
 
    
    func applicationWillEnterForeground(application: UIApplication) {
        updateEnvironmentSettings()
        doTestCycleForVPN()
        
    }
    
    func doBackgroundTask() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.beginBackgroundUpdateTask()
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }
    
    func startServer() {
        self.httpServer = RoutingHTTPServer()
        self.httpServer?.setPort(8089)
        
        self.httpServer?.handleMethod("GET", withPath: "/start", target: self, selector: #selector(self.handleMobileconfigRootRequest))
        self.httpServer?.handleMethod("GET", withPath: "/load", target: self, selector: #selector(self.handleMobileconfigLoadRequest))
        
        
        
        do {
            try  self.httpServer?.start()
            print("SERVER STARTET")
        } catch {
            return
        }

    
    }
    func handleMobileconfigRootRequest (request :RouteRequest,  response :RouteResponse ) {
        print("handleMobileconfigRootRequest");
        let txt = "<HTML><HEAD><title>Profile Install</title></HEAD><script type=\"text/javascript\">window.addEventListener(\"focus\", function(evt){load()},false);window.addEventListener(\"blur\", function(evt) {console.log('hide');}, false);</script><script type=\"text/javascript\">function load() {clearInterval(int);window.location.href='http://localhost:8089/load/';}var int=self.setInterval(function(){load()},200);</script><BODY></BODY></HTML>"
        
        
        /*"<HTML><HEAD><title>Profile Install</title></HEAD><script type=\"text/javascript\">window.addEventListener(\"pageshow\", function(evt){alert('show');}, false);window.addEventListener(\"pagehide\", function(evt){console.log('hide';}, false);</script><script>function load() { window.location.href='http://localhost:8089/load/'; }var int=self.setInterval(function(){load()},4000);</script><BODY></BODY></HTML>"*/
        response.respondWithString(txt)
    }
    
    func handleMobileconfigLoadRequest (request : RouteRequest ,response : RouteResponse ) {
        if firstTime  {
            print("handleMobileconfigLoadRequest, first time")
            firstTime = false
            let resourceDocPath = NSHomeDirectory().stringByAppendingString("/Documents/user.mobileconfig")
            let mobileconfigData = NSData(contentsOfFile: resourceDocPath)
         
            response.setHeader("Content-Type", value: "application/x-apple-aspen-config")
            response.respondWithData(mobileconfigData)
        } else {
            print("handleMobileconfigLoadRequest, NOT first time")
            response.statusCode = 302
            //TODO: must change yonaApp: to the id choosen by Yona and add a path to override pincode.... (security???)
            //response.setHeader("Location", value: "yonaApp://")
            
            if #available(iOS 9, *) {
                response.setHeader("Location", value: "https://www.yona.nl/yonaapp/")
            } else {
                response.setHeader("Location", value: "yonaApp://yonaapp/")
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
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
        
        print ("I came here")
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
        if let url = NSURL(string: "https://10.96.169.12:442/cgi-bin/login.cgi") {
            let request:NSURLRequest = NSURLRequest(URL:url)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.timeoutIntervalForRequest = 10
            let session = NSURLSession(configuration: config)
            
            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                if let aError = error {
                    print (" No access through vpn \(aError.code), \(aError.localizedDescription)")
                    if #available(iOS 8.0, *) {
                        
                        let alert = UIAlertController(title: NSLocalizedString("vpnerror.notrunning.title.text", comment:""), message: NSLocalizedString("vpnerror.notrunning.message.text", comment:""), preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: {
                            void in
                            self.handleOpenVPNNotRuning()
                        })
                        alert.addAction(cancelAction)
                        self.window?.rootViewController!.presentViewController(alert, animated: true, completion:nil )
                        
                    }
                    else {
                        
                        UIAlertView(title:  NSLocalizedString("vpnerror.notrunning.title.text", comment:""), message: NSLocalizedString("vpnerror.notrunning.message.text", comment:""), delegate: self, cancelButtonTitle: "OK").show()
                    }

                    
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

    
    func handleOpenVPNNotRuning() {
        print("I came here")
    }
    
    func testForOpenVPNInstalled () -> Bool {
        #if (arch(i386) || arch(x86_64))
            return NSUserDefaults.standardUserDefaults().boolForKey( "SIMULATOR_OPENVPN")
            
        #else
            let installed = UIApplication.sharedApplication().canOpenURL( NSURL(string: "openvpn://")! )
            return installed
        #endif
    }
}
