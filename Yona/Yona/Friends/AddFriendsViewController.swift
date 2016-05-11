//
//  AddFriendsViewController.swift
//  Yona
//
//  Created by Chandan on 11/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UIScrollViewDelegate {
    
    enum FriendsOverviewSelectedTab {
        case TimelineTab
        case overViewTab
    }
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var timelineTabView: UIView!
    @IBOutlet var overviewTabView: UIView!
    @IBOutlet var timelineTabBottomBorder: UIView!
    @IBOutlet var overviewTabBottomBorder: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addFriendbutton: UIButton!
    @IBOutlet var allMyEvent:[UIView]!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiMidBlueColor(), UIColor.yiMidBlueColor()]
        })
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - private functions
    private func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}

extension AddFriendsViewController {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
       
        return cell
    }

}


// MARK: Touch Event of Custom Segment

extension AddFriendsViewController {
    
    @IBAction func TimeLineTabAction(sender: AnyObject) {
        overviewTabView.alpha = 0.5
        overviewTabBottomBorder.hidden = true
        timelineTabView.alpha = 1.0
        timelineTabBottomBorder.hidden = false
        addFriendbutton.hidden = true
    }
    
    @IBAction func OverviewTabAction(sender: AnyObject) {
        timelineTabView.alpha = 0.5
        timelineTabBottomBorder.hidden = true
        overviewTabView.alpha = 1.0
        overviewTabBottomBorder.hidden = false
        addFriendbutton.hidden = false
    }
}


