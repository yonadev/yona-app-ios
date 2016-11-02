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

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let navbarColor1 = navbarColor1,
            let navbarColor = navbarColor {
            self.navigationController?.navigationBar.backgroundColor = navbarColor1
            if let navbar = navigationController?.navigationBar as? GradientNavBar{
                navbar.gradientColor = navbarColor
            }
        }
    }
    
    private func shouldAnimate(cell : NSIndexPath) -> Bool {
        let txt = "\(cell.section)-\(cell.row)"
        
        if animatedCells.indexOf(txt) == nil {
            print("Animated \(txt)")
            animatedCells.append(txt)
            return true
        }
        print("NO animated \(txt)")
        return false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comments = []        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "FriendsDayDetailViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)
        var heightOfHeader : CGFloat = 45
        if section == 1 && self.comments.count > 0{
            heightOfHeader = 45
        }
        return heightOfHeader
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if goalType == GoalType.BudgetGoalString.rawValue || activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 165
                } else if goalType == GoalType.NoGoGoalString.rawValue || activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if goalType == GoalType.TimeZoneGoalString.rawValue || activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == detailDayRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCellWithIdentifier("SpreadCell", forIndexPath: indexPath) as! SpreadCell
                if let data = dayData  {
                    cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                }
                return cell
                
            }
            if indexPath.row == detailDayRows.activity.rawValue {
                
                if goalType == GoalType.BudgetGoalString.rawValue || activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.TimeZoneGoalString.rawValue || activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    let cell: TimeZoneControlCell = tableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.NoGoGoalString.rawValue || activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    let cell: NoGoCell = tableView.dequeueReusableCellWithIdentifier("NoGoCell", forIndexPath: indexPath) as! NoGoCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data)
                    }
                    return cell
                }
                
            }
        } else if self.dayData?.messageLink != nil && indexPath.section == 1 {
            let comment = self.comments[indexPath.row]
            if let cell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as? CommentControlCell {
                cell.setBuddyCommentData(comment)
                cell.indexPath = indexPath
                cell.commentDelegate = self
                if self.dayData?.commentLink != nil {
                    cell.replyToComment.hidden = true
                    self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
                } else if comment.replyLink != nil {
                    cell.replyToComment.hidden = false
                    self.sendCommentFooter!.postReplyLink = comment.replyLink
                }
                return cell
            }
        }
        return UITableViewCell(frame: CGRectZero)
    }
    
    
    override func loadData (typeToLoad : loadType = .own) {
        
        Loader.Show()
        //        size = 4
        //        page = 1
        if typeToLoad == .own {
            if let path = initialObjectLink,
                let aBuddy = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: aBuddy, onCompletion:  {(success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                            self.goalType = data.goalType
                            self.navigationItem.title = self.dayData?.goalName.uppercaseString //only need to do this in the first original data
                            
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
                            }
                            //make sure the commentview has the right link to post comments to
                            if self.dayData?.commentLink != nil {
                                self.sendCommentFooter!.alpha = self.dayData?.commentLink != nil ? 1 : 0
                                self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
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
        else if typeToLoad == .prev {
            if let path = dayData!.prevLink,
                let aBuddy = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: aBuddy, onCompletion:  {(success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
                            }
                            //make sure the commentview has the right link to post comments to
                            if self.dayData?.commentLink != nil {
                                self.sendCommentFooter!.alpha = self.dayData?.commentLink != nil ? 1 : 0
                                self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
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
        else if typeToLoad == .next {
            if let path = dayData!.nextLink,
                let aBuddy = buddy {
                ActivitiesRequestManager.sharedInstance.getBuddyDayActivityDetails(path, date: currentDate, buddy: aBuddy, onCompletion:  {(success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
                            }
                            //make sure the commentview has the right link to post comments to
                            if self.dayData?.commentLink != nil {
                                self.sendCommentFooter!.alpha = self.dayData?.commentLink != nil ? 1 : 0
                                self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
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
        
        //Loader.Hide()
        self.tableView.reloadData()
        
    }

 }