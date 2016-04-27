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
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var maxDurationMinutes: Int = 10
    
    var zonesArray = [String]()
    var datePickerView: UIView?
    var picker: YonaCustomDatePickerView?
    var activeIndexPath: NSIndexPath?
    var isFromButton: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        })
        configureDatePickerView()
        
        footerGradientView.colors = [UIColor.yiWhiteThreeColor(), UIColor.yiWhiteTwoColor()]
        
        self.setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        
        self.bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        self.timezoneChallengeMainTitle.text = NSLocalizedString("challenges.addBudgetGoal.TimeZoneChallengeMainTitle", comment: "")
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.TimeZoneChallengeDescription", comment: "")
        
        if isFromActivity == true{
            self.timezoneChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.deleteGoalButton.hidden = false
            } else {
                self.deleteGoalButton.hidden = true
            }
            self.timezoneChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            zonesArray = (goalCreated?.zonesStore)!
        }
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func postNewTimeZoneChallengeButtonTapped(sender: AnyObject) {
        print("integrate post  challenge")
        if isFromActivity == true {
            
            if let activityCategoryLink = activitiyToPost?.selfLinks! {
                
                let bodyTimeZoneSocialGoal = [
                    "@type": "TimeZoneGoal",
                    "_links": [
                        "yona:activityCategory": ["href": activityCategoryLink]
                    ],
                    "zones": zonesArray
                ];
                
                APIServiceManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal as! BodyDataDictionary, onCompletion: {
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
        }else {
            
        }
    }
    
    @IBAction func addTimeZoneAction(sender: AnyObject) {
        zonesArray.append("10:00-10:00")
        self.isFromButton = true
        self.picker?.pickerTitleLabel("From")
        self.picker?.hideShowDatePickerView(isToShow: true)
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
    
    // MARK: functions
    func configureDatePickerView() {
        
        datePickerView = YonaCustomDatePickerView().loadDatePickerView()
        picker = datePickerView as? YonaCustomDatePickerView
        
        picker!.configure(onView:self.view, withCancelListener: {
            self.picker?.hideShowDatePickerView(isToShow: false)
        }) { (doneValue) in
            let tempArr: String?
            if (self.activeIndexPath != nil) {
                if doneValue != "" {
                    tempArr = self.generateTimeZoneArray(isFrom: self.isFromButton, fromToValue: self.zonesArray[(self.activeIndexPath?.row)!], withDoneValue: doneValue)
                    self.zonesArray[(self.activeIndexPath?.row)!] = tempArr!
                    print("************** TempArr \(tempArr)")
                }
            } else {
                if doneValue != "" {
                    tempArr = self.generateTimeZoneArray(isFrom: self.isFromButton, fromToValue: self.zonesArray[self.zonesArray.endIndex - 1], withDoneValue: doneValue)
                    self.zonesArray[self.zonesArray.endIndex - 1] = tempArr!
                    print("************** TempArr \(tempArr)")
                }
            }
            
            
            
            self.picker?.hideShowDatePickerView(isToShow: false)
            
            
            if self.isFromButton {
                self.picker?.hideShowDatePickerView(isToShow: true)
                self.picker?.pickerTitleLabel("To")
                self.isFromButton = false
            } else {
                self.activeIndexPath = nil
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            print("Value updated \(self.zonesArray)")
        }
    }
    
    func generateTimeZoneArray(isFrom iFrom: Bool, fromToValue ft: String, withDoneValue: String) -> String {
        let arr = ft.dashRemoval()
        var fromValue = arr[0]
        var toValue = arr[1]
        
        if iFrom {
            fromValue = withDoneValue
        } else {
            toValue = withDoneValue
        }
        
        return "\(fromValue)-\(toValue)"
        
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return zonesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TimeZoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("timeZoneCell", forIndexPath: indexPath) as! TimeZoneTableViewCell
        let s: String = zonesArray[indexPath.row]
        cell.configureWithFromTime(s.dashRemoval()[0], toTime: s.dashRemoval()[1], fromButtonListener: { (cell) in
            print("From Button Clicked in cell")
            self.activeIndexPath = indexPath
            self.isFromButton = true
            self.picker?.pickerTitleLabel("From")
            self.picker?.hideShowDatePickerView(isToShow: true)
        }) { (cell) in
            print("to Button Clicked in cell")
            self.activeIndexPath = indexPath
            self.isFromButton = false
            self.picker?.hideShowDatePickerView(isToShow: true)
        }
        cell.rowNumber.text = String(indexPath.row + 1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.zonesArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            print(self.zonesArray)
            if self.zonesArray.count == 0 {
                self.setChallengeButton.enabled = false
                self.setChallengeButton.alpha = 0.5
            }
        }
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

