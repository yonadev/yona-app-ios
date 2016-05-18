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
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Loader.Show()
        let requestObj = NSURLRequest(URL: NSURL(string: "http://www.yona.nu/app/privacy")!);
        self.privacyView.loadRequest(requestObj)
    }
    
    //when webview is loaded stop the loading wheel and hide the view
    func webViewDidFinishLoad(webView: UIWebView) {
        Loader.Hide()
    }
    
    @IBAction func backButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}