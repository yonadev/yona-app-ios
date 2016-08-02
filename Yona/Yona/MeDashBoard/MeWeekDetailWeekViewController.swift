//
//  MeWeekDetailWeekViewController.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum detailRows : Int  {
    case weekoverview = 0
    case activity
    case spreadCell
}

class MeWeekDetailWeekViewController: UIViewController, YonaButtonsTableHeaderViewProtocol {
    var initialObject : WeekSingleActivityGoal?
    var week : [String:WeekSingleActivityDetail] = [:]
    var firstWeek :  NSDate = NSDate()
    var currentWeek : NSDate = NSDate()
    var correctToday = NSDate()
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = NSLocalizedString("Social", comment: "")
        registreTableViewCells()
            
    }

    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "SpreadCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SpreadCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()
        correctToday = NSDate().dateByAddingTimeInterval(60*60*24)

        if let aWeek = initialObject {
            if let txt = aWeek.goalName {
                navigationItem.title = NSLocalizedString(txt, comment: "")
            }
            
            loadData(.own)
        }
    }
    
    // MARK: - tableview Override
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {

            if indexPath.row == detailRows.weekoverview.rawValue {
                let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
                
                if let data = week[currentWeek.yearWeek]  {
                    cell.setSingleActivity(data ,isScore: true)
                }
                return cell
            
            }
        
            if indexPath.row == detailRows.activity.rawValue {
                if let data = week[currentWeek.yearWeek]  {
                    if data.goalType != GoalType.NoGoGoalString.rawValue && data.goalType != GoalType.TimeZoneGoalString.rawValue{
                        let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                        cell.setWeekActivityDetailForView(data, animated: true)
                        return cell
                    }
                }
            }
            
            if indexPath.row == detailRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCellWithIdentifier("SpreadCell", forIndexPath: indexPath) as! SpreadCell
                if let data = week[currentWeek.yearWeek]  {
                    cell.setWeekActivityDetailForView(data, animated: true)
                }
                return cell
            }
        }
        return UITableViewCell(frame: CGRectZero)

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
            cell.delegate = self
            
            let other = week[currentWeek.yearWeek]?.date.yearWeek
            let otherDateStart = correctToday.dateByAddingTimeInterval(-60*60*24*7)
            let otherDate = otherDateStart.yearWeek
            
            if correctToday.yearWeek == other {
                cell.headerTextLabel.text = NSLocalizedString("This week", comment: "")
            } else if other == otherDate {
                cell.headerTextLabel.text =  NSLocalizedString("Last week", comment: "")
            } else {
                let dateFormatter : NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                cell.headerTextLabel.text = "\(dateFormatter.stringFromDate(otherDateStart)) - \(dateFormatter.stringFromDate(otherDateStart.dateByAddingTimeInterval(7*60*60*24)))"
            }
           if let data = week[currentWeek.yearWeek] {
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight = 126        
        if indexPath.row == detailRows.activity.rawValue {
            if let initialObject = initialObject {
                if initialObject.goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 165
                } else if initialObject.goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 0
                } else if initialObject.goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 0
                }
            }
        }
        if indexPath.row == detailRows.spreadCell.rawValue {
            cellHeight = 165
            
        }
        return CGFloat(cellHeight)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        }
        return 0.0
    }

    
    //MARK: Protocol implementation
    func leftButtonPushed(){
        //currentWeek = currentWeek.dateByAddingTimeInterval(-60*60*24*7)
        //tableView.reloadData()
        loadData(.prev)
    }
    func rightButtonPushed() {
        //currentWeek = currentWeek.dateByAddingTimeInterval(60*60*24*7)
        //tableView.reloadData()
        loadData(.next)
    }

    
    func loadData (typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        // ALWAYS DOWNLOAD DATA FIRST TIME FOR THE WEEK
        Loader.Show()
        
        if typeToLoad == .own {
            if let data = initialObject  {
                if let path = data.weekDetailLink {
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                        if success {
                            
                            if let data = activitygoals {
                                self.currentWeek = data.date
                                self.week[data.date.yearWeek] = data
                                print (data.date.yearWeek)
                            }
                            
                            Loader.Hide()
                            self.tableView.reloadData()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
            }
        } else  if typeToLoad == .prev {
            if let data = week[currentWeek.yearWeek]  {
                if let path = data.prevLink {
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                        if success {
                            
                            if let data = activitygoals {
                                self.currentWeek = data.date
                                self.week[data.date.yearWeek] = data
                                print (data.date.yearWeek)
                            }
                            
                            Loader.Hide()
                            self.tableView.reloadData()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
            }
        } else  if typeToLoad == .next {
            if let data = week[currentWeek.yearWeek]  {
                if let path = data.nextLink {
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                        if success {
                            
                            if let data = activitygoals {
                                self.currentWeek = data.date
                                self.week[data.date.yearWeek] = data
                                print (data.date.yearWeek)
                            }
                            
                            Loader.Hide()
                            self.tableView.reloadData()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
            }
            
            
        }
        Loader.Hide()
        self.tableView.reloadData()
            
    }
}