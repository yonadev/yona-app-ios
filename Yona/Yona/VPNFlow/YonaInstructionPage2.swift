//
//  YonaInstructionPage2.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaInstructionPage2 : YonaVPNInstructionsViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = NSLocalizedString("vpnflowintro1.title2.text", comment: "")
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "YonaInstructionPage2")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}