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
    @IBOutlet weak var budgetChallengeTitle: UILabel!
    @IBOutlet weak var budgetChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var budgetChallengeMainTitle: UILabel!
    @IBOutlet weak var deleteGoalButton: UIButton!
    @IBOutlet var headerImage: UIImageView!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimeBucketTabToDisplay(timeBucketTabNames.noGo.rawValue, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = setChallengeButton.frame.size.height/2
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        })
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.NoGoChallengeDescription", comment: "")
        if isFromActivity == true {
            setChallengeButton.enabled = true
            setChallengeButton.alpha = 1.0
            self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        } else {
            setChallengeButton.enabled = false
            setChallengeButton.alpha = 0.5
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
        
        self.headerImage.image = UIImage(named: "icnChallengeNogo")
        
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        self.budgetChallengeMainTitle.text = NSLocalizedString("challenges.addBudgetGoal.NoGoChallengeMainTitle", comment: "")
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func postNewNoGoChallengeButtonTapped(sender: AnyObject) {
        if let activityCategoryLink = activitiyToPost?.selfLinks! {
            let bodyBudgetGoal: [String: AnyObject] = [
                "@type": "BudgetGoal",
                "_links": ["yona:activityCategory":
                    ["href": activityCategoryLink]
                ],
                "maxDurationMinutes": String(maxDurationMinutes)
            ]
            Loader.Show(delegate: self)
            APIServiceManager.sharedInstance.postUserGoals(bodyBudgetGoal, onCompletion: {
                (success, serverMessage, serverCode, goal, goals, err) in
                if success {
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.deleteGoalButton.selected = true
                        Loader.Hide(self)
                        self.navigationController?.popViewControllerAnimated(true)
                        self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.goalAddedSuccessfully", comment: ""), alertDescription: "")
                    })
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        Loader.Hide(self)
                        if let message = serverMessage {
                            self.displayAlertMessage(message, alertDescription: "")
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {
        
        //then once it is posted we can delete it
        if let goalUnwrap = self.goalCreated,
            let goalEditLink = goalUnwrap.editLinks {
            Loader.Show(delegate: self)
            APIServiceManager.sharedInstance.deleteUserGoal(goalEditLink) { (success, serverMessage, serverCode) in
                dispatch_async(dispatch_get_main_queue(), {
                    Loader.Hide(self)
                    if serverCode == YonaConstants.serverCodes.OK {
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    } else if serverCode == YonaConstants.serverCodes.cannotRemoveMandatoryGoal {
                        self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.cannotDeleteMandatoryGoalMessage", comment: ""), alertDescription: "")
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            if let message = serverMessage {
                                self.displayAlertMessage(message, alertDescription: "")
                            }
                        })
                    }
                })
            }
        }
    }
}

private extension Selector {
    
    static let back = #selector(TimeFrameNoGoChallengeViewController.back(_:))
    
}
