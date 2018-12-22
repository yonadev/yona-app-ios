//
//  TimeFrameTimeZoneChallengeViewController.swift
//  Yona
//
//  Created by Chandan on 19/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


struct ToFromDate {
    fileprivate static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var fromDate:Date = Date()
    var toDate: Date = Date()
}

protocol TimeZoneChallengeDelegate: class {
    func callGoalsMethod()
}

class TimeFrameTimeZoneChallengeViewController: BaseViewController, DeleteTimezoneCellDelegateProtocol, UIAlertViewDelegate {
    
    weak var delegate: TimeZoneChallengeDelegate?
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var setChallengeButton: UIButton!
    @IBOutlet weak var timezoneChallengeTitle: UILabel!
    @IBOutlet weak var timezoneChallengeDescription: UILabel!
    @IBOutlet weak var bottomLabelText: UILabel!
    @IBOutlet weak var timezoneChallengeMainTitle: UILabel!
    @IBOutlet weak var deleteGoalButton: UIBarButtonItem!
    @IBOutlet weak var appList: UILabel!

    @IBOutlet var footerGradientView: GradientView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    var isFromActivity :Bool?
    var isSaved :Bool = true
    var activitiyToPost: Activities?
    var goalCreated: Goal?
    var timeInterval: Int = 15
    
    var zonesArrayDate = [ToFromDate]()
    var zonesArrayString = [String]()
    var datePickerView: UIView?
    var picker: YonaCustomDatePickerView?
    var activeIndexPath: IndexPath?
    var isFromButton: Bool = true
    var tempToFromDate: ToFromDate?
    
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
        
        configureView()
        configureDatePickerView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let str = activitiyToPost?.activityDescription {
            appList.text = str
        }

        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "TimeFrameTimeZoneChallengeViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        picker?.hideShowDatePickerView(isToShow: false)
    }
    
    
    // MARK: functions
    fileprivate func configureDatePickerView() {
        datePickerView = YonaCustomDatePickerView().loadDatePickerView()
        picker = datePickerView as? YonaCustomDatePickerView
        picker!.configure(onView:self.view, withCancelListener: {
            self.picker?.hideShowDatePickerView(isToShow: false)
            
            if self.picker?.cancelButtonTitle.title == NSLocalizedString("challenge-prev", comment: "") {
                self.isFromButton = true
                self.picker?.pickerTitleLabel.title = NSLocalizedString("from", comment: "")
                
                if self.activeIndexPath != nil {
                    self.picker?.hideShowDatePickerView(isToShow: true).configureWithTime(self.zonesArrayDate[(self.activeIndexPath?.row)!].fromDate)
                } else {
                    if let fromDate = self.tempToFromDate?.fromDate {
                        self.picker?.hideShowDatePickerView(isToShow: true).configureWithTime(fromDate)
                    }
                }
                self.picker?.cancelButtonTitle.title = NSLocalizedString("challenge-cancel", comment: "")
                self.picker?.okButtonTitle.title = NSLocalizedString("challenge-next", comment: "")
            }
            
        }) { doneValue in
            
            self.configureTimeZone(doneValue as Date)
        }
    }
    
    
    func configureView() {
        setTimeBucketTabToDisplay(.timeZone, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)

        setChallengeButton.backgroundColor = UIColor.clear
        setChallengeButton.layer.cornerRadius = 25.0
        setChallengeButton.layer.borderWidth = 1.5
        setChallengeButton.layer.borderColor = UIColor.yiMidBlueColor().cgColor
        footerGradientView.colors = [UIColor.yiWhiteTwoColor(), UIColor.yiWhiteTwoColor()]
        setChallengeButton.setTitle(NSLocalizedString("challenges.addBudgetGoal.setChallengeButton", comment: "").uppercased(), for: UIControl.State())
        
       // bottomLabelText.text = NSLocalizedString("challenges.addBudgetGoal.bottomLabelText", comment: "")
        let localizedString = NSLocalizedString("challenges.addBudgetGoal.TimeZoneChallengeDescription", comment: "")
        
        if isFromActivity == true{
            self.timezoneChallengeTitle.text = activitiyToPost?.activityCategoryName
            if let activityName = activitiyToPost?.activityCategoryName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            if ((goalCreated?.editLinks?.isEmpty) != nil) {
                self.navigationItem.rightBarButtonItem = self.deleteGoalButton
            } else {
                self.navigationItem.rightBarButtonItem?.tintColor? = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
            self.timezoneChallengeTitle.text = goalCreated?.GoalName
            if let activityName = goalCreated?.GoalName {
                self.timezoneChallengeDescription.text = String(format: localizedString, activityName)
            }
            
            zonesArrayDate = (goalCreated?.zones.converToDate())!
            zonesArrayString = zonesArrayDate.convertToString()
            
        }
        if zonesArrayDate.count == 0 {
            setChallengeButton.isEnabled = false
            setChallengeButton.alpha = 0.5
        }
    }
    
    /**
     Show and hide the picker select values, and validate from and to picker times by looking at if start time is less than end time, if it isn't it gives an error message. If the timezone values are correct the table is updated with the timezones
     
     - parameter doneValue: String The number selected by the user in the picker
     - return none
     */
    fileprivate func configureTimeZone(_ doneValue: Date?) {
        self.isSaved = false

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
                            displayAlertMessage(NSLocalizedString("challenges.timezone.totimegreaterwarning", comment: ""), alertDescription: "")
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
                picker?.hideShowDatePickerView(isToShow: true).configureWithTime(Date().dateRoundedDownTo15Minute())
            }
            
            picker?.pickerTitleLabel(NSLocalizedString("to", comment: ""))
            picker?.okButtonTitle.title = NSLocalizedString("challenge-done", comment: "")
            picker?.cancelButtonTitle.title = NSLocalizedString("challenge-prev", comment: "")
            isFromButton = false
        } else {
            if self.zonesArrayString.count > 0 {
                self.setChallengeButton.isEnabled = true
                self.setChallengeButton.alpha = 1.0
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func tableReload(){
        tableView.reloadData()
    }
    
    // MARK: - DeleteCellDelegate
    func deleteTimezone(_ cell: TimeZoneTableViewCell) {
        if let indexPath = cell.indexPath {
            self.isSaved = false
            self.tableView.beginUpdates()
            self.zonesArrayString.remove(at: indexPath.row)
            self.zonesArrayDate.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
            if self.zonesArrayDate.count == 0 {
                picker?.hideShowDatePickerView(isToShow: false)
                self.setChallengeButton.isEnabled = false
                self.setChallengeButton.alpha = 0.5
            }
            self.tableView.endUpdates()
            activeIndexPath = nil
            self.delegate?.callGoalsMethod()
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: Selector.tableReload, userInfo: nil, repeats: false)
        }
    }
    
    // MARK: - TableViewDelegate
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zonesArrayString.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: TimeZoneTableViewCell = tableView.dequeueReusableCell(withIdentifier: "timeZoneCell", for: indexPath) as! TimeZoneTableViewCell
//        if tableView.numberOfRowsInSection(0) == 1 {
//            cell.isPanEnabled = false
//        } else {
//            cell.isPanEnabled = true
//        }
        cell.timezoneCellDelegate = self
        cell.indexPath = indexPath
        let s: String = zonesArrayString[indexPath.row]
        cell.configureWithFromTime(s.dashRemoval()[0], toTime: s.dashRemoval()[1], fromButtonListener: { (cell) in
            
            self.activeIndexPath = indexPath
            self.isFromButton = true
            self.picker?.pickerTitleLabel(NSLocalizedString("from", comment: ""))
            self.picker?.okButtonTitle.title = NSLocalizedString("challenge-next", comment: "")
            self.picker?.cancelButtonTitle.title = NSLocalizedString("challenge-cancel", comment: "")
            self.picker?.hideShowDatePickerView(isToShow: (cell.editingStyle ==  UITableViewCell.EditingStyle.delete ? false:true)).configureWithTime(self.zonesArrayDate[indexPath.row].fromDate)
        }) { (cell) in
            
            self.activeIndexPath = indexPath
            self.configureTimeZone(self.picker?.selectedValue)
            
            self.isFromButton = false
            self.picker?.pickerTitleLabel(NSLocalizedString("to", comment: ""))
            self.picker?.okButtonTitle.title = NSLocalizedString("challenge-done", comment: "")
            self.picker?.cancelButtonTitle.title = NSLocalizedString("challenge-prev", comment: "")
            self.picker?.hideShowDatePickerView(isToShow: (cell.editingStyle ==  UITableViewCell.EditingStyle.delete ? false:true)).configureWithTime(self.zonesArrayDate[indexPath.row].toDate)
        }
        
        return cell
    }
    
}


// MARK: - Actions
extension TimeFrameTimeZoneChallengeViewController {
    
    @IBAction func back(_ sender: AnyObject) {
        if isSaved == false {
            
            self.displayAlertOption(NSLocalizedString("addfriend.alert.title.text", comment: ""), cancelButton: true, alertDescription: NSLocalizedString("challenges.user.TimeZoneNotSaved", comment: ""), onCompletion: { (buttonType) in
                if buttonType == .ok {
                    weak var tracker = GAI.sharedInstance().defaultTracker
                    tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionTimeFrameTimeZoneChallengeViewController", label: "Back from timezone challenge page", value: nil).build() as? [AnyHashable: Any])
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionTimeFrameTimeZoneChallengeViewController", label: "Back from timezone challenge page", value: nil).build() as? [AnyHashable: Any])
            
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func postNewTimeZoneChallengeButtonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "postNewTimeZoneChallengeButtonTapped", label: "Add timezone challenge", value: nil).build() as? [AnyHashable: Any])
        
        self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: true)
        if isFromActivity == true {
            addANewTimeZone()
        } else {
            updateTimezone()
        }
    }
    
    @IBAction func addTimeZoneAction(_ sender: AnyObject) {
        isFromButton = true
        self.isSaved = false
        picker?.pickerTitleLabel(NSLocalizedString("from", comment: ""))
        picker?.okButtonTitle.title = NSLocalizedString("challenge-next", comment: "")
        picker?.hideShowDatePickerView(isToShow: true).configureWithTime(Date().dateRoundedDownTo15Minute())
        picker?.datePicker.minuteInterval = timeInterval
        if view.frame.size.height < 570 {
            scrollView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
        }
        activeIndexPath = nil
    }
    
    @IBAction func deletebuttonTapped(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "deletebuttonTappedTimeZone", label: "Delete timezone challenge", value: nil).build() as? [AnyHashable: Any])
        self.isSaved = false

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
        deleteTimezone()
    }
    
    func addANewTimeZone(){
        if let activityCategoryLink = activitiyToPost?.selfLinks {
            self.isSaved = false

            let bodyTimeZoneSocialGoal = [ "@type": "TimeZoneGoal", YonaConstants.jsonKeys.linksKeys: [
                YonaConstants.jsonKeys.yonaActivityCategory: [YonaConstants.jsonKeys.hrefKey: activityCategoryLink]
                ],
                                           YonaConstants.jsonKeys.zones: zonesArrayString
            ] as [String : Any];
            Loader.Show()
            GoalsRequestManager.sharedInstance.postUserGoals(bodyTimeZoneSocialGoal as BodyDataDictionary, onCompletion: {
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
    
    func updateTimezone() {
        //Integrate Edit
        if let activityCategoryLink = goalCreated?.activityCategoryLink {
            let updatedBodyTimeZoneSocialGoal = [
                "@type": "TimeZoneGoal",
                YonaConstants.jsonKeys.linksKeys: [
                    YonaConstants.jsonKeys.yonaActivityCategory: [YonaConstants.jsonKeys.hrefKey: activityCategoryLink]
                ],
                YonaConstants.jsonKeys.zones: zonesArrayString
            ] as [String : Any];
            Loader.Show()
            isSaved = true
            GoalsRequestManager.sharedInstance.updateUserGoal(goalCreated?.editLinks, body: updatedBodyTimeZoneSocialGoal as BodyDataDictionary, onCompletion: { (success, serverMessage, server, goal, goals, error) in
                Loader.Hide()
                if success {
                    self.isSaved = true
                    self.delegate?.callGoalsMethod()
                    if let goalUnwrap = goal {
                        self.goalCreated = goalUnwrap
                    }
                    if goal?.zones.count <= 1 {
                        self.setChallengeButton.isEnabled = false
                        self.setChallengeButton.alpha = 0.5
                    } else {
                        self.setChallengeButton.isEnabled = true
                        self.setChallengeButton.alpha = 1.0
                    }
                    self.navigationController?.popViewController(animated: true)

                } else { //only one timezone disable save button
                    self.setChallengeButton.isEnabled = false
                    self.setChallengeButton.alpha = 0.5
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
                        UserDefaults.standard.set(false, forKey: YonaConstants.nsUserDefaultsKeys.isGoalsAdded)
                    }
                    self.delegate?.callGoalsMethod()
                    self.navigationController?.popViewController(animated: true)
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
