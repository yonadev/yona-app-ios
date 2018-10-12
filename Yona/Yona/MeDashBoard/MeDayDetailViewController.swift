
//
//  MeDetailDayViewController.swift
//  Yona
//
//  Created by Ben Smith on 20/07/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

enum detailDayRows : Int  {
    case activity = 0
    case spreadCell
    case linkCell
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
    @IBOutlet weak var sendCommentFooter : SendCommentControl?
    
    var correctToday = Date()
    var singleDayData : [String: DaySingleActivityDetail] = [:]
    var dayData : DaySingleActivityDetail?
    var activityGoal : ActivitiesGoal?
    var initialObjectLink : String?
    var goalName : String?
    var goalType : String?
    var currentDate : Date = Date()
    var currentDay : String?
    var nextLink : String?
    var prevLink : String?
    var hideReplyButton : Bool = false
    var moveToBottomRequired : Bool = false
    var previousThreadID : String = ""
    var page : Int = 1
    var size : Int = 4
    var animatedCells : [String] = []
    
    var navbarColor1 : UIColor?
    var navbarColor : UIColor?
    
    var violationStartTime : Date?
    var violationEndTime : Date?
    var violationLinkURL : String?
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    var comments = [Comment]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            DispatchQueue.main.async {
                self.previousThreadID = ""
                self.tableView.reloadData()
                if self.comments.count > 0 && self.moveToBottomRequired {
                    self.tableView.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 1), at: UITableViewScrollPosition.bottom, animated: false)
                }
            }
        }
    }
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = goalName?.uppercased()
        self.comments = []
        if let activityGoal = activityGoal {
            initialObjectLink = activityGoal.dayDetailLinks
            currentDate = activityGoal.date as Date
            goalName = activityGoal.goalName
            goalType = activityGoal.goalType
        }
        registreTableViewCells()
        self.sendCommentFooter?.commentControlDelegate = self
        self.sendCommentFooter?.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "MeDayDetailViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        correctToday = Date().addingTimeInterval(60*60*24)
        self.loadData(.own)
    }
    
    //MARK: - button action
    @IBAction func backAction(_ sender : AnyObject) {
        DispatchQueue.main.async(execute: {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backAction", label: "MeDayDetailViewController", value: nil).build() as! [AnyHashable: Any])
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    fileprivate func shouldAnimate(_ cell : IndexPath) -> Bool {
        let txt = "\(cell.section)-\(cell.row)"
        if animatedCells.index(of: txt) == nil {
            print("Animated \(txt)")
            animatedCells.append(txt)
            return true
        }
        print("NO animated \(txt)")
        return false
    }
    
    func registreTableViewCells () {
        var nib = UINib(nibName: "SpreadCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SpreadCell")
        
        nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "TimeZoneControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeZoneControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
        nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentControlCell")
        
        nib = UINib(nibName: "ReplyToComment", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ReplyToComment")
        
        nib = UINib(nibName: "DayViewLinkCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DayViewLinkCell")
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
    
    //MARK: - load data
    func loadData (_ typeToLoad : loadType = .own) {
        Loader.Show()
        if typeToLoad == .own {
            loadOwnData()
        }
        else if typeToLoad == .prev {
            loadPreviousData()
        }
        else if typeToLoad == .next {
            loadNextData()
        }
        Loader.Hide()
        self.tableView.reloadData()
    }
    
    fileprivate func loadOwnData() {
        if let path = initialObjectLink {
            ActivitiesRequestManager.sharedInstance.getDayActivityDetails(path, date: currentDate , onCompletion: { (success, serverMessage, serverCode, dayActivity, err) in
                if success {
                    if let data = dayActivity {
                        self.currentDate = data.date!
                        self.currentDay = data.dayOfWeek
                        self.dayData  = data
                        self.goalType = data.goalType
                        if let commentsLink = data.messageLink {
                            self.getComments(commentsLink)
                        }
                        //make sure the commentview has the right link to post comments to
                        if self.dayData?.commentLink != nil {
                            self.sendCommentFooter!.alpha = self.dayData?.commentLink != nil ? 1 : 0
                            self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
                        }
                    }
                    if let _ = self.dayData?.goalType {
                        self.tableView.reloadData()
                        
                    } else {
                        self.noGoalTypeInResponse()
                    }
                }
            })
        }
    }
    
    fileprivate func loadPreviousData() {
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
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    fileprivate func loadNextData() {
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
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func noGoalTypeInResponse() {
        let alert = UIAlertController(title: NSLocalizedString("nogo-data-not-found-title", comment: ""),
                                      message: NSLocalizedString("nogo-data-not-found-description", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("dashboard.error.button", comment: ""), style: .default, handler: { action in
            switch action.style {
            case .default:
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableviewDelegate Methods
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  dayData == nil {
            return 0
        }
        var numberOfRows = 2
        if violationLinkURL != nil {
            numberOfRows = 3
        }
        if section == 1 {
            numberOfRows = self.comments.count // number of comments
        } else if section == 2 {
            numberOfRows = 1
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 135
                } else if goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 135
                }
            }
            if indexPath.row == detailDayRows.spreadCell.rawValue{
                cellHeight = 165
            }
        } else if indexPath.section == detailDaySections.comment.rawValue {
            return UITableViewAutomaticDimension
        }
        return CGFloat(cellHeight)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 135
                } else if goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 135
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44.0
        } else if section == 1 && self.comments.count > 0{
            return 45
        }
        return 0.0
    }
    
    fileprivate func getSpreadCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell: SpreadCell = tableView.dequeueReusableCell(withIdentifier: "SpreadCell", for: indexPath) as! SpreadCell
        if let data = dayData  {
            cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
        }
        return cell
    }
    
    fileprivate func getTimeBucketControlCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell: TimeBucketControlCell = tableView.dequeueReusableCell(withIdentifier: "TimeBucketControlCell", for: indexPath) as! TimeBucketControlCell
        if let data = dayData  {
            cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
        }
        return cell
    }
    
    fileprivate func getTimeZoneControlCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell: TimeZoneControlCell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneControlCell", for: indexPath) as! TimeZoneControlCell
        if let data = dayData  {
            cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
        }
        return cell
    }
    
    fileprivate func getNoGoCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell: NoGoCell = tableView.dequeueReusableCell(withIdentifier: "NoGoCell", for: indexPath) as! NoGoCell
        if let data = dayData  {
            cell.setDayActivityDetailForView(data)
        }
        return cell
    }
    
    fileprivate func getDayViewLinkCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell: DayViewLinkCell = tableView.dequeueReusableCell(withIdentifier: "DayViewLinkCell", for: indexPath) as! DayViewLinkCell
        cell.setData(violationLinkURL!, startDate: violationStartTime!)
        return cell
    }
    
    fileprivate func getCommentControlCell(_ tableView: UITableView, _ indexPath: IndexPath, _ comment: Comment) -> UITableViewCell {
        let cell: CommentControlCell = tableView.dequeueReusableCell(withIdentifier: "CommentControlCell", for: indexPath) as! CommentControlCell
        cell.setBuddyCommentData(comment)
        cell.indexPath = indexPath
        cell.commentDelegate = self
        cell.hideShowReplyButton(self.dayData?.commentLink != nil && comment.replyLink == nil)
        self.sendCommentFooter!.setLinks(comment.replyLink, commentLink: self.dayData?.commentLink)
        return cell
    }
    
    fileprivate func getReplyToCommentCell(_ tableView: UITableView, _ indexPath: IndexPath, _ comment: Comment) -> UITableViewCell {
        let cell: ReplyToComment = tableView.dequeueReusableCell(withIdentifier: "ReplyToComment", for: indexPath) as! ReplyToComment
        cell.setBuddyCommentData(comment)
        cell.indexPath = indexPath
        cell.commentDelegate = self
        cell.hideShowReplyButton(comment.replyLink == nil)
        self.sendCommentFooter?.alpha = 0
        return cell
    }
    
    func getCellForSectionZero(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == detailDayRows.spreadCell.rawValue {
            return getSpreadCell(tableView, indexPath)
        }
        if indexPath.row == detailDayRows.activity.rawValue {
            if goalType == GoalType.BudgetGoalString.rawValue {
                return getTimeBucketControlCell(tableView, indexPath)
            } else if goalType == GoalType.TimeZoneGoalString.rawValue {
                return getTimeZoneControlCell(tableView, indexPath)
            } else if goalType == GoalType.NoGoGoalString.rawValue {
                return getNoGoCell(tableView, indexPath)
            }
        }
        if indexPath.row == detailDayRows.linkCell.rawValue {
            return getDayViewLinkCell(tableView, indexPath)
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    fileprivate func getNextCommentThreadId(_ indexPath: IndexPath, _ nextThreadID: inout String, _ previousThreadID: inout String) {
        if indexPath.row + 1 < self.comments.count {
            if let nextThreadMessageId = self.comments[indexPath.row + 1].threadHeadMessageID {
                nextThreadID = nextThreadMessageId
            }
        } else {
            nextThreadID = ""
        }
        //check for a previous row
        if indexPath.row != 0{
            // then get the thread id of this row
            if let previousThreadMessageId = self.comments[indexPath.row - 1].threadHeadMessageID {
                previousThreadID = previousThreadMessageId
            }
        }
    }
    
    func getCellForSectionOne(indexPath: IndexPath) -> UITableViewCell {
        let comment = self.comments[indexPath.row]
        let currentThreadID = comment.threadHeadMessageID
        var previousThreadID = ""
        var nextThreadID = ""
        
        getNextCommentThreadId(indexPath, &nextThreadID, &previousThreadID)
        
        if self.dayData?.messageLink != nil && indexPath.section == 1 {
            if currentThreadID != previousThreadID { //if we ahve a thread id that is different in the current comment as in the previous one show ccomment control
                return getCommentControlCell(tableView, indexPath, comment)
            } else {  // if the thread id is the same then show the reply to comment cell
                return getReplyToCommentCell(tableView, indexPath, comment)
            }
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getCellForSectionZero(indexPath: indexPath)
        } else if self.dayData?.messageLink != nil && indexPath.section == 1 {
            return getCellForSectionOne(indexPath: indexPath)
        }
        return UITableViewCell(frame: CGRect.zero)
    }
    
    fileprivate func headerViewForSectionZero(_ tableView: UITableView) -> UIView? {
        let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
        cell.delegate = self
        if currentDate.isToday() {
            cell.headerTextLabel.text = NSLocalizedString("today", comment: "")
        } else if currentDate.isYesterday() {
            cell.headerTextLabel.text = NSLocalizedString("yesterday", comment: "")
        } else {
            cell.headerTextLabel.text = currentDate.fullDayMonthDateString()
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
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerViewForSectionZero(tableView)
        } else if section == 1 && self.comments.count > 0{
            let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommentTableHeader") as! CommentTableHeader
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if self.comments.count > 0{
            if indexPath.section == 1 {
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
    func deleteComment(_ cell: CommentControlCell, comment: Comment){
        let aComment = comment as Comment
        CommentRequestManager.sharedInstance.deleteComment(aComment, onCompletion: { (success, message, code) in
            if success {
                self.comments.remove(at: (cell.indexPath?.row)!)
            } else {
                self.displayAlertMessage(message!, alertDescription: "")
            }
        })
    }
    
    func showSendComment(_ comment: Comment?) {
        self.comments = []
        if let comment = comment {
            self.comments.append(comment)
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.sendCommentFooter!.alpha = 1
        })
    }
    
    // MARK: - SendCommentControlProtocol
    func textFieldBeginEdit(_ textField: UITextField, commentTextField: UITextField) {
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    func textFieldEndEdit(_ commentTextField: UITextField, comment: Comment?){
        moveToBottomRequired = true
        commentTextField.resignFirstResponder()
        commentTextField.text = ""
        if let commentsLink = self.dayData?.messageLink {
            size = 4
            page = 1
            self.getComments(commentsLink)
        }
    }
    
    // MARK: - get comment data
    func getComments(_ commentLink: String) {
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
