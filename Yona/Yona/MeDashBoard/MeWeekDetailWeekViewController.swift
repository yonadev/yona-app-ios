//
//  MeWeekDetailWeekViewController.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class MeWeekDetailWeekViewController: UIViewController, YonaButtonsTableHeaderViewProtocol {
    
    var weeks : [WeekSingleActivityGoal]?
    var currentIndex = 0
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Social", comment: "")
        registreTableViewCells()
            
    }

    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
    }

    
    
    // MARK: - tableview Override
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
        
        let cell: WeekScoreControlCell = tableView.dequeueReusableCellWithIdentifier("WeekScoreControlCell", forIndexPath: indexPath) as! WeekScoreControlCell
            
            cell.setSingleActivity(weeks![currentIndex])
        return cell
        }
        
        return UITableViewCell(frame: CGRectZero)

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
            cell.delegate = self
            cell.headerTextLabel.text = NSLocalizedString("This week", comment: "")
            if currentIndex == 0 && weeks?.count > 1{
               cell.configureAsFirst()
            } else if currentIndex == weeks?.count && weeks?.count > 1 {
               cell.configureAsLast()
            } else if weeks?.count == 1 {
               cell.configureWithNone()
            } else {
                cell.configureWithBoth()
            }
        return cell
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 126
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        }
        return 0.0
    }

    
    //MARK: Protocol implementation
    func leftButtonPushed(){
        currentIndex += 1
        tableView.reloadData()
    }
    func rightButtonPushed() {
        currentIndex -= 1
        tableView.reloadData()
    
    }

}