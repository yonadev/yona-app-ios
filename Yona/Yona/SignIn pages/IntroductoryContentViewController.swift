//
//  IntroductoryContentViewController.swift
//  Yona
//
//  Created by Chandan on 23/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class IntroductoryContentViewController: UIViewController {
    
    @IBOutlet var introductoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func buttonAction(sender: UIButton) {
        
    }
    
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.introductoryImageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
