//
//  TimeFrameNoGoChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

protocol NoGoChallengeDelegate: class {
    func callGoalsMethod()
}

class TimeFrameNoGoChallengeViewController: BaseViewController ,UIAlertViewDelegate {
    
    weak var delegate: NoGoChallengeDelegate?
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var setChallengeButton: UIButton!
    @IBOutlet weak var budgetChallengeTitle: UILabel!
    @IBOutlet weak var budgetChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var deleteGoalButton: UIBarButtonItem!
    @IBOutlet var headerImage: UIImageView!
    @IBOutlet weak var appList: UILabel!

    @IBOutlet var footerGradientView: GradientLargeView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let activityName = self.goalCreated?.GoalName{
//            ActivitiesRequestManager.sharedInstance.getActivityApplications(activityName, onCompletion: { (success, message, code, apps, error) in
//                if success {
//                    self.appList.text = apps
//                } else {
//                    self.appList.text = ""
//                }
//            })
//        } else if let activityName = self.activitiyToPost?.activityCategoryName {
//            ActivitiesRequestManager.sharedInstance.getActivityApplications(activityName, onCompletion: { (success, message, code, apps, error) in
//                if success {
//                    self.appList.text = apps
//                } else {
//                    self.appList.text = ""
//                }
//            })
//        }
        
        setTimeBucketTabToDisplay(.noGo, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        setChallengeButton.backgroundColor = UIColor.clear
        setChallengeButton.layer.cornerRadius = setChallengeButton.frame.size.height/2
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().cgColor
        
        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercased(), for: UIControl.State())
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.NoGoChallengeDescription", comment: "")
        if isFromActivity == true {
            setChallengeButton.isEnabled = true
            setChallengeButton.alpha = 1.0
            self.budgetChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        } else {
            setChallengeButton.isEnabled = false
            setChallengeButton.alpha = 0.5
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.white
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            self.budgetChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.budgetChallengeDescription.text = String(format: localizedString, activityName)
            }
        }
        
        self.headerImage.image = UIImage(named: "icnChallengeNogo")
        //self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let str = activitiyToPost?.activityDescription {
            appList.text = str
        }

        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "TimeFrameNoGoChallengeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
    
    func listActivities(_ activities: [String]){
        let activityApps = activities
        var appString = ""
        for activityApp in activityApps as [String] {
            appString += "" + activityApp + ", "
        }
        self.appList.text = appString
    }
    
    // MARK: - Actions
    @IBAction func back(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionTimeFrameNoGoChallengeViewController", label: "Back from no go challenge page", value: nil).build() as! [AnyHashable: Any])
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func postNewNoGoChallengeButtonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "postNewNoGoChallengeButtonTapped", label: "Post No Go Challenge", value: nil).build() as! [AnyHashable: Any])
        
        if let activityCategoryLink = activitiyToPost?.selfLinks! {
            let bodyBudgetGoal: [String: AnyObject] = [
                "@type": "BudgetGoal" as AnyObject,
                "_links": ["yona:activityCategory":
                    ["href": activityCategoryLink]
                ]as AnyObject,
                "maxDurationMinutes": String(maxDurationMinutes) as AnyObject
            ]
            Loader.Show()
            GoalsRequestManager.sharedInstance.postUserGoals(bodyBudgetGoal, onCompletion: {
                (success, serverMessage, serverCode, goal, goals, err) in
                Loader.Hide()
                if success {
                    self.delegate?.callGoalsMethod()
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }

                    self.navigationController?.popViewController(animated: true)
                    UserDefaults.standard.set(true, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                    UserDefaults.standard.synchronize()
                } else {
                    if let message = serverMessage {
                        self.displayAlertMessage(message, alertDescription: "")
                    }
                    
                }
            })
        }
    }
    
    @IBAction func deletebuttonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "deletebuttonTappedNoGo", label: "Delete No Go Challenge", value: nil).build() as! [AnyHashable: Any])
        
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
        
        //then once it is posted we can delete it
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
                    
                    self.navigationController?.popViewController(animated: true)
                    
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
    
    static let back = #selector(TimeFrameNoGoChallengeViewController.back(_:))
    
}
