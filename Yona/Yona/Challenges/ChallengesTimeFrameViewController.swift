//
//  ChallengesTimeFrameViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class ChallengesTimeFrameViewController: UIViewController {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func deletebuttonTapped(sender: UIButton) {

        
    }
    
    

}

private extension Selector {
   
    static let back = #selector(SignUpSecondStepViewController.back(_:))
    
}

