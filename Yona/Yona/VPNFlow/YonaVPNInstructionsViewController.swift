//
//  YonaVPNInstructionsViewController.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaInstructionsProtocol {
    
    
    func didFinishAnimations(sender : AnyObject)
    func didRequestReRun()
    
    
}

class YonaVPNInstructionsViewController : UIViewController {
    
    @IBOutlet weak var textLabel : UILabel!
    @IBOutlet weak var mainImage : UIImageView!
    @IBOutlet weak var overlayImage : UIImageView!
    
    var delegate : YonaInstructionsProtocol?
    let animationDuration = 0.6;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yiGrapeColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "YonaVPNInstructionsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
//MARK: Protocol impl
    func startAnimation(){
    
        overlayImage.alpha = 0.0
        overlayImage.hidden = false
        UIView.animateWithDuration(animationDuration, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn,animations: {
            self.overlayImage.alpha = 1.0
            }, completion: {
                completed in
                
        })
    }
    
    
    @IBAction func userDidPressScreen (sender : AnyObject){
        self.delegate?.didFinishAnimations(self)
    }

    
}