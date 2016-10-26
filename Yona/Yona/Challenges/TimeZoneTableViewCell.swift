//
//  TimeZoneTableViewCell.swift
//  Yona
//
//  Created by Chandan on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeZoneTableViewCell: PKSwipeTableViewCell {
    private var values = (from: "", to: "")
    let pickerData = ["11", "12", "13"]
    @IBOutlet var fromButton:UIButton!
    @IBOutlet var toButton:UIButton!
    @IBOutlet var rowNumber:UILabel!
    typealias fromButtonClicked = (TimeZoneTableViewCell) -> ()
    typealias toButtonClicked = (TimeZoneTableViewCell) -> ()
    
    var gFrombuttonClicked: fromButtonClicked?
    var gTobuttonClicked: toButtonClicked?
    var indexPath: NSIndexPath?
    var gradientView: GradientSmooth!
    
    override func awakeFromNib() {
        addRightViewInCell()
    }
    
    func addRightViewInCell() {
        gradientView = GradientSmooth.init(frame: self.frame)
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())

        //Create a view that will display when user swipe the cell in right
        let viewCall = UIView()
        viewCall.backgroundColor = UIColor.yiDarkishPinkColor()
        viewCall.frame = CGRectMake(0,0, self.frame.size.height, self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButtonType.Custom)
        btnCall.frame = CGRectMake(0,0,viewCall.frame.size.width,viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), forState: UIControlState.Normal)
        btnCall.addTarget(self, action: "deleteCell", forControlEvents: UIControlEvents.TouchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
        self.addSubview(gradientView)
        self.sendSubviewToBack(gradientView)

    }
    
    
    func deleteCell(){
        if let timezoneCellDelegate = timezoneCellDelegate{
            timezoneCellDelegate.deleteTimezone(self)
        }
    }
    
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
