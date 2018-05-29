//
//  YonaInstructionPage1.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaInstructionMobilePage1 : YonaVPNInstructionsViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = NSLocalizedString("vpnflowintro2.title1.text", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaInstructionMobilePage1")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
}
