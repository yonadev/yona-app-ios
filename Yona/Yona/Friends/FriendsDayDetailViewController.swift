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
    var avtarImg : UIImageView = UIImageView()
    
    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comments = []
        configureRightButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsDayDetailViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navbarColor1 = navbarColor1,
            let navbarColor = navbarColor {
            self.navigationController?.navigationBar.backgroundColor = navbarColor1
            if let navbar = navigationController?.navigationBar as? GradientNavBar{
                navbar.gradientColor = navbarColor
            }
        }
    }
    
    func configureRightButton() {
        let btnName = UIButton.init(frame: CGRect(x:0, y:0, width:YonaConstants.profileImageWidth, height:YonaConstants.profileImageHeight))
        let rightBarButton = UIBarButtonItem()
        if let link = buddy?.buddyAvatarURL, let URL = URL(string: link) {
            self.avtarImg.kf.setImage(with: URL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                let resizedImage:UIImage = UIImage.resizeImage(image: image!, targetSize: CGSize(width:YonaConstants.profileImageWidth, height:YonaConstants.profileImageHeight))
                btnName.setImage(resizedImage, for: .normal)
                btnName.backgroundColor = UIColor.clear
                btnName.clipsToBounds = true
            })
        } else if let nickName = buddy?.buddyNickName {
            btnName.setTitle("\(nickName.capitalized.first!)", for: UIControl.State())
            btnName.backgroundColor = UIColor.yiGrapeTwoColor()
        }
        btnName.addTarget(self, action: #selector(self.showUserProfile(_:)), for: .touchUpInside)
        btnName.layer.cornerRadius = btnName.frame.size.width/2
        btnName.layer.borderWidth = 1
        btnName.layer.borderColor = UIColor.white.cgColor
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItems = [rightBarButton]
    }
    
    override func registreTableViewCells () {
        super.registreTableViewCells()
        var nib = UINib(nibName: "CommentTableHeader", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CommentTableHeader")
        
        nib = UINib(nibName: "CommentControlCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentControlCell")
        
    }
    
    @objc func showUserProfile(_ sender : AnyObject) {
        performSegue(withIdentifier: R.segue.friendsDayDetailViewController.showFriendProfile, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendsProfileViewController {
            let controller = segue.destination as! FriendsProfileViewController
            controller.aUser = buddy
        }
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        super.tableView(tableView, heightForHeaderInSection: section)
        var heightOfHeader : CGFloat = 45
        if section == 1 && self.comments.count > 0{
            heightOfHeader = 45
        }
        return heightOfHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        var cellHeight = 165
        if indexPath.section == detailDaySections.activity.rawValue && indexPath.row == detailDayRows.activity.rawValue {
            if indexPath.row == detailDayRows.activity.rawValue {
                if goalType == GoalType.BudgetGoalString.rawValue || activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    cellHeight = 135
                } else if goalType == GoalType.NoGoGoalString.rawValue || activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    cellHeight = 85
                } else if goalType == GoalType.TimeZoneGoalString.rawValue || activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    cellHeight = 135
                }
            }
            
            if indexPath.row == detailDayRows.spreadCell.rawValue{
                cellHeight = 165
            }
        } else if indexPath.section == detailDaySections.comment.rawValue {
            return UITableView.automaticDimension
        }

        return CGFloat(cellHeight)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
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

    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
//        super.tableView(tableView, cellForRowAtIndexPath: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == detailDayRows.spreadCell.rawValue {
                let cell: SpreadCell = tableView.dequeueReusableCell(withIdentifier: "SpreadCell", for: indexPath) as! SpreadCell
                if let data = dayData  {
                    cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                }
                return cell
                
            }
            if indexPath.row == detailDayRows.activity.rawValue {
                
                if goalType == GoalType.BudgetGoalString.rawValue || activityGoal?.goalType == GoalType.BudgetGoalString.rawValue {
                    let cell: TimeBucketControlCell = tableView.dequeueReusableCell(withIdentifier: "TimeBucketControlCell", for: indexPath) as! TimeBucketControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.TimeZoneGoalString.rawValue || activityGoal?.goalType == GoalType.TimeZoneGoalString.rawValue {
                    let cell: TimeZoneControlCell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneControlCell", for: indexPath) as! TimeZoneControlCell
                    if let data = dayData  {
                        cell.setDayActivityDetailForView(data, animated: shouldAnimate(indexPath))
                    }
                    return cell
                } else if goalType == GoalType.NoGoGoalString.rawValue || activityGoal?.goalType == GoalType.NoGoGoalString.rawValue {
                    let cell: NoGoCell = tableView.dequeueReusableCell(withIdentifier: "NoGoCell", for: indexPath) as! NoGoCell
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
            
            if self.dayData?.messageLink != nil && indexPath.section == 1 {
                //if we ahve a thread id that is different in the current comment as in the previous one show ccomment control
                if currentThreadID != previousThreadID {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentControlCell", for: indexPath) as? CommentControlCell {
                        cell.setBuddyCommentData(comment)
                        cell.indexPath = indexPath
                        cell.commentDelegate = self
                        if self.dayData?.commentLink != nil {
                            cell.replyToComment.isHidden = true
                            self.sendCommentFooter!.postCommentLink = self.dayData?.commentLink
                        } else if comment.replyLink != nil {
                            cell.replyToComment.isHidden = false
                            self.sendCommentFooter!.postReplyLink = comment.replyLink
                        }
                        return cell
                    }
                } else {
                    // if the thread id is the same then show the reply to comment cell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyToComment", for: indexPath) as? ReplyToComment {
                        cell.setBuddyCommentData(comment)
                        cell.indexPath = indexPath
                        cell.commentDelegate = self
                        //cell.hideShowReplyButton(comment.replyLink == nil)
                        //self.sendCommentFooter?.alpha = 0
                        return cell
                    }
                }
            }
            
        }
        return UITableViewCell(frame: CGRect.zero)
    }


    override func loadData (_ typeToLoad : loadType = .own) {
        
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
                            self.navigationItem.title = self.dayData?.goalName!.uppercased()
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
                        Loader.Hide()
                        
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
