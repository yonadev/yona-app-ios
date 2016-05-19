//
//  TimeFrameBudgetChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

protocol BudgetChallengeDelegate {
    func callGoalsMethod()
}

class TimeFrameBudgetChallengeViewController: BaseViewController {
    
    var delegate: BudgetChallengeDelegate?
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
    
    @IBOutlet weak var pickerBackgroundView: UIView!
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimeBucketTabToDisplay(timeBucketTabNames.budget.rawValue, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        self.gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        
        configurePickerView()
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.timeZoneLabel.text = NSLocalizedString("challenges.addBudgetGoal.timeZoneLabel", comment: "")
        self.minutesPerDayLabel.text = NSLocalizedString("challenges.addBudgetGoal.minutesPerDayLabel", comment: "")
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        self.budgetChallengeMainTitle.text = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeMainTitle", comment: "")
        self.maxTimeButton.setTitle(String(maxDurationMinutes), forState: UIControlState.Normal)
        if let maxDurationMinutesUnwrapped = goalCreated?.maxDurationMinutes {
            self.maxTimeButton.setTitle(String(maxDurationMinutesUnwrapped), forState: UIControlState.Normal)
        }
        //        configureDatePickerView()
        
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeDescription", comment: "")
        
        if isFromActivity == true {
            self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.deleteGoalButton.hidden = false
            } else {
                self.deleteGoalButton.hidden = true
            }
            
            self.budgetChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        }
    }
    
    // MARK: functions
    func configurePickerView() {
        pickerBackgroundView = YonaCustomPickerView().loadPickerView()
        let picker = pickerBackgroundView as! YonaCustomPickerView
        var arr = [Int]()
        arr += 1...96
        picker.setData(data: arr,
                       withCancelListener: {
                        self.showHidePicker(false)
        }) { (doneValue) in
            self.showHidePicker(false)
            if doneValue != "" {
                self.maxDurationMinutes = doneValue
                
                self.maxTimeButton.setTitle(String(self.maxDurationMinutes), forState: UIControlState.Normal)
            }
        }
        
        self.pickerBackgroundView.frame.origin.y = self.view.frame.size.height + 200
        self.pickerBackgroundView.frame.size.width = UIScreen.mainScreen().bounds.width
        
        picker.frame.size.width = UIScreen.mainScreen().bounds.width
        UIApplication.sharedApplication().keyWindow?.addSubview(pickerBackgroundView)
//        self.view.addSubview(pickerBackgroundView)
    }
    
    func showHidePicker(isToShow: Bool) {
        UIView.animateWithDuration(0.6,
                                   animations: {
                                    if isToShow {
                                        self.pickerBackgroundView.frame.origin.y = self.view.frame.size.height - 200
                                    } else {
                                        self.pickerBackgroundView.frame.origin.y = self.view.frame.size.height + 200
                                    }
            },
                                   completion: nil)
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
                Loader.Show(delegate:self)
                GoalsRequestManager.sharedInstance.postUserGoals(bodyBudgetGoal) { (success, serverMessage, serverCode, goal, nil, err) in
                    Loader.Hide(self)
                    
                    if success {
                        self.delegate?.callGoalsMethod()
                        if let goalUnwrap = goal {
                            self.goalCreated = goalUnwrap
                        }
                        self.deleteGoalButton.selected = true
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                        
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
                        self.deleteGoalButton.selected = true
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                    } else {
                        Loader.Hide()
                        if let message = serverMessage {
                            self.displayAlertMessage(message, alertDescription: "")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func maxTimebuttonTapped(sender: AnyObject) {
        showHidePicker(true)
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {
        self.delegate?.callGoalsMethod()

        //then once it is posted we can delete it
        if let goalUnwrap = self.goalCreated,
            let goalEditLink = goalUnwrap.editLinks {
            Loader.Show(delegate:self)
            GoalsRequestManager.sharedInstance.deleteUserGoal(goalEditLink) { (success, serverMessage, serverCode) in
                Loader.Hide(self)
                
                if success {
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

