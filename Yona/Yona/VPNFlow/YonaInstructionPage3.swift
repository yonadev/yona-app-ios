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
        actionButton.setTitle(NSLocalizedString("vpnflowintro1.rerun.text", comment: ""), forState: UIControlState.Normal)
    }
    
    @IBAction func requestReRun(sender: AnyObject){
        delegate?.didRequestReRun()
    }
    
    override func startAnimation(){
        
        overlayImage.alpha = 0.0
        overlayImage.hidden = false
        UIView.animateWithDuration(animationDuration, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn,animations: {
            self.overlayImage.alpha = 1.0
            }, completion: {
                completed in
                UIView.animateWithDuration(0.0  , delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn,animations: {
                    
                    }, completion: {
                        completed in
                    self.delegate?.didFinishAnimations(self)
                })
        })
    }
}