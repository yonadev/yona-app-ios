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

class FriendsDayDetailViewController : MeDayDetailViewController, SendCommentControlProtocol, CommentCellDelegate {

    var buddy : Buddies?
    var comments = [Comment]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
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
        
        return UITableViewCell(frame: CGRectZero)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        if self.dayData?.messageLink != nil && indexPath.section == 1 {
            let cell: CommentControlCell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as! CommentControlCell
            cell.setData(self.comments[indexPath.row])
            cell.indexPath = indexPath
            cell.commentDelegate = self
            return cell
        } else if indexPath.section == 2 {
            let cell: SendCommentControl = tableView.dequeueReusableCellWithIdentifier("SendCommentControl") as! SendCommentControl
            cell.delegate = self
            cell.postGoalLink = self.dayData?.commentLink
            return cell
        }
        return UITableViewCell(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)
        var heightOfHeader : CGFloat = 0
        if section == 1 {
            heightOfHeader = 50
        }
        return heightOfHeader
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        super.numberOfSectionsInTableView(tableView)
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        var numberOfSections = 2
        if section == 1 {
            numberOfSections = self.comments.count // number of comments
        } else if section == 2 {
            numberOfSections = 1
        }
        return numberOfSections
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 165
                } else if activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 165
                }
            }
            
            if indexPath.row == detailDayRows.spreadCell.rawValue{
                cellHeight = 165
            }
        } else if indexPath.section == detailDaySections.comment.rawValue {
            cellHeight = 165
        }
        
        return CGFloat(cellHeight)
    }
    
// MARK: - Load data method
    override func loadData (typeToLoad : loadType = .own) {
        
        Loader.Show()
        
        if let _ = buddy {
        
        if typeToLoad == .own {
            if let path = initialObjectLink {
                if let bud = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: bud,onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                            if let messageLink = data.messageLink {
                                self.getMessageData(messageLink)
                            }
                        }
                        
                        Loader.Hide()
                        self.tableView.reloadData()
                        
                    } else {
                        Loader.Hide()
                    }
                })
                }
            }
            if let messageLink = dayData?.messageLink {
                getMessageData(messageLink)
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
                            if let messageLink = data.messageLink {
                                self.getMessageData(messageLink)
                            }
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
                                if let messageLink = data.messageLink {
                                    self.getMessageData(messageLink)
                                }
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
        } else {
            super.loadData()
        
        }
        //Loader.Hide()
        self.tableView.reloadData()
    }
    
    // MARK: - get comment data
    func getMessageData(commentLink: String?) {
        CommentRequestManager.sharedInstance.getComments(commentLink!, size: 11, page: 0) { (success, comment, comments, serverMessage, serverCode) in
            if success {
                self.comments = []
                if let comments = comments {
                    self.comments = comments
                }
            }
        }
    }
    
    // MARK: - CommentCellDelegate
    func deleteComment(cell: CommentControlCell, comment: Comment){
        let aComment = comment as Comment
        CommentRequestManager.sharedInstance.deleteComment(aComment, onCompletion: { (success, message, code) in
            if success {
                self.comments.removeAtIndex((cell.indexPath?.row)!)

                if let messageLink = self.dayData?.messageLink {
                    self.getMessageData(messageLink)
                }
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    // MARK: - SendCommentControlProtocol
    func textFieldBeginEdit(textField: UITextField, commentTextField: UITextField) {
        if textField == commentTextField {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
        } else {
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
        }
    }
    
    func textFieldEndEdit(commentTextField: UITextField){
        commentTextField.resignFirstResponder()
    }

}