
//
//  MeDetailDayViewController.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


enum detailWeekRows : Int  {
    case activity = 0
    case spreadCell

}

class MeDayDetailViewController: UIViewController, YonaButtonsTableHeaderViewProtocol  {
 
    @IBOutlet weak var tableView : UITableView!
    var correctToday = NSDate()
    var singleDayData : [String: DaySingleActivityDetail] = [:]
    var dayData : DaySingleActivityDetail?
    var activityGoal : ActivitiesGoal?
    var initialObjectLink : String?
    var goalName : String?
    var currentDate : NSDate = NSDate()
    var currentDay : String?
    var nextLink : String?
    var prevLink : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let activityGoal = activityGoal {
            initialObjectLink = activityGoal.dayDetailLinks
            currentDate = activityGoal.date
            goalName = activityGoal.goalName
        }
        registreTableViewCells()
    }
    
    func registreTableViewCells () {
        
        var nib = UINib(nibName: "SpreadCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SpreadCell")
        
        nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "TimeZoneControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeZoneControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        correctToday = NSDate().dateByAddingTimeInterval(60*60*24)

        self.loadData(.own)
        self.navigationItem.title = goalName


    }
    
    //MARK: Protocol implementation
    func leftButtonPushed(){
        loadData(.prev)
    }
    func rightButtonPushed() {
        loadData(.next)
    }
    
    func loadData (typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        Loader.Show()
        
        if typeToLoad == .own {
            if let path = initialObjectLink {
                ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                        }
                        
                        Loader.Hide()
                        self.tableView.reloadData()
                        
                    } else {
                        Loader.Hide()
                    }
                })
            }
        }
        else if typeToLoad == .prev {
                if let path = dayData!.prevLink {
                    ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                        if success {
                            
                            if let data = dayActivity {
                                self.currentDate = data.date!
                                self.currentDay = data.dayOfWeek
                                self.dayData  = data
                            }
                            
                            Loader.Hide()
                            self.tableView.reloadData()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
            
        }
        else if typeToLoad == .next {
                if let path = dayData!.nextLink {
                    ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                        if success {
                            
                            if let data = dayActivity {
                                self.currentDate = data.date!
                                self.currentDay = data.dayOfWeek
                                self.dayData  = data
                            }
                            
                            Loader.Hide()
                            self.tableView.reloadData()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
        }
        
        Loader.Hide()
        self.tableView.reloadData()
        
    }
    
// MARK: - tableview Override
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.row == detailWeekRows.activity.rawValue {
            if activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                cellHeight = 165
            } else if activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                cellHeight = 85
            } else if activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                cellHeight = 165
            }
        }
        return CGFloat(cellHeight)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        }
        return 0.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dayData != nil {
            return 2
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if indexPath.row == detailWeekRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCellWithIdentifier("SpreadCell", forIndexPath: indexPath) as! SpreadCell
                if let data = dayData  {
                    cell.setDayActivityDetailForView(data, animated: true)
                }
                // cell.setUpView(activityGoal)
                return cell
                
            }
            if indexPath.row == detailWeekRows.activity.rawValue {

                if activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                    cell.setDataForView(activityGoal!, animated: true)
                    return cell
                } else if activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    let cell: TimeZoneControlCell = tableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                    cell.setDataForView(activityGoal!, animated: true)
                    return cell
                } else if activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    let cell: NoGoCell = tableView.dequeueReusableCellWithIdentifier("NoGoCell", forIndexPath: indexPath) as! NoGoCell
                    cell.setDataForView(activityGoal!)
                    return cell
                }
                
            }

//        }
        
        return UITableViewCell(frame: CGRectZero)
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
            cell.delegate = self

            if currentDate.isToday() {
                cell.headerTextLabel.text = NSLocalizedString("today", comment: "")
            } else if currentDate.isYesterday() {
                cell.headerTextLabel.text = NSLocalizedString("yesterday", comment: "")
            } else {
                cell.headerTextLabel.text = currentDate.dayMonthDateString()
            }
            
            //if date prievious to that show
            if let data = dayData {
                var next = false
                var prev = false
                cell.configureWithNone()
                if let _ = data.nextLink  {
                    next = true
                    cell.configureAsLast()
                }
                if let _ = data.prevLink  {
                    prev = true
                    cell.configureAsFirst()
                }
                if next && prev {
                    cell.configureWithBoth()
                }
                
            }
            
            return cell
        }
        return nil
    }

}