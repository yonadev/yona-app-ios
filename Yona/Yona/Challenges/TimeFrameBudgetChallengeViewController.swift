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

class TimeFrameBudgetChallengeViewController: BaseViewController {
    
    weak var delegate: BudgetChallengeDelegate?
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var minutesPerDayLabel: UILabel!
    @IBOutlet weak var budgetChallengeTitle: UILabel!
    @IBOutlet weak var budgetChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var maxTimeButton: UIButton!

    @IBOutlet var deleteGoalButton: UIBarButtonItem!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var pickerBackgroundView: UIView!
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: String = "1"
    
    var picker = YonaCustomPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimeBucketTabToDisplay(.budget, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor

        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        
        configurePickerView()
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.timeZoneLabel.text = NSLocalizedString("challenges.addBudgetGoal.budgetLabel", comment: "")
        self.minutesPerDayLabel.text = NSLocalizedString("challenges.addBudgetGoal.minutesPerDayLabel", comment: "")
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")

        
        if let maxDurationMinutesUnwrapped = goalCreated?.maxDurationMinutes {
            maxDurationMinutes = String(maxDurationMinutesUnwrapped)
            self.maxTimeButton.setTitle(String(maxDurationMinutesUnwrapped), forState: UIControlState.Normal)
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
            self.maxTimeButton.setTitle(String(maxDurationMinutes), forState: UIControlState.Normal)
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        picker.showHidePicker(isToShow: false)
    }
    
    // MARK: functions
    func configurePickerView() {
        pickerBackgroundView = YonaCustomPickerView().loadPickerView()
        picker = pickerBackgroundView as! YonaCustomPickerView
        var arr = [Int]()
        arr += 1...96
        picker.setData(onView: self.view, data: arr, withCancelListener:{
            self.picker.showHidePicker(isToShow: false)
        }) { (doneValue) in
            self.picker.showHidePicker(isToShow: false)
            if doneValue != "" {
                self.maxDurationMinutes = doneValue
                
                self.maxTimeButton.setTitle(String(self.maxDurationMinutes), forState: UIControlState.Normal)
            }
        }
        
        self.pickerBackgroundView.frame.origin.y = self.view.frame.size.height + 200
        self.pickerBackgroundView.frame.size.width = UIScreen.mainScreen().bounds.width
        
        picker.frame.size.width = UIScreen.mainScreen().bounds.width
        UIApplication.sharedApplication().keyWindow?.addSubview(pickerBackgroundView)
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
    
    @IBAction func maxTimebuttonTapped(sender: AnyObject) {
        picker.showHidePicker(isToShow: true)
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {
        if let goalUnwrap = self.goalCreated,
            let goalEditLink = goalUnwrap.editLinks {
            Loader.Show()
            GoalsRequestManager.sharedInstance.deleteUserGoal(goalEditLink) { (success, serverMessage, serverCode) in
                Loader.Hide()
                
                if success {
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

