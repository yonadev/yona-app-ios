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
        
        nib = UINib(nibName: "SendCommentControlFooter", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "SendCommentControlFooter")

    }
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        sendCommentFooter = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SendCommentControlFooter") as? SendCommentControlFooter
        sendCommentFooter!.delegate = self
        self.commentView.addSubview(sendCommentFooter!)
        self.commentView.hidden = false
    }

// MARK: - tableview Override
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableView(tableView, viewForHeaderInSection: section)
        
        if section == 1 && self.comments.count > 0{
            let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CommentTableHeader") as! CommentTableHeader
            return cell
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)
        var heightOfHeader : CGFloat = 0
        if section == 1 && self.comments.count > 0{
            heightOfHeader = 45
        }
        return heightOfHeader
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        if section == 1 && self.dayData?.commentLink != nil{
//            let cell: SendCommentControlFooter = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SendCommentControlFooter") as! SendCommentControlFooter
//            cell.delegate = self
//            cell.postGoalLink = self.dayData?.commentLink
//            return cell
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 && self.dayData?.commentLink != nil{
//            return 45.0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == detailDayRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCellWithIdentifier("SpreadCell", forIndexPath: indexPath) as! SpreadCell
                if let data = dayData  {
                    cell.setDayActivityDetailForView(data, animated: true)
                }
                return cell
                
            }
            if indexPath.row == detailDayRows.activity.rawValue {
                
                if activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: true)
                    }
                    return cell
                } else if activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    let cell: TimeZoneControlCell = tableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: true)
                    }
                    return cell
                } else if activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    let cell: NoGoCell = tableView.dequeueReusableCellWithIdentifier("NoGoCell", forIndexPath: indexPath) as! NoGoCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data)
                    }
                    return cell
                }
                
            }
        }
        else if self.dayData?.messageLink != nil && indexPath.section == 1 {
            let cell: CommentControlCell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as! CommentControlCell
            cell.setBuddyCommentData(self.comments[indexPath.row])
            cell.indexPath = indexPath
            cell.commentDelegate = self
            cell.replyToComment.hidden = true
            return cell
        }
        return UITableViewCell(frame: CGRectZero)
    }
    
}