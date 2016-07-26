//
//  YonaVPNFlowInstructionsVPNViewController.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaVPNFlowInstructionsVPNViewController : UIViewController {
    @IBOutlet weak var progressPageControl: UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func setupUI() {
        self.navigationItem.backBarButtonItem  = UIBarButtonItem()
        view.backgroundColor = UIColor.yiGrapeColor()
        navigationItem.title = NSLocalizedString("vpnflowmainscreen.title.text", comment: "")
       
    }

}