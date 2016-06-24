//
//  YonaTwoButtonsTableViewController.swift
//  Yona
//
//  Created by Anders Liebl on 17/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit


enum currentSelectedTab {
    case left
    case right
}
class YonaTwoButtonsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var leftTabMainView: UIView!
    @IBOutlet weak var leftTabLabel: UILabel!
    @IBOutlet weak var leftTabSelcetionView: UIView!
    
    @IBOutlet weak var rightTabMainView: UIView!
    @IBOutlet weak var rightTabLabel: UILabel!
    @IBOutlet weak var rightTabSelectionsView: UIView!

    var selectedTab : currentSelectedTab = .left
    
    var isFromfriends = true
    
// MARK: - Table view data source
    /*
       The methods below MUST be overriden if this class is Inherit
     
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      print("ERROR 'numberOfSectionsInTableView' has not been overiden")
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ERROR 'numberOfRowsInSection' has not been overiden")
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("ERROR 'cellForRowAtIndexPath' has not been overiden")
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
        
    }

    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //
    //    }

    //    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //    }
    
    
// MARK: TabButtons Actions
    @IBAction func showLeftTab (sender : AnyObject) {
        leftTabLabel.alpha = 1.0
        leftTabSelcetionView.hidden = false
        
        rightTabSelectionsView.hidden = true
        rightTabLabel.alpha = 0.5
        
        selectedTab = .left
        actionsAfterLeftButtonPush()
    }
    @IBAction func showRightTab (sender : AnyObject) {
        leftTabLabel.alpha = 0.5
        leftTabSelcetionView.hidden = true
        
        rightTabSelectionsView.hidden = false
        rightTabLabel.alpha = 1.0
        
        selectedTab = .right
        actionsAfterRightButtonPush()
    }

    
    func actionsAfterLeftButtonPush() {
        // The subController must override this to have any action after the tabe selection
    }

    func actionsAfterRightButtonPush() {
        // The subController must override this to have any action after the tabe selection
    }

    
}