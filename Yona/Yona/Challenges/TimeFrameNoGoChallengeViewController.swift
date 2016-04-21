//
//  TimeFrameNoGoChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeFrameNoGoChallengeViewController: UIViewController {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var setChallengeButton: UIButton!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        
        
        //Nav bar Back button.
        self.navigationItem.hidesBackButton = true
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
    }
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    @IBAction func postNewNoGoChallengeButtonTapped(sender: AnyObject) {
        print("integrate post  challenge")
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {


    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index  \(indexPath)")
       
    }
}

private extension Selector {
   
    static let back = #selector(TimeFrameNoGoChallengeViewController.back(_:))
    
}

