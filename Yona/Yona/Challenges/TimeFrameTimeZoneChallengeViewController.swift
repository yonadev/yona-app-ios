//
//  TimeFrameTimeZoneChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

struct ToFromDate {
    private static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var fromDate:NSDate = NSDate()
    var toDate: NSDate = NSDate()
}

protocol TimeZoneChallengeDelegate: class {
    func callGoalsMethod()
}

class TimeFrameTimeZoneChallengeViewController: BaseViewController, DeleteTimezoneCellDelegateProtocol {
    
    weak var delegate: TimeZoneChallengeDelegate?
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var timeZoneInstructions: UILabel!
    @IBOutlet weak var timezoneChallengeTitle: UILabel!
    @IBOutlet weak var timezoneChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var timezoneChallengeMainTitle: UILabel!
    @IBOutlet weak var deleteGoalButton: UIBarButtonItem!
    
    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    var isFromActivity :Bool?
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var timeInterval: Int = 15
    
    var zonesArrayDate = [ToFromDate]()
    var zonesArrayString = [String]()
    var datePickerView: UIView?
    var picker: YonaCustomDatePickerView?
    var activeIndexPath: NSIndexPath?
    var isFromButton: Bool = true
    var tempToFromDate: ToFromDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureDatePickerView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        picker?.hideShowDatePickerView(isToShow: false)
    }
    
    
    // MARK: functions
    private func configureDatePickerView() {
        datePickerView = YonaCustomDatePickerView().loadDatePickerView()
        picker = datePickerView as? YonaCustomDatePickerView
        picker!.configure(onView:self.view, withCancelListener: {
            self.picker?.hideShowDatePickerView(isToShow: false)
            
            if self.picker?.cancelButtonTitle.title == "Prev" {
                self.isFromButton = true
                self.picker?.pickerTitleLabel.title = "From"
                
                if self.activeIndexPath != nil {
                    self.picker?.hideShowDatePickerView(isToShow: true).configureWithTime(self.zonesArrayDate[(self.activeIndexPath?.row)!].fromDate)
                } else {
                    if let fromDate = self.tempToFromDate?.fromDate {
                        self.picker?.hideShowDatePickerView(isToShow: true).configureWithTime(fromDate)
                    }
                }
                self.picker?.cancelButtonTitle.title = "Cancel"
                self.picker?.okButtonTitle.title = "Next"
            }
            
        }) { doneValue in
            self.configureTimeZone(doneValue)
        }
    }
    
    
    func configureView() {
//        if BaseTabViewController.userHasGoals() == false {
//            setTimeBucketTabToDisplay(.noGo, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
//        } else {
            setTimeBucketTabToDisplay(.timeZone, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
//        }
        setChallengeButton.backgroundColor = UIColor.clearColor()
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercaseString, forState: UIControlState.Normal)
        timeZoneInstructions.text = NSLocalizedString("challenges.user.TimeZoneDescription", comment: "")
        
        bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.TimeZoneChallengeDescription", comment: "")
        
        if isFromActivity == true{
            self.timezoneChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clearColor()
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
            } else {
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clearColor()
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
            
            self.timezoneChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            
            zonesArrayDate = (goalCreated?.zones.converToDate())!
            zonesArrayString = zonesArrayDate.convertToString()
            
        }
        if zonesArrayDate.count == 0 {
            setChallengeButton.enabled = false
            setChallengeButton.alpha = 0.5
        }
    }
    
    /**
     Show and hide the picker select values, and validate from and to picker times by looking at if start time is less than end time, if it isn't it gives an error message. If the timezone values are correct the table is updated with the timezones
     
     - parameter doneValue: String The number selected by the user in the picker
     - return none
     */
    private func configureTimeZone(doneValue: NSDate?) {
        if doneValue != nil {
            if tempToFromDate == nil {
                tempToFromDate = ToFromDate()
            }
            if let unWrappedDoneValue = doneValue {
                if isFromButton {
                    tempToFromDate!.fromDate = unWrappedDoneValue
                } else {
                    tempToFromDate!.toDate = unWrappedDoneValue
                    if let unWrappedTempToFromDate = tempToFromDate {
                        
                        if (unWrappedTempToFromDate.toDate).isGreaterThanDate(unWrappedTempToFromDate.fromDate) {
                            if activeIndexPath != nil {
                                zonesArrayDate[(self.activeIndexPath?.row)!] = unWrappedTempToFromDate
                                zonesArrayString = self.zonesArrayDate.convertToString()
                            } else {
                                zonesArrayDate.append(unWrappedTempToFromDate)
                                zonesArrayString = self.zonesArrayDate.convertToString()
                            }
                        } else {
                            displayAlertMessage("To time must be greater than From time", alertDescription: "")
                        }
                    }
                }
            }
        }
        
        picker?.hideShowDatePickerView(isToShow: false)
        
        if isFromButton {
            if (activeIndexPath != nil) {
                picker?.hideShowDatePickerView(isToShow: true).configureWithTime(zonesArrayDate[(self.activeIndexPath?.row)!].toDate)
            } else {
                picker?.hideShowDatePickerView(isToShow: true).configureWithTime(NSDate().dateRoundedDownTo15Minute())
            }
            
            picker?.pickerTitleLabel("To")
            picker?.okButtonTitle.title = "Done"
            picker?.cancelButtonTitle.title = "Prev"
            isFromButton = false
        } else {
            activeIndexPath = nil
            if self.zonesArrayString.count > 0 {
                self.setChallengeButton.enabled = true
                self.setChallengeButton.alpha = 1.0
                self.tableView.reloadData()
            }
        }
    }
    
    func tableReload(){
        tableView.reloadData()
    }
    
    // MARK: - DeleteCellDelegate
    
    func deleteTimezone(cell: TimeZoneTableViewCell) {
        if let indexPath = cell.indexPath {
            self.tableView.beginUpdates()
            self.zonesArrayString.removeAtIndex(indexPath.row)
            self.zonesArrayDate.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if self.zonesArrayDate.count == 0 {
                picker?.hideShowDatePickerView(isToShow: false)
                self.setChallengeButton.enabled = false
                self.setChallengeButton.alpha = 0.5
            }
            self.tableView.endUpdates()
            activeIndexPath = nil
            self.delegate?.callGoalsMethod()
            updateTimezone()
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector.tableReload, userInfo: nil, repeats: false)
        }
    }
    
    // MARK: - TableViewDelegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zonesArrayString.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TimeZoneTableViewCell = tableView.dequeueReusableCellWithIdentifier("timeZoneCell", forIndexPath: indexPath) as! TimeZoneTableViewCell
        cell.timezoneCellDelegate = self
        cell.indexPath = indexPath
        let s: String = zonesArrayString[indexPath.row]
        cell.configureWithFromTime(s.dashRemoval()[0], toTime: s.dashRemoval()[1], fromButtonListener: { (cell) in
            
            self.activeIndexPath = indexPath
            self.isFromButton = true
            self.picker?.pickerTitleLabel("From")
            self.picker?.okButtonTitle.title = "Next"
            self.picker?.cancelButtonTitle.title = "Cancel"
            self.picker?.hideShowDatePickerView(isToShow: (cell.editingStyle ==  UITableViewCellEditingStyle.Delete ? false:true)).configureWithTime(self.zonesArrayDate[indexPath.row].fromDate)
        }) { (cell) in
            self.configureTimeZone(self.picker?.selectedValue)
            self.activeIndexPath = indexPath
            self.isFromButton = false
            self.picker?.pickerTitleLabel("To")
            self.picker?.okButtonTitle.title = "Done"
            self.picker?.cancelButtonTitle.title = "Prev"
            self.picker?.hideShowDatePickerView(isToShow: (cell.editingStyle ==  UITableViewCellEditingStyle.Delete ? false:true)).configureWithTime(self.zonesArrayDate[indexPath.row].toDate)
        }
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.tableView.beginUpdates()
            self.zonesArrayString.removeAtIndex(indexPath.row)
            self.zonesArrayDate.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if self.zonesArrayDate.count == 0 {
                picker?.hideShowDatePickerView(isToShow: false)
                self.setChallengeButton.enabled = false
                self.setChallengeButton.alpha = 0.5
            }
            self.tableView.endUpdates()
            activeIndexPath = nil

            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector.tableReload, userInfo: nil, repeats: false)
        }
    }
}


// MARK: - Actions
extension TimeFrameTimeZoneChallengeViewController {
    
    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func postNewTimeZoneChallengeButtonTapped(sender: AnyObject) {
        self.scrollView.scrollRectToVisible(CGRectMake(0, 0, 10, 10), animated: true)
        if isFromActivity == true {
            addANewTimeZone()
        } else {
            updateTimezone()
        }
    }
    
    @IBAction func addTimeZoneAction(sender: AnyObject) {
        isFromButton = true
        picker?.pickerTitleLabel("From")
        picker?.okButtonTitle.title = "Next"
        picker?.hideShowDatePickerView(isToShow: true).configureWithTime(NSDate().dateRoundedDownTo15Minute())
        picker?.datePicker.minuteInterval = timeInterval
        if view.frame.size.height < 570 {
            scrollView.setContentOffset(CGPointMake(0, 200), animated: true)
        }
    }
    
    @IBAction func deletebuttonTapped(sender: AnyObject) {
        deleteTimezone()
    }
    
    func addANewTimeZone(){
        if let activityCategoryLink = activitiyToPost?.selfLinks {
            
            let bodyTimeZoneSocialGoal = [ "@type": "TimeZoneGoal", YonaConstants.jsonKeys.linksKeys: [
                YonaConstants.jsonKeys.yonaActivityCategory: [YonaConstants.jsonKeys.hrefKey: activityCategoryLink]
                ],
                                           YonaConstants.jsonKeys.zones: zonesArrayString
            ];
            Loader.Show()
            GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal as! BodyDataDictionary, onCompletion: {
                (success, serverMessage, serverCode, goal, goals, err) in
                Loader.Hide()
                if success {
                    self.delegate?.callGoalsMethod()
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                    NSUserDefaults.standardUserDefaults().synchronize()
                } else {
                    if let message = serverMessage {
                        self.displayAlertMessage(message, alertDescription: "")
                    }
                }
            })
        }
    }
    
    func updateTimezone() {
        //Integrate Edit
        if let activityCategoryLink = goalCreated?.activityCategoryLink {
            let updatedBodyTimeZoneSocialGoal = [
                "@type": "TimeZoneGoal",
                YonaConstants.jsonKeys.linksKeys: [
                    YonaConstants.jsonKeys.yonaActivityCategory: [YonaConstants.jsonKeys.hrefKey: activityCategoryLink]
                ],
                YonaConstants.jsonKeys.zones: zonesArrayString
            ];
            Loader.Show()
            
            GoalsRequestManager.sharedInstance.updateUserGoal(goalCreated?.editLinks, body: updatedBodyTimeZoneSocialGoal as! BodyDataDictionary, onCompletion: { (success, serverMessage, server, goal, goals, error) in
                Loader.Hide()
                if success {
                    self.delegate?.callGoalsMethod()
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    
                } else { //only one timezone delete the goal
                    self.deleteTimezone()
                }
            })
        }
    }
    
    func deleteTimezone() {
        //then once it is posted we can delete it
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
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.displayAlertMessage(NSLocalizedString("challenges.addBudgetGoal.deletedGoalMessage", comment: ""), alertDescription: "")
                }
            }
        }
    }
}


private extension Selector {
    static let back = #selector(TimeFrameTimeZoneChallengeViewController.back(_:))
    
    static let tableReload = #selector(TimeFrameTimeZoneChallengeViewController.tableReload)
}
