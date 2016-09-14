//
//  TimeFrameBudgetChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

protocol BudgetChallengeDelegate: class {
    func callGoalsMethod()
}

class TimeFrameBudgetChallengeViewController: BaseViewController,UIAlertViewDelegate {
    
    weak var delegate: BudgetChallengeDelegate?
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var minutesPerDayLabel: UILabel!
    @IBOutlet weak var budgetChallengeTitle: UILabel!
    @IBOutlet weak var budgetChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!

    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var minutesSlider: UISlider!
    @IBOutlet var deleteGoalButton: UIBarButtonItem!
    
    @IBOutlet var footerGradientView: GradientLargeView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: String = "0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if BaseTabViewController.userHasGoals() == false {
//            setTimeBucketTabToDisplay(.noGo, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
//        } else {
            setTimeBucketTabToDisplay(.budget, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
//        }
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor

        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.timeZoneLabel.text = NSLocalizedString("challenges.addBudgetGoal.budgetLabel", comment: "")
        self.minutesPerDayLabel.text = NSLocalizedString("challenges.addBudgetGoal.minutesPerDayLabel", comment: "")
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")

        
        if let maxDurationMinutesUnwrapped = goalCreated?.maxDurationMinutes {
            maxDurationMinutes = String(maxDurationMinutesUnwrapped)
            
        }
        
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeDescription", comment: "")
        
        self.navigationItem.rightBarButtonItem = nil
        if isFromActivity == true {
            self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
            self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clearColor()
            self.navigationItem.rightBarButtonItem?.enabled = false
            self.updateValues()
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
            } else {
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clearColor()
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
            
            self.budgetChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        }
        
        self.updateValues()
    }
    
    
    
    // MARK: - functions
   
    func updateValues()
    {
        self.minutesLabel.text = String(Int(maxDurationMinutes)!)
        self.minutesSlider.value = Float(maxDurationMinutes)!
        if self.minutesSlider.value > 0{
            self.setChallengeButton.enabled = true
        }else{
            self.setChallengeButton.enabled = false
        }
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func minutesDidChange(sender: AnyObject) {
        maxDurationMinutes = String(Int(minutesSlider.value))
        self.updateValues()
    }
    @IBAction func postNewBudgetChallengeButtonTapped(sender: AnyObject) {
        if isFromActivity == true {
            if let activityCategoryLink = activitiyToPost?.selfLinks! {
                let bodyBudgetGoal: [String: AnyObject] = [
                    "@type": "BudgetGoal",
                    "_links": ["yona:activityCategory":
                        ["href": activityCategoryLink]
                    ],
                    "maxDurationMinutes": String(maxDurationMinutes)
                ]
                Loader.Show()
                GoalsRequestManager.sharedInstance.postUserGoals(bodyBudgetGoal) { (success, serverMessage, serverCode, goal, nil, err) in
                    Loader.Hide()
                    
                    if success {
                        self.delegate?.callGoalsMethod()
                        if let goalUnwrap = goal {
                            self.goalCreated = goalUnwrap
                        }
                        self.navigationItem.rightBarButtonItem = self.deleteGoalButton
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        YonaConstants.nsUserDefaultsKeys.isGoalsAdded
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    } else {
                        if let message = serverMessage {
                            self.displayAlertMessage(message, alertDescription: "")
                        }
                    }
                }
            }
        } else {
            //EDIT Implementation
            if let activityCategoryLink = goalCreated?.activityCategoryLink! {
                let bodyBudgetGoal: [String: AnyObject] = [
                    "@type": "BudgetGoal",
                    "_links": ["yona:activityCategory":
                        ["href": activityCategoryLink]
                    ],
                    "maxDurationMinutes": String(maxDurationMinutes)
                ]
                Loader.Show()
                GoalsRequestManager.sharedInstance.updateUserGoal(goalCreated?.editLinks, body: bodyBudgetGoal, onCompletion: { (success, serverMessage, server, goal, goals, error) in
                    Loader.Hide()
                    
                    if success {
                        self.delegate?.callGoalsMethod()
                        if let goalUnwrap = goal {
                            self.goalCreated = goalUnwrap
                        }
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                    } else {
                        if let message = serverMessage {
                            self.displayAlertMessage(message, alertDescription: "")
                        }
                    }
                })
            }
        }
    }
  
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {
        if #available(iOS 8, *)  {
            let alert = UIAlertController(title: NSLocalizedString("WARNING", comment: ""), message: NSLocalizedString("Are you sure", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: {void in
                self.deleteGoal()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertView(title: NSLocalizedString("WARNING", comment: ""), message: NSLocalizedString("Are you sure", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), otherButtonTitles: NSLocalizedString("OK", comment: "") )
            
            alert.show()
        }
    
    }
    
    func alertView( alertView: UIAlertView,clickedButtonAtIndex buttonIndex: Int){
        
        if buttonIndex == 1 {
            deleteGoal()
        }
    }
    func deleteGoal() {
        if let goalUnwrap = self.goalCreated,
            let goalEditLink = goalUnwrap.editLinks {
            Loader.Show()
            GoalsRequestManager.sharedInstance.deleteUserGoal(goalEditLink) { (success, serverMessage, serverCode, goal, goals, error) in
                Loader.Hide()
                
                if success {
                    if goals?.count == 1 {
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                    }
                    self.delegate?.callGoalsMethod()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                } else {
                    if let message = serverMessage {
                        self.displayAlertMessage(message, alertDescription: "")
                    }
                }
            }
        }
    }
}

private extension Selector {
    static let back = #selector(TimeFrameBudgetChallengeViewController.back(_:))
}
