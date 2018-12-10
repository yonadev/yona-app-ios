//
//  MeWeekDetailWeekViewController.swift
//  Yona
//
//  Created by Anders Liebl on 05/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

enum detailRows : Int  {
    case weekoverview = 0
    case activity
    case spreadCell
}

class MeWeekDetailWeekViewController: UIViewController, YonaButtonsTableHeaderViewProtocol, SendCommentControlProtocol, CommentCellDelegate {
    var initialObject : WeekSingleActivityGoal?
    var initialObjectLink : String?
    var goalType : String?
    var week : [String:WeekSingleActivityDetail] = [:]
    var firstWeek :  Date = Date()
    var currentWeek : Date = Date()
    var correctToday = Date()
    
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var commentView : UIView?
    @IBOutlet weak var sendCommentFooter : SendCommentControl?
    var previousThreadID : String = ""
    var animatedCells : [String] = []

    var page : Int = 0
    var size : Int = 4
    
    //paging
    var totalSize: Int = 0
    var totalPages : Int = 0
    
    var comments = [Comment]() {
        didSet{
            //everytime add comments refresh table
            DispatchQueue.main.async {
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
        self.sendCommentFooter?.commentControlDelegate = self
    }
    
    func shouldAnimate(_ cell : IndexPath) -> Bool {
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
        var nib = UINib(nibName: "TimeBucketControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeBucketControlCell")
        
        nib = UINib(nibName: "NoGoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "NoGoCell")
        
        nib = UINib(nibName: "SpreadCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SpreadCell")
        
        nib = UINib(nibName: "WeekScoreControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "WeekScoreControlCell")
        
        nib = UINib(nibName: "YonaButtonsTableHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "YonaButtonsTableHeaderView")
        
        nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentControlCell")
        
        nib = UINib(nibName: "SendCommentControl", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SendCommentControl")
        
        nib = UINib(nibName: "ReplyToComment", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ReplyToComment")
    }

    @IBAction func backAction(_ sender : AnyObject) {
        DispatchQueue.main.async(execute: {
            weak var tracker = GAI.sharedInstance().defaultTracker
            tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backAction", label: "MeWeekDetailWeekViewController", value: nil).build() as! [AnyHashable: Any])
            self.navigationController?.popViewController(animated: true)
        })
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "MeWeekDetailWeekViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()
        correctToday = Date().addingTimeInterval(60*60*24)

        if let aWeek = initialObject {
//            if let txt = aWeek.goalName?.uppercaseString {
//                navigationItem.title = NSLocalizedString(txt, comment: "")
//            }
            loadData(.own)
        } else if initialObjectLink != nil {
            loadData(.own)
        }
    }
    
    // MARK: - tableview Override
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if week[currentWeek.yearWeek] == nil {
            return 0
        }
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {

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
                    if goalType != GoalType.NoGoGoalString.rawValue && data.goalType != GoalType.TimeZoneGoalString.rawValue{
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
            if data.messageLink != nil && indexPath.section == 1 {
                let comment = self.comments[indexPath.row]
                let currentThreadID = comment.threadHeadMessageID
                var previousThreadID = ""
                var nextThreadID = ""
                
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
                
                if data.messageLink != nil && indexPath.section == 1 {
                    //if we ahve a thread id that is different in the current comment as in the previous one show ccomment control
                    if currentThreadID != previousThreadID {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentControlCell", for: indexPath) as? CommentControlCell {
                            cell.setBuddyCommentData(comment)
                            cell.indexPath = indexPath
                            cell.commentDelegate = self
                            cell.hideShowReplyButton(data.commentLink != nil && comment.replyLink == nil)
                            self.sendCommentFooter!.setLinks(comment.replyLink, commentLink: data.commentLink)
                            return cell
                        }
                    } else {
                        // if the thread id is the same then show the reply to comment cell
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyToComment", for: indexPath) as? ReplyToComment {
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
        return UITableViewCell(frame: CGRect.zero)

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let data = week[currentWeek.yearWeek] {
            if section == 0 {
                let cell : YonaButtonsTableHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "YonaButtonsTableHeaderView") as! YonaButtonsTableHeaderView
                cell.delegate = self
                
                let other = week[currentWeek.yearWeek]?.date.yearWeek
                let otherDateStart = correctToday.addingTimeInterval(-60*60*24*7)
                let otherDate = otherDateStart.yearWeek
                
                if correctToday.yearWeek == other {
                    cell.headerTextLabel.text = NSLocalizedString("this_week", comment: "")
                } else if other == otherDate {
                    cell.headerTextLabel.text =  NSLocalizedString("last_week", comment: "")
                } else {
                    cell.headerTextLabel.text = "\(otherDateStart.shortDayMonthDateString()) - \(otherDateStart.addingTimeInterval(7*60*60*24).shortDayMonthDateString())"
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
                let cell : CommentTableHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommentTableHeader") as! CommentTableHeader
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.row == detailRows.activity.rawValue {
            if goalType == GoalType.BudgetGoalString.rawValue {
                cellHeight = 165
            } else if goalType == GoalType.NoGoGoalString.rawValue {
                cellHeight = 0
            } else if goalType == GoalType.TimeZoneGoalString.rawValue {
                cellHeight = 0
            }
        }
        if indexPath.row == detailRows.spreadCell.rawValue {
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

    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
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

    
    func loadData (_ typeToLoad : loadType = .own) {
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
                            self.navigationItem.title = data.goalName?.uppercased()
                            self.currentWeek = data.date
                            self.week[data.date.yearWeek] = data
                            self.goalType = data.goalType
                            if let commentsLink = data.messageLink {
                                self.getComments(commentsLink)
                            }
                            if data.commentLink != nil {
                                self.sendCommentFooter!.postCommentLink = data.commentLink
                            }

                        }
                        self.tableView.reloadData()
                        Loader.Hide()
                        
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
                            self.tableView.reloadData()
                            Loader.Hide()
                            
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
                            self.tableView.reloadData()
                            Loader.Hide()
                            
                        } else {
                            Loader.Hide()
                        }
                    })
                }
            }
            
            
        }
        self.tableView.reloadData()
        Loader.Hide()
        
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
