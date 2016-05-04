//
//  SettingsViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var settingsArray:NSArray!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var gradientView: GradientView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().statusBarHidden = true
        settingsArray = [ "Wijzig pincode", "Privacy", "Device toevoegen"]
        tableView.tableFooterView = UIView(frame: CGRectZero)
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiMangoColor(), UIColor.yiMangoColor()]
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = settingsArray[indexPath.row] as? String;
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index  \(indexPath)")
        print("index  \(self.navigationController)")
        if indexPath.row == 2 {
            //Display Alert here
        }
    }
}

func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.settingsArray.count
}


func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    cell.textLabel?.text = settingsArray[indexPath.row] as? String;
    return cell
}


func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("index  \(indexPath)")
    print("index  \(self.navigationController)")
    if indexPath.row == 2 {
        NewDeviceRequestManager.sharedInstance.putNewDevice({ (success, message, code, addDeviceCode) in
            NewDeviceRequestManager.sharedInstance.deleteNewDevice({ (success, message, code) in
                let localizedString = NSLocalizedString("adddevice.user.AddDevicePasscodeMessage", comment: "")
                if let addDeviceCode = addDeviceCode {
                    self.displayAlertMessage("", alertDescription: String(format: localizedString, addDeviceCode))
                }
            })
        })
    }

}

}
