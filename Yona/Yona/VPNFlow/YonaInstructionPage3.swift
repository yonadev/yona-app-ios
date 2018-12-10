//
//  YonaInstructionPage3.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaInstructionPage3 : YonaVPNInstructionsViewController {
  
    @IBOutlet weak var actionButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = NSLocalizedString("vpnflowintro1.title3.text", comment: "")
        actionButton.setTitle(NSLocalizedString("vpnflowintro1.rerun.text", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaInstructionPage3")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    @IBAction func requestReRun(_ sender: AnyObject){
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "requestReRun", label: "Request re run of instructions", value: nil).build() as! [AnyHashable: Any])
        
        delegate?.didRequestReRun()
    }
    
    override func startAnimation(){
        
        overlayImage.alpha = 0.0
        overlayImage.isHidden = false
        UIView.animate(withDuration: animationDuration, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn,animations: {
            self.overlayImage.alpha = 1.0
            }, completion: {
                completed in
                UIView.animate(withDuration: 0.0  , delay: 0.5, options: UIViewAnimationOptions.curveEaseIn,animations: {
                    
                    }, completion: {
                        completed in
                    self.delegate?.didFinishAnimations(self)
                })
        })
    }
}
