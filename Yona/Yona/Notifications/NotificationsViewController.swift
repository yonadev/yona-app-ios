//
//  NotificationsViewController.swift
//  Yona
//
//  Created by Ben Smith on 19/05/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class NotificationsViewController: UITableViewController {
    
    //MARK: searchResultMovies hold the movie search results
    var messages = [Message]() {
        didSet{
            //everytime savedarticles is added to or deleted from table is refreshed
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("notifcationsCell") as! NotificationsCell
        let row = indexPath.row
    }
}