//
//  TimeFrameTimeZoneChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeFrameTimeZoneChallengeViewController: UIViewController {

    @IBOutlet var gradientView: GradientView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var timezoneChallengeTitle: UILabel!
    @IBOutlet weak var timezoneChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var timezoneChallengeMainTitle: UILabel!
    @IBOutlet weak var deleteGoalButton: UIButton!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: Int = 10

    var zonesArray:NSArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        })
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.timezoneChallengeTitle.text = activitiyToPost?.activityCategoryName
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        self.timezoneChallengeMainTitle.text = NSLocalizedString("challenges.addBudgetGoal.NoGoChallengeMainTitle", comment: "")
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.NoGoChallengeDescription", comment: "")
        if let activityName = activitiyToPost?.activityCategoryName {
            self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
        }

    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    @IBAction func postNewTimeZoneChallengeButtonTapped(sender: AnyObject) {
        print("integrate post  challenge")
        if let activityCategoryLink = activitiyToPost?.selfLinks! {
            
            let bodyTimeZoneSocialGoal = [
                "@type": "TimeZoneGoal",
                "_links": [
                    "yona:activityCategory": ["href": activityCategoryLink]
                ],
                "zones": ["8:00-17:00", "20:00-22:00", "22:00-20:00"]
            ]
            
            
            
            APIServiceManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal, onCompletion: {
                (success, serverMessage, serverCode, goal, err) in
                if success {
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.deleteGoalButton.selected = true
                        self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.goalAddedSuccessfully", comment: ""), alertDescription: "")
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

        //then once it is posted we can delete it
        if let goalUnwrap = self.goalCreated {
            APIServiceManager.sharedInstance.deleteUserGoal(goalUnwrap.goalID!) { (success, serverMessage, serverCode) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.deletedGoalMessage", comment: ""), alertDescription: "")
                })
            }
        }
    }


    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (goalCreated?.zonesStore.count)!
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TimeZoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("timeZoneCell", forIndexPath: indexPath) as! TimeZoneTableViewCell
        let s: String = (goalCreated?.zonesStore[indexPath.row])!
        
        cell.configure((s.dashRemoval()[0], s.dashRemoval()[1]), fromButtonListener: { (cell) in
            print("From Button Clicked in cell")
            
            }) { (cell) in
                print("to Button Clicked in cell")
        }
        
        return cell
    }
    

}


extension String {
    func dashRemoval() -> Array<String> {
        return self.characters.split{$0 == "-"}.map(String.init)
    }
}

private extension Selector {
   
    static let back = #selector(TimeFrameTimeZoneChallengeViewController.back(_:))
    
}

