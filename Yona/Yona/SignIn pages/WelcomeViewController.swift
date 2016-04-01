//
//  WelcomeViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet var welcomeView: UIView!
    @IBOutlet var welcomeWebViewBG: UIWebView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    
    var colorX : UIColor = UIColor(red: (10/255.0), green: (237/255.0), blue: (213/255.0), alpha: 1.0)
    var colorY : UIColor = UIColor(red: (255/255.0), green: (0/255.0), blue: (70/255.0), alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create File Path and Read From It
        let filePath = NSBundle.mainBundle().pathForResource("faceBook", ofType: "gif")
        let gif = NSData(contentsOfFile: filePath!)
        
        
        // UIWebView to Load gif
        welcomeWebViewBG.loadData(gif!, MIMEType: "image/gif", textEncodingName: "utf-8", baseURL: NSURL(string: "http://localhost/")!)
        welcomeWebViewBG.userInteractionEnabled = false
        self.view.addSubview(welcomeWebViewBG)
        
        
        // backgroundFilter
        let filter = UIView()
        filter.frame = self.view.frame
        filter.backgroundColor = UIColor.blackColor()
        filter.alpha = 0.35
        self.view.addSubview(filter)
        
        
        
        welcomeLabel.text = "Welcome"
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.font = UIFont(name: "Avenir Next", size: 17)
        self.view.addSubview(welcomeLabel)
        
        loginButton.setBackgroundImage(UIImage(named: "cyanOutfill"), forState: UIControlState.Normal)
        //            loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        //            loginButton.layer.borderWidth = 1
        //            loginButton.layer.cornerRadius = 5
        loginButton.titleLabel!.font = UIFont(name: "Avenir Next", size: 16)
        loginButton.tintColor = colorX
        loginButton.backgroundColor = UIColor.clearColor()
        loginButton.setTitle("Login", forState: UIControlState.Normal)
        loginButton.center = CGPointMake(welcomeView.frame.size.width  / 2, welcomeView.frame.size.height  / 2)
        self.view.addSubview(loginButton)
        
        signUpButton.setBackgroundImage(UIImage(named: "coralRedOutfill"), forState: UIControlState.Normal)
        //            signUpButton.layer.borderColor = UIColor.whiteColor().CGColor
        //            signUpButton.layer.borderWidth = 1
        //            signUpButton.layer.cornerRadius = 5
        signUpButton.titleLabel!.font = UIFont(name: "Avenir Next", size: 16)
        signUpButton.tintColor = colorY
        signUpButton.backgroundColor = UIColor.clearColor()
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        self.view.addSubview(signUpButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
