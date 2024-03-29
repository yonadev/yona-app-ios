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
    @IBOutlet weak var appList: UILabel!
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: String = "0"
    var scaledMinutes: Float = 5
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let activityName = self.goalCreated?.GoalName{
//            ActivitiesRequestManager.sharedInstance.getActivityApplications(activityName, onCompletion: { (success, message, code, apps, error) in
//                if success {
//                    self.appList.text = apps
//                }
//            })
//        } else if let activityName = self.activitiyToPost?.activityCategoryName {
//            ActivitiesRequestManager.sharedInstance.getActivityApplications(activityName, onCompletion: { (success, message, code, apps, error) in
//                if success {
//                    self.appList.text = apps
//                }
//            })
//        }
        
        setTimeBucketTabToDisplay(.budget, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        setChallengeButton.backgroundColor = UIColor.clear
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().cgColor

        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercased(), for: UIControl.State())
        self.timeZoneLabel.text = NSLocalizedString("challenges.addBudgetGoal.budgetLabel", comment: "")
        self.minutesPerDayLabel.text = NSLocalizedString("challenges.addBudgetGoal.minutesPerDayLabel", comment: "")
        //self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")

        
        if let maxDurationMinutesUnwrapped = goalCreated?.maxDurationMinutes {
            maxDurationMinutes = String(Int(Float(maxDurationMinutesUnwrapped) / scaledMinutes))
        }
        
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.budgetChallengeDescription", comment: "")
        
        self.navigationItem.rightBarButtonItem = nil
        if isFromActivity == true {
            self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
            self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.updateValues()
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
            } else {
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
            self.budgetChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        }
        
        self.updateValues()
    }
    
    func listActivities(_ activities: [String]){
        let activityApps = activities
        var appString = ""
        for activityApp in activityApps as [String] {
            appString += "" + activityApp + ", "
        }
        self.appList.text = appString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let str = activitiyToPost?.activityDescription {
            appList.text = str
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "TimeFrameBudgetChallengeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    // MARK: - functions
   
    func updateValues()
    {
        self.minutesLabel.text = String(Int(maxDurationMinutes)! * Int(scaledMinutes))
        self.minutesSlider.value = Float(maxDurationMinutes)!
        if self.minutesSlider.value > 0{
            setChallengeButton.alpha = 1.0
            self.setChallengeButton.isEnabled = true
        }else{
            setChallengeButton.alpha = 0.0
            self.setChallengeButton.isEnabled = false
        }
    }
    
    // MARK: - Actions
    @IBAction func back(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionTimeFrameBudgetChallengeViewController", label: "Back from time budget challenge page", value: nil).build() as? [AnyHashable: Any])
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func minutesDidChange(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "minutesDidChange", label: "Change minutes", value: nil).build() as? [AnyHashable: Any])
        
        maxDurationMinutes = String(Int(minutesSlider.value))
        self.updateValues()
    }
    @IBAction func postNewBudgetChallengeButtonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "postNewBudgetChallengeButtonTapped", label: "Post new budget challenge", value: nil).build() as? [AnyHashable: Any])
        
        if isFromActivity == true {
            if let activityCategoryLink = activitiyToPost?.selfLinks! {
                let bodyBudgetGoal: [String: AnyObject] = [
                    "@type": "BudgetGoal" as AnyObject,
                    "_links": ["yona:activityCategory":
                        ["href": activityCategoryLink]
                    ] as AnyObject,
                    "maxDurationMinutes": String(Int(Float(maxDurationMinutes)! * scaledMinutes)) as AnyObject
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
                        self.navigationController?.popToRootViewController(animated: true)
                        UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                        UserDefaults.standard.synchronize()
                        
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
                    "@type": "BudgetGoal" as AnyObject,
                    "_links": ["yona:activityCategory":
                        ["href": activityCategoryLink]
                    ] as AnyObject,
                    "maxDurationMinutes": String(Int(Float(maxDurationMinutes)! * scaledMinutes)) as AnyObject
                ]
                Loader.Show()
                GoalsRequestManager.sharedInstance.updateUserGoal(goalCreated?.editLinks, body: bodyBudgetGoal, onCompletion: { (success, serverMessage, server, goal, goals, error) in
                    Loader.Hide()
                    
                    if success {
                        self.delegate?.callGoalsMethod()
                        if let goalUnwrap = goal {
                            self.goalCreated = goalUnwrap
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    } else {
                        if let message = serverMessage {
                            self.displayAlertMessage(message, alertDescription: "")
                        }
                    }
                })
            }
        }
    }
  
    
    @IBAction func deletebuttonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "deletebuttonTapped", label: "Delete time bucket challenge", value: nil).build() as? [AnyHashable: Any])
        
        if #available(iOS 8, *)  {
            let alert = UIAlertController(title: NSLocalizedString("addfriend.alert.title.text", comment: ""), message: NSLocalizedString("challenges.timezone.deletetimezonemessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: {void in
                self.deleteGoal()
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertView(title: NSLocalizedString("addfriend.alert.title.text", comment: ""), message: NSLocalizedString("challenges.timezone.deletetimezonemessage", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("cancel", comment: ""), otherButtonTitles: NSLocalizedString("OK", comment: "") )
            
            alert.show()
        }
    
    }
    
    func alertView( _ alertView: UIAlertView,clickedButtonAt buttonIndex: Int){
        
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
                        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                    }
                    self.delegate?.callGoalsMethod()
                    self.navigationController?.popToRootViewController(animated: true)
                    
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
