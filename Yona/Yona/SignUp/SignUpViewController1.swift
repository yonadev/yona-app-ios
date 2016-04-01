
//
//  SignUpViewController.swift
//  Yona
//
//  Created by Chandan on 29/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SignUpViewController1: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.navigationController?.navigationBar.barTintColor = UIColor.yiGrapeTwoColor()
        //        self.view.backgroundColor = UIColor.yiGrapeTwoColor()
        //        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "icnBack")!, style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
