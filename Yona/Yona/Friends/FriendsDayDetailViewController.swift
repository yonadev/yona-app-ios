//
//  FriendsDayDetailViewController.swift
//  Yona
//
//  Created by Anders Liebl on 03/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum DayDetailSecions : Int{
    case activities = 0
    case comments
}

class FriendsDayDetailViewController : MeDayDetailViewController {

    var buddy : Buddies?
    
    override func registreTableViewCells () {
        super.registreTableViewCells()
        var nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CommentControlCell")
        
        nib = UINib(nibName: "SendCommentControl", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SendCommentControl")
    }

// MARK: - tableview Override
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableView(tableView, viewForHeaderInSection: section)
        
        if section == 1 {
            let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CommentTableHeader") as! CommentTableHeader
            return cell
        }
        
        return nil
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if indexPath.section == 1 {
            let cell: CommentControlCell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as! CommentControlCell
            return cell
        } else if indexPath.section == 2 {
            let cell: SendCommentControl = tableView.dequeueReusableCellWithIdentifier("SendCommentControl") as! SendCommentControl
            return cell
        }
        return UITableViewCell(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        super.numberOfSectionsInTableView(tableView)
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
// MARK: - Load data method
    override func loadData (typeToLoad : loadType = .own) {
        
        Loader.Show()
        
        if typeToLoad == .own {
            if let path = initialObjectLink {
                if let bud = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: bud,onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
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
        }
        else if typeToLoad == .prev {
            if let path = dayData!.prevLink {
                if let bud = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: bud,onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
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
            
        }
        else if typeToLoad == .next {
            if let path = dayData!.nextLink {
                if let bud = buddy {
                    ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: bud ,onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
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
        }
        
        //Loader.Hide()
        self.tableView.reloadData()
    }

}