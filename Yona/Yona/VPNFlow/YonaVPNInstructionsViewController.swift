//
//  YonaVPNInstructionsViewController.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaInstructionsProtocol {
    
    
    func didFinishAnimations(_ sender : AnyObject)
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
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaVPNInstructionsViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
//MARK: Protocol impl
    func startAnimation(){
    
        overlayImage.alpha = 0.0
        overlayImage.isHidden = false
        UIView.animate(withDuration: animationDuration, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn,animations: {
            self.overlayImage.alpha = 1.0
            }, completion: {
                completed in
                
        })
    }
    
    
    @IBAction func userDidPressScreen (_ sender : AnyObject){
        self.delegate?.didFinishAnimations(self)
    }

    
}
