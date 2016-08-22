//
//  FriendsWeekDetailWeekController.swift
//  Yona
//
//  Created by Anders Liebl on 03/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsWeekDetailWeekController : MeWeekDetailWeekViewController {
  
    var buddy : Buddies?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sendCommentFooter = tableView.dequeueReusableCellWithIdentifier("SendCommentControl") as? SendCommentControl
//        sendCommentFooter!.delegate = self
//        self.commentView.addSubview(sendCommentFooter!)
        self.sendCommentFooter!.alpha = 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
        if let data = week[currentWeek.yearWeek]  {
            if data.messageLink != nil && indexPath.section == 1 {
                let comment = self.comments[indexPath.row]
                if let cell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as? CommentControlCell {
                    cell.setBuddyCommentData(comment)
                    cell.indexPath = indexPath
                    cell.commentDelegate = self
                    if data.commentLink != nil {
                        cell.replyToComment.hidden = true
                        self.sendCommentFooter!.postCommentLink = data.commentLink
                    } else if comment.replyLink != nil {
                        cell.replyToComment.hidden = false
                        self.sendCommentFooter!.postReplyLink = comment.replyLink
                    }
                    return cell
                }
            }
        }
        return UITableViewCell(frame: CGRectZero)
        
    }
    
    override func loadData (typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        // ALWAYS DOWNLOAD DATA FIRST TIME FOR THE WEEK
        Loader.Show()
        if let theBuddy = buddy {
            if typeToLoad == .own {
                if let data = initialObject  {
                    if let path = data.weekDetailLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                    if let commentsLink = data.messageLink {
                                        self.getComments(commentsLink)
                                    }
                                    if data.commentLink != nil {
                                        self.sendCommentFooter!.postCommentLink = data.commentLink
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
            } else  if typeToLoad == .prev {
                if let data = week[currentWeek.yearWeek]  {
                    if let path = data.prevLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                    if let commentsLink = data.messageLink {
                                        self.getComments(commentsLink)
                                    }
                                    if data.commentLink != nil {
                                        self.sendCommentFooter!.postCommentLink = data.commentLink
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
            } else  if typeToLoad == .next {
                if let data = week[currentWeek.yearWeek]  {
                    if let path = data.nextLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                    if let commentsLink = data.messageLink {
                                        self.getComments(commentsLink)
                                    }
                                    if data.commentLink != nil {
                                        self.sendCommentFooter!.postCommentLink = data.commentLink
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
        }
        Loader.Hide()
        self.tableView.reloadData()
        
    }

}