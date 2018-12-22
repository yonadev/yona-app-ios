//
//  AVPageContentViewController.swift
//  AVLighterPageViewController
//
//  Created by Angel Vasa on 13/01/16.
//  Copyright © 2016 Angel Vasa. All rights reserved.
//

import UIKit

class AVPageContentViewController: BaseViewController {

    @IBOutlet var imageView: UIImageView?
    var viewControllerIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView?.image = UIImage(named: String(self.viewControllerIndex))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "AVPageContentViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
