//
//  IntroductoryContentViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class IntroductoryContentViewController: UIViewController {
    
    @IBOutlet var introductoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    
    @IBAction func nextTapped(sender: UIButton) {
        if pageIndex == 3 {
            if let welcome = R.storyboard.welcome.welcomeStoryboard {
                self.navigationController?.pushViewController(welcome, animated: false)
            }
        }
    }
     override func viewDidLoad()
     {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.introductoryImageView.image = UIImage(named: self.imageFile)
        
        
    }
    
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
