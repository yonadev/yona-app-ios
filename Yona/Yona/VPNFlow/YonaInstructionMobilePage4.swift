//
//  YonaInstructionPage1.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaInstructionMobilePage4 : YonaVPNInstructionsViewController{
    
    @IBOutlet weak var actionButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = NSLocalizedString("vpnflowintro2.title4.text", comment: "")
        actionButton.setTitle(NSLocalizedString("vpnflowintro1.rerun.text", comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaInstructionMobilePage4")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }

    @IBAction func requestReRun(_ sender: AnyObject){
        delegate?.didRequestReRun()
    }
    
    override func startAnimation(){
        
        overlayImage.alpha = 0.0
        overlayImage.isHidden = false
        UIView.animate(withDuration: animationDuration, delay: 0.5, options: UIView.AnimationOptions.curveEaseIn,animations: {
            self.overlayImage.alpha = 1.0
            }, completion: {
                completed in
                UIView.animate(withDuration: 0.0  , delay: 0.5, options: UIView.AnimationOptions.curveEaseIn,animations: {
                    
                    }, completion: {
                        completed in
                        self.delegate?.didFinishAnimations(self)
                })
        })
    }

}
