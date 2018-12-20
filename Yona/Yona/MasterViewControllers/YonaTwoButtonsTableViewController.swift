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
    @IBOutlet weak var theTableView: UITableView!
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaTwoButtonsTableViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
        
        UIBarButtonItem.appearance().tintColor = UIColor.yiWhiteColor()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      print("ERROR 'numberOfSectionsInTableView' has not been overiden")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ERROR 'numberOfRowsInSection' has not been overiden")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("ERROR 'cellForRowAtIndexPath' has not been overiden")
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
        
    }

    
    
// MARK: TabButtons Actions
    @IBAction func showLeftTab (_ sender : AnyObject) {
        leftTabLabel.alpha = 1.0
        leftTabSelcetionView.isHidden = false
        
        rightTabSelectionsView.isHidden = true
        rightTabLabel.alpha = 0.5
        
        selectedTab = .left
        actionsAfterLeftButtonPush()
    }
    @IBAction func showRightTab (_ sender : AnyObject) {
        leftTabLabel.alpha = 0.5
        leftTabSelcetionView.isHidden = true
        
        rightTabSelectionsView.isHidden = false
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
