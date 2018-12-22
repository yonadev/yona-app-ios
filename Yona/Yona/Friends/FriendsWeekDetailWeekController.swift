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
        self.comments = []
        self.sendCommentFooter!.alpha = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsWeekDetailWeekController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.row == detailRows.activity.rawValue {
            if initialObject!.goalType == GoalType.BudgetGoalString.rawValue {
                cellHeight = 165
            } else if initialObject!.goalType == GoalType.NoGoGoalString.rawValue {
                cellHeight = 0
            } else if initialObject!.goalType == GoalType.TimeZoneGoalString.rawValue {
                cellHeight = 0
            }
        }
        if indexPath.row == detailRows.spreadCell.rawValue {
            cellHeight = 165
            
        }
        return CGFloat(cellHeight)
        
    }
    
//    func didSelectDayInWeek(goal: SingleDayActivityGoal, aDate : NSDate) {
//        
//        weekDayDetailLink = goal.yonadayDetails
//        performSegueWithIdentifier(R.segue.meDashBoardMainViewController.showDayDetail, sender: self)
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            
            if indexPath.row == detailRows.weekoverview.rawValue {
                let cell: WeekScoreControlCell = tableView.dequeueReusableCell(withIdentifier: "WeekScoreControlCell", for: indexPath) as! WeekScoreControlCell
                
                if let data = week[currentWeek.yearWeek]  {
                    cell.setSingleActivity(data ,isScore: shouldAnimate(indexPath))
                }
                return cell
                
            }
            
            if indexPath.row == detailRows.activity.rawValue {
                if let data = week[currentWeek.yearWeek]  {
                    if self.goalType != GoalType.NoGoGoalString.rawValue && data.goalType != GoalType.TimeZoneGoalString.rawValue{
                        let cell: TimeBucketControlCell = tableView.dequeueReusableCell(withIdentifier: "TimeBucketControlCell", for: indexPath) as! TimeBucketControlCell
                        cell.setWeekActivityDetailForView(data, animated: shouldAnimate(indexPath))
                        return cell
                    }
                }
            }
            
            if indexPath.row == detailRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCell(withIdentifier: "SpreadCell", for: indexPath) as! SpreadCell
                if let data = week[currentWeek.yearWeek]  {
                    cell.setWeekActivityDetailForView(data, animated: shouldAnimate(indexPath))
                }
                return cell
            }
        }
        if let data = week[currentWeek.yearWeek]  {
            self.sendCommentFooter!.alpha = data.commentLink != nil ? 1 : 0
            if data.messageLink != nil && indexPath.section == 1 {
                let comment = self.comments[indexPath.row]
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentControlCell", for: indexPath) as? CommentControlCell {
                    cell.setBuddyCommentData(comment)
                    cell.indexPath = indexPath
                    cell.commentDelegate = self
                    if data.commentLink != nil {
                        cell.replyToComment.isHidden = true
                        self.sendCommentFooter!.postCommentLink = data.commentLink
                    } else if comment.replyLink != nil {
                        cell.replyToComment.isHidden = false
                        self.sendCommentFooter!.postReplyLink = comment.replyLink
                    }
                    return cell
                }
            }
        }
        return UITableViewCell(frame: CGRect.zero)
        
    }
    
    override func loadData (_ typeToLoad : loadType = .own) {
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
