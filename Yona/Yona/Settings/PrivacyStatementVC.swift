//
//  PrivacyStatementVC.swift
//  Yona
//
//  Created by Ben Smith on 18/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

class PrivacyStatementVC: UIViewController {
    @IBOutlet var privacyView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Loader.Show()
        let requestObj = URLRequest(url: URL(string: YonaConstants.urlLinks.privacyStatementURLString)!);
        self.privacyView.loadRequest(requestObj)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "PrivacyStatementVC")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
}

    //MARK: UIWebViewDelegate
extension PrivacyStatementVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        Loader.Hide()
    }
}
