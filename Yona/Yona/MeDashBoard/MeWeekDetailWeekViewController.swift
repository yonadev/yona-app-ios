//
//  MeWeekDetailWeekViewController.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

enum detailRows : Int  {
    case weekoverview = 0
    case activity
    case spreadCell
}

class MeWeekDetailWeekViewController: UIViewController, YonaButtonsTableHeaderViewProtocol, SendCommentControlProtocol, CommentCellDelegate {
    var initialObject : WeekSingleActivityGoal?
    var initialObjectLink : String?
    var week : [String:WeekSingleActivityDetail] = [:]
    var firstWeek :  NSDate = NSDate()
    var currentWeek : NSDate = NSDate()
    var correctToday = NSDate()
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var commentView : UIView?
    @IBOutlet weak var sendCommentFooter : SendCommentControl?
    var previousThreadID : String = ""
    
    var page : Int = 0
    var size : Int = 4
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    
    var comments = [Comment]() {
        didSet{
            //everytime add comments refresh table
            dispatch_async(dispatch_get_main_queue()) {
                self.previousThreadID = ""
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comments = []
        registreTableViewCells()
        self.sendCommentFooter!.alpha = 0
        self.sendCommentFooter?.delegate = self
<<<<<<< HEAD
        
=======
        self.navigationItem.setHidesBackButton(true, animated: false)
>>>>>>> 6c4a1295553a72dc25bbf77679cc0c7471c40427
    }

    func registreTableViewCells () {
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "SpreadCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SpreadCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
        nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "CommentControlCell")
        
        nib = UINib(nibName: "SendCommentControl", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "SendCommentControl")
        
        nib = UINib(nibName: "ReplyToComment", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "ReplyToComment")
    }

    @IBAction func backAction(sender : AnyObject) {
        dispatch_async(dispatch_get_main_queue(), {
            self.navigationController?.popViewControllerAnimated(true)
        })
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()
        correctToday = NSDate().dateByAddingTimeInterval(60*60*24)

        if let aWeek = initialObject {
            if let txt = aWeek.goalName {
                navigationItem.title = NSLocalizedString(txt, comment: "")
            }
            
            loadData(.own)
        } else if initialObjectLink != nil {
            loadData(.own)
        
//            let back = navigationController?.navigationItem
//            navigationController?.navigationItem
//            navigationItem
//            setLeftBarButtonItem(nil, animated: false)
//            //navigationItem.setHidesBackButton(true, animated: false)
//
//            print (back)
        }
    }
    
    // MARK: - tableview Override
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfSections = 0
        if let _ = week[currentWeek.yearWeek]  {
            numberOfSections = 3
        }
        if section == 1 {
            numberOfSections = self.comments.count // number of comments
        } else if section == 2 {
            numberOfSections = 1
        }
        return numberOfSections
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

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
                
                if data.messageLink != nil && indexPath.section == 1 {
                    //if we ahve a thread id that is different in the current comment as in the previous one show ccomment control
                    if currentThreadID != previousThreadID {
                        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentControlCell", forIndexPath: indexPath) as? CommentControlCell {
                            cell.setBuddyCommentData(comment)
                            cell.indexPath = indexPath
                            cell.commentDelegate = self
                            cell.hideShowReplyButton(data.commentLink != nil && comment.replyLink == nil)
                            self.sendCommentFooter!.setLinks(comment.replyLink, commentLink: data.commentLink)
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
        }
        return UITableViewCell(frame: CGRectZero)

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let data = week[currentWeek.yearWeek] {
            if section == 0 {
                let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
                cell.delegate = self
                
                let other = week[currentWeek.yearWeek]?.date.yearWeek
                let otherDateStart = correctToday.dateByAddingTimeInterval(-60*60*24*7)
                let otherDate = otherDateStart.yearWeek
                
                if correctToday.yearWeek == other {
                    cell.headerTextLabel.text = NSLocalizedString("This week", comment: "")
                } else if other == otherDate {
                    cell.headerTextLabel.text =  NSLocalizedString("Last week", comment: "")
                } else {
                    let dateFormatter : NSDateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd MMM"
                    cell.headerTextLabel.text = "\(dateFormatter.stringFromDate(otherDateStart)) - \(dateFormatter.stringFromDate(otherDateStart.dateByAddingTimeInterval(7*60*60*24)))"
                }
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
                return cell
            } else if section == 1 && self.comments.count > 0{
                let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CommentTableHeader") as! CommentTableHeader
                return cell
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.row == detailRows.activity.rawValue {
            if let initialObject = initialObject {
                if initialObject.goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 165
                } else if initialObject.goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 0
                } else if initialObject.goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 0
                }
            }
        }
        if indexPath.row == detailRows.spreadCell.rawValue {
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

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.comments.count > 0{
            if indexPath.section == 1 {
                print(indexPath.row)
                if indexPath.row == page * size - 1 && page < self.totalPages {
                    page = page + 1
                    if let data = week[currentWeek.yearWeek],
                        let commentsLink = data.messageLink {
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
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        // ALWAYS DOWNLOAD DATA FIRST TIME FOR THE WEEK
        Loader.Show()
        //reset these so that the data can be loaded when we switch to a different set of challenges we need to see from the beginning
        size = 4
        page = 1
        
        if typeToLoad == .own {
            var path : String?
            if let url = initialObjectLink {
                path = url
            } else {
                if let data = initialObject,
                    let url = data.weekDetailLink {
                        path = url
                }
            }
            if let path = path {
                ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                    if success {
                        
                        if let data = activitygoals {
                            self.navigationItem.title = data.goalName
                            self.currentWeek = data.date
                            self.week[data.date.yearWeek] = data
                            print (data.date.yearWeek)
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
                            }
                            if data.commentLink != nil {
                                self.sendCommentFooter!.postCommentLink = data.commentLink
                            }
                            self.navigationItem.title = data.goalName //only need to do this in the first original data

                        }
                        
                        Loader.Hide()
                        self.tableView.reloadData()
                        
                    } else {
                        Loader.Hide()
                    }
                })
            }
            
        } else  if typeToLoad == .prev {
            if let data = week[currentWeek.yearWeek]  {
                if let path = data.prevLink {
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
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
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
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
        Loader.Hide()
        self.tableView.reloadData()
            
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
        if let data = week[currentWeek.yearWeek],
            let commentsLink = data.messageLink {
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