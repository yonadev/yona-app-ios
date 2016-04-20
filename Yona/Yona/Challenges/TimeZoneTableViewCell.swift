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
    
    @IBOutlet var fromButton:UIButton!
    @IBOutlet var toButton:UIButton!
    @IBOutlet var rowNumber:UILabel!
    typealias fromButtonClicked = (UITableViewCell) -> ()
    typealias toButtonClicked = (UITableViewCell) -> ()
    
    var gFrombuttonClicked: fromButtonClicked?
    var gTobuttonClicked: toButtonClicked?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configure (data:(from: String, to: String), fromButtonListener: fromButtonClicked, toButtonListener: toButtonClicked) {
        values.from = data.from
        values.to = data.to
        gFrombuttonClicked = fromButtonListener
        gTobuttonClicked = toButtonListener
    }
    
    @IBAction func frombuttonTapped(sender: UIButton) {
        gFrombuttonClicked!(self)
    }
    
    @IBAction func tobuttonTapped(sender: UIButton) {
        gTobuttonClicked!(self)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        print(values.from + values.to)
    }

}
