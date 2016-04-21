//
//  TimeFrameBudgetChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeFrameBudgetChallengeViewController: UIViewController {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var setChallengeButton: UIButton!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    var goalToPost: Goal?
    var maxDurationMinutes: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    @IBAction func postNewBudgetChallengeButtonTapped(sender: AnyObject) {
       print("integrate post budget challenge")
        
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {


    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index  \(indexPath)")
       
    }
}

private extension Selector {
   
    static let back = #selector(TimeFrameBudgetChallengeViewController.back(_:))
    
}

