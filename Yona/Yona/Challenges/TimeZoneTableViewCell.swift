//
//  TimeZoneTableViewCell.swift
//  Yona
//
//  Created by Chandan on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeZoneTableViewCell: UITableViewCell {
    private var values = (from: "", to: "")
    let pickerData = ["11", "12", "13"]
    @IBOutlet var fromButton:UIButton!
    @IBOutlet var toButton:UIButton!
    @IBOutlet var rowNumber:UILabel!
    typealias fromButtonClicked = (TimeZoneTableViewCell) -> ()
    typealias toButtonClicked = (TimeZoneTableViewCell) -> ()
    
    var gFrombuttonClicked: fromButtonClicked?
    var gTobuttonClicked: toButtonClicked?
    
    
    
    func configureWithFromTime(from: String, toTime to: String, fromButtonListener: fromButtonClicked, toButtonListener: toButtonClicked) {
        fromButton.setTitle(from, forState: .Normal)
        toButton.setTitle(to, forState: .Normal)
        gFrombuttonClicked = fromButtonListener
        gTobuttonClicked = toButtonListener
    }
    
    
    @IBAction func frombuttonTapped(sender: UIButton) {
        gFrombuttonClicked!(self)
    }
    
    @IBAction func tobuttonTapped(sender: UIButton) {
        gTobuttonClicked!(self)
    }
}
