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
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var minutesPerDayLabel: UILabel!
    @IBOutlet weak var budgetChallengeTitle: UILabel!
    @IBOutlet weak var budgetChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var maxTimeButton: UIButton!
    @IBOutlet weak var budgetChallengeMainTitle: UILabel!
    @IBOutlet weak var deleteGoalButton: UIButton!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.timeZoneLabel.text = NSLocalizedString("challenges.addBudgetGoal.timeZoneLabel", comment: "")
        self.minutesPerDayLabel.text = NSLocalizedString("challenges.addBudgetGoal.minutesPerDayLabel", comment: "")
        self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        self.budgetChallengeMainTitle.text = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeMainTitle", comment: "")
        self.maxTimeButton.setTitle(String(maxDurationMinutes), forState: UIControlState.Normal)

        let localizedString = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeDescription", comment: "")
        if let activityName = activitiyToPost?.activityCategoryName {
            self.budgetChallengeDescription.text = String(format: localizedString, activityName)
        }
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func postNewBudgetChallengeButtonTapped(sender: AnyObject) {
        print("integrate post budget challenge")
        
        if let activityCategoryLink = activitiyToPost?.selfLinks! {
            let bodyBudgetGoal: [String: AnyObject] = [
                "@type": "BudgetGoal",
                "_links": ["yona:activityCategory":
                    ["href": activityCategoryLink]
                ],
                "maxDurationMinutes": String(maxDurationMinutes)
            ]
            APIServiceManager.sharedInstance.postUserGoals(bodyBudgetGoal, onCompletion: {
                (success, serverMessage, serverCode, goal, err) in
                if success {
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.deleteGoalButton.selected = true
                        self.displayAlertMessage(serverMessage!, alertDescription: "")
                    })

                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayAlertMessage(serverMessage!, alertDescription: "")
                    })
                }
            })
        }
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

