
//
//  MeDetailDayViewController.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


enum detailDayRows : Int  {
    case activity = 0
    case spreadCell
}

enum detailDayCommentRows : Int  {
    case comment = 0
    case sendComment
}

enum detailDaySections : Int  {
    case activity = 0
    case comment
}

class MeDayDetailViewController: UIViewController, YonaButtonsTableHeaderViewProtocol, SendCommentControlProtocol, CommentCellDelegate  {
 
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
    var hideReplyButton : Bool = false
    
    @IBOutlet weak var commentView: UIView!
    var sendCommentFooter : SendCommentControl?

    var comments = [Comment]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let activityGoal = activityGoal {
            initialObjectLink = activityGoal.dayDetailLinks
            currentDate = activityGoal.date
            goalName = activityGoal.goalName
        }
        registreTableViewCells()
        sendCommentFooter = tableView.dequeueReusableCellWithIdentifier("SendCommentControl") as? SendCommentControl
        sendCommentFooter!.delegate = self
        self.commentView.addSubview(sendCommentFooter!)
        self.commentView.alpha = 0
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
        
        nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CommentControlCell")
        
        nib = UINib(nibName: "SendCommentControl", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SendCommentControl")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        correctToday = NSDate().dateByAddingTimeInterval(60*60*24)

        self.loadData(.own)
        self.navigationItem.title = goalName

    }
    
    //MARK: Protocol implementation
    func leftButtonPushed(){
        self.comments = []
        loadData(.prev)
    }
    func rightButtonPushed() {
        self.comments = []
        loadData(.next)
    }
    
    func loadData (typeToLoad : loadType = .own) {
        
        Loader.Show()
        
        if typeToLoad == .own {
            if let path = initialObjectLink {
                ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate , onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                    if success {
                        
                        if let data = dayActivity {
                            self.currentDate = data.date!
                            self.currentDay = data.dayOfWeek
                            self.dayData  = data
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
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
                if let path = dayData!.prevLink {
                    ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                        if success {
                            
                            if let data = dayActivity {
                                self.currentDate = data.date!
                                self.currentDay = data.dayOfWeek
                                self.dayData  = data
                                if let commentsLink = data.messageLink {
                                    self.getComments(commentsLink)
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
                if let path = dayData!.nextLink {
                    ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate, onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                        if success {
                            
                            if let data = dayActivity {
                                self.currentDate = data.date!
                                self.currentDay = data.dayOfWeek
                                self.dayData  = data
                                if let commentsLink = data.messageLink {
                                    self.getComments(commentsLink)
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
    
// MARK: - tableview Override
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        } else if section == 1 && self.comments.count > 0{
            return 45
        }
        return 0.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfSections = 2
        if section == 1 {
            numberOfSections = self.comments.count // number of comments
        } else if section == 2 {
            numberOfSections = 1
        }
        return numberOfSections
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        } else if self.dayData?.messageLink != nil && indexPath.section == 1 {
            let cell : CommentControlCell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as! CommentControlCell
            let comment = self.comments[indexPath.row]
            cell.setBuddyCommentData(comment)
            cell.indexPath = indexPath
            cell.commentDelegate = self

            if self.dayData?.commentLink != nil {
                self.commentView.hidden = false
                self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
            } else if comment.replyLink != nil {
                hideReplyButton = false
                cell.replyToComment.hidden = hideReplyButton
                self.sendCommentFooter!.postReplyLink = comment.replyLink
            }

            return cell
        }
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
        } else if section == 1 && self.comments.count > 0{
            let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CommentTableHeader") as! CommentTableHeader
            return cell
        }
//        else if section == 2 && self.dayData?.commentLink != nil{
//            let cell: SendCommentControl = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SendCommentControl") as! SendCommentControl
//            cell.delegate = self
//            cell.postGoalLink = self.dayData?.commentLink
//            return cell
//        }
        return nil
    }
    
    // MARK: - CommentCellDelegate
    func deleteComment(cell: CommentControlCell, comment: Comment){
        let aComment = comment as Comment
        CommentRequestManager.sharedInstance.deleteComment(aComment, onCompletion: { (success, message, code) in
            if success {
                self.comments.removeAtIndex((cell.indexPath?.row)!)
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    func showSendComment() {

        UIView.animateWithDuration(1.5, animations: {
            self.commentView.alpha = 1
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
    
    func textFieldEndEdit(commentTextField: UITextField, comment: Comment?){
        commentTextField.resignFirstResponder()
        //reload the data
        if let comment = comment {
            self.comments.append(comment)
        }
        
    }
    
    // MARK: - get comment data
    func getComments(commentLink: String?) {
        CommentRequestManager.sharedInstance.getComments(commentLink!, size: 11, page: 0) { (success, comment, comments, serverMessage, serverCode) in
            if success {
                self.comments = []
                if let comments = comments {
                    self.comments = comments
                }
            }
        }
    }

}