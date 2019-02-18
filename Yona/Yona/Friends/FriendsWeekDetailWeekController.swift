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
    var avtarImg : UIImageView = UIImageView()
    
    //MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comments = []
        self.sendCommentFooter!.alpha = 1
        self.configureRightButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "FriendsWeekDetailWeekController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        if initialObject != nil || initialObjectLink != nil {
            loadData(.own)
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
    
    @objc func showUserProfile(_ sender : AnyObject) {
        performSegue(withIdentifier: R.segue.friendsWeekDetailWeekController.showFriendProfile, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FriendsProfileViewController {
            let controller = segue.destination as! FriendsProfileViewController
            controller.aUser = buddy
        }
    }
    
    override func loadData (_ typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        // ALWAYS DOWNLOAD DATA FIRST TIME FOR THE WEEK
        Loader.Show()
        if let theBuddy = buddy {
            if typeToLoad == .own {
                var path : String?
                if let url = initialObjectLink {
                    path = url
                } else if let url = initialObject?.weekDetailLink {
                    path = url
                }
                if let path = path {
                    ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                        if success {
                            if let data = activitygoals {
                                self.currentWeek = data.date
                                self.initialObject = data
                                self.week[data.date.yearWeek] = data
                                self.navigationItem.title = data.goalName?.uppercased()
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
