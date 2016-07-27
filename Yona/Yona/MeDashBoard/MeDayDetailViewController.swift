
//
//  MeDetailDayViewController.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class MeDayDetailViewController: UIViewController, YonaButtonsTableHeaderViewProtocol  {
 
    @IBOutlet weak var tableView : UITableView!
    var correctToday = NSDate()
    var singleDayData : [String: DaySingleActivityDetail] = [:]
    var dayData : DaySingleActivityDetail?
    var initialObjectLink : String?
    var initialObject : DaySingleActivityDetail?
    var currentDate : NSDate = NSDate()
    var currentDay : String?
    var nextLink : String?
    var prevLink : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        ActivitiesRequestManager.sharedInstance.getDayActivityDetails(self.initialObjectLink!, date: currentDate, onCompletion: { (success, serverMessage, serverCode, daySingleDetail, err) in
            self.initialObject = daySingleDetail
            if let aDay = self.initialObject {
                if let txt = aDay.dayOfWeek
                {
                    self.navigationItem.title = NSLocalizedString(txt, comment: "")
                }

                self.loadData(.own)
            }
        })
    }
    
    //MARK: Protocol implementation
    func leftButtonPushed(){
        //currentWeek = currentWeek.dateByAddingTimeInterval(-60*60*24*7)
        //tableView.reloadData()
        //loadData(.prev)
    }
    func rightButtonPushed() {
        //currentWeek = currentWeek.dateByAddingTimeInterval(60*60*24*7)
        //tableView.reloadData()
        //loadData(.next)
    }
    
    func loadData (typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        Loader.Show()
        
        if typeToLoad == .own {
            if let data = initialObject  {
                if let path = data.goalLinks {
                    ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                        if success {
                            
                            if let data = dayActivity {
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
        }
        Loader.Hide()
        self.tableView.reloadData()
        
    }
    
// MARK: - tableview Override
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 126
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        }
        return 0.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if indexPath.row == detailRows.activity.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCellWithIdentifier("SpreadCell", forIndexPath: indexPath) as! SpreadCell
                if let data = singleDayData[correctToday.Day]  {
                    cell.setDayActivityDetailForView(data, animated: true)
                }
                // cell.setUpView(activityGoal)
                return cell
                
            }
        
//        if indexPath.section == 0 {
//            
//            if indexPath.row == detailRows.weekoverview.rawValue {
//                let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
//                
//                if let data = week[currentWeek.yearWeek]  {
//                    cell.setSingleActivity(data ,isScore: true)
//                }
//                return cell
//                
//            }
            if indexPath.row == detailRows.activity.rawValue {
                let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                if let data = singleDayData[correctToday.Day]  {
                    cell.setDayActivityDetailForView(data, animated: true)
                }
                // cell.setUpView(activityGoal)
                return cell
                
            }
//
//        }
        
        return UITableViewCell(frame: CGRectZero)
        
    }

}