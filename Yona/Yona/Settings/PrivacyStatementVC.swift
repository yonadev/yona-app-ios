//
//  PrivacyStatementVC.swift
//  Yona
//
//  Created by Ben Smith on 18/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

class PrivacyStatementVC: UIViewController, UIWebViewDelegate{
    @IBOutlet var privacyView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Loader.Show()
        let requestObj = NSURLRequest(URL: NSURL(string: YonaConstants.urlLinks.privacyStatementURLString)!);
        self.privacyView.loadRequest(requestObj)
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "PrivacyStatementVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    //when webview is loaded stop the loading wheel and hide the view
    func webViewDidFinishLoad(webView: UIWebView) {
        Loader.Hide()
    }
}