
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
    var goalType : String?
    var currentDate : NSDate = NSDate()
    var currentDay : String?
    var nextLink : String?
    var prevLink : String?
    var hideReplyButton : Bool = false
    var previousThreadID : String = ""
    var page : Int = 1
    var size : Int = 4
    var animatedCells : [String] = []
    
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    
    @IBOutlet weak var sendCommentFooter : SendCommentControl?

    var comments = [Comment]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.previousThreadID = ""
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comments = []
        if let activityGoal = activityGoal {
            initialObjectLink = activityGoal.dayDetailLinks
            currentDate = activityGoal.date
            goalName = activityGoal.goalName
            goalType = activityGoal.goalType
            
        }
        registreTableViewCells()
        self.sendCommentFooter?.delegate = self
        self.sendCommentFooter?.alpha = 0
        
    }
    
    @IBAction func backAction(sender : AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "backAction", label: "MeDayDetailViewController", value: nil).build() as [NSObject : AnyObject])

            self.navigationController?.popViewControllerAnimated(true)
        })
        
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
        
//        nib = UINib(nibName: "SendCommentControl", bundle: nil)
//        tableView.registerNib(nib, forCellReuseIdentifier: "SendCommentControl")
        
        nib = UINib(nibName: "ReplyToComment", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ReplyToComment")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "MeDayDetailViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        correctToday = NSDate().dateByAddingTimeInterval(60*60*24)
        self.loadData(.own)

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
//        size = 4
//        page = 1
        if typeToLoad == .own {
            if let path = initialObjectLink {
                ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate , onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
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
    
// MARK: - tableview Override
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 165
                } else if goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if goalType == GoalType.TimeZoneGoalString.rawValue {
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
        if  dayData == nil {
            return 0
        }
        
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
                    cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                }
                return cell
                
            }
            if indexPath.row == detailDayRows.activity.rawValue {

                if goalType == GoalType.BudgetGoalString.rawValue {
                    let cell: TimeBucketControlCell = tableView.dequeueReusableCellWithIdentifier("TimeBucketControlCell", forIndexPath: indexPath) as! TimeBucketControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.TimeZoneGoalString.rawValue {
                    let cell: TimeZoneControlCell = tableView.dequeueReusableCellWithIdentifier("TimeZoneControlCell", forIndexPath: indexPath) as! TimeZoneControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.NoGoGoalString.rawValue {
                    let cell: NoGoCell = tableView.dequeueReusableCellWithIdentifier("NoGoCell", forIndexPath: indexPath) as! NoGoCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data)
                    }
                    return cell
                }
                
            }
        } else if self.dayData?.messageLink != nil && indexPath.section == 1 {
            let comment = self.comments[indexPath.row]
            let currentThreadID = comment.threadHeadMessageID
            var previousThreadID = ""
            var nextThreadID = ""

            if indexPath.row + 1 < self.comments.count {
                 nextThreadID = self.comments[indexPath.row + 1].threadHeadMessageID!
            } else {
                nextThreadID = ""
            }
            //check for a previous row
            if indexPath.row != 0{
                // then get the thread id of this row
                previousThreadID = self.comments[indexPath.row - 1].threadHeadMessageID!
            }
            
            if self.dayData?.messageLink != nil && indexPath.section == 1 {
                //if we ahve a thread id that is different in the current comment as in the previous one show ccomment control
                if currentThreadID != previousThreadID {
                    if let cell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as? CommentControlCell {
                        cell.setBuddyCommentData(comment)
                        cell.indexPath = indexPath
                        cell.commentDelegate = self
                        cell.hideShowReplyButton(self.dayData?.commentLink != nil && comment.replyLink == nil)
                        self.sendCommentFooter!.setLinks(comment.replyLink, commentLink: self.dayData?.commentLink)
                        return cell
                    }
                } else {
                    // if the thread id is the same then show the reply to comment cell
                    if let cell = tableView.dequeueReusableCellWithIdentifier("ReplyToComment", forIndexPath: indexPath) as? ReplyToComment {
                        cell.setBuddyCommentData(comment)
                        cell.indexPath = indexPath
                        cell.commentDelegate = self
                        cell.hideShowReplyButton(comment.replyLink == nil)
                        self.sendCommentFooter?.alpha = 0
                        return cell
                    }
                }
            }
            
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
        return nil
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.comments.count > 0{
            if indexPath.section == 1 {
                print(indexPath.row)
                if indexPath.row == page * size - 1 && page < self.totalPages {
                    page = page + 1
                    
                    if let commentsLink = self.dayData?.messageLink {
                        Loader.Show()
                        CommentRequestManager.sharedInstance.getComments(commentsLink, size: size, page: page) { (success, comment, comments, serverMessage, serverCode) in
                            Loader.Hide()
                            if success {
                                if let comments = comments {
                                    for comment in comments {
                                        self.comments.append(comment)
                                    }
                                }
                            }
                        }
                    }
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
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    func showSendComment(comment: Comment?) {
        self.comments = []
        if let comment = comment {
            self.comments.append(comment)
        }
        UIView.animateWithDuration(0.5, animations: {
            self.sendCommentFooter!.alpha = 1
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
        commentTextField.text = ""
        if let commentsLink = self.dayData?.messageLink {
            size = 4
            page = 1
            self.getComments(commentsLink)
        }
    }
    
    // MARK: - get comment data
    func getComments(commentLink: String) {
        CommentRequestManager.sharedInstance.getComments(commentLink, size: size, page: page) { (success, comment, comments, serverMessage, serverCode) in
            if success {
                self.comments = []
                if let comments = comments {
                    self.comments = comments
                    self.totalPages = comments[0].totalPages!
                }
            }
        }
    }

}