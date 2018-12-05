//
//  TimeZoneTableViewCell.swift
//  Yona
//
//  Created by Chandan on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeZoneTableViewCell: PKSwipeTableViewCell {
    fileprivate var values = (from: "", to: "")
    let pickerData = ["11", "12", "13"]
    @IBOutlet var fromButton:UIButton!
    @IBOutlet var toButton:UIButton!
    @IBOutlet var rowNumber:UILabel!
    typealias fromButtonClicked = (TimeZoneTableViewCell) -> ()
    typealias toButtonClicked = (TimeZoneTableViewCell) -> ()
    
    var gFrombuttonClicked: fromButtonClicked?
    var gTobuttonClicked: toButtonClicked?
    var indexPath: IndexPath?
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
        viewCall.frame = CGRect(x: 0,y: 0, width: self.frame.size.height, height: self.frame.size.height)
        //Add a button to perform the action when user will tap on call and add a image to display
        let btnCall = UIButton(type: UIButton.ButtonType.custom)
        btnCall.frame = CGRect(x: 0,y: 0,width: viewCall.frame.size.width,height: viewCall.frame.size.height)
        btnCall.setImage(UIImage(named: "icnDelete"), for: UIControl.State())
        btnCall.addTarget(self, action: #selector(TimeZoneTableViewCell.deleteCell), for: UIControl.Event.touchUpInside)
        
        viewCall.addSubview(btnCall)
        //Call the super addRightOptions to set the view that will display while swiping
        super.addRightOptionsView(viewCall)
        self.addSubview(gradientView)
        self.sendSubviewToBack(gradientView)

    }
    
    
    @objc func deleteCell(){
        if let timezoneCellDelegate = timezoneCellDelegate{
            timezoneCellDelegate.deleteTimezone(self)
        }
    }
    
    func configureWithFromTime(_ from: String, toTime to: String, fromButtonListener: @escaping fromButtonClicked, toButtonListener: @escaping toButtonClicked) {
        fromButton.setTitle(from, for: UIControl.State())
        toButton.setTitle(to, for: UIControl.State())
        gFrombuttonClicked = fromButtonListener
        gTobuttonClicked = toButtonListener
    }
    
    
    @IBAction func frombuttonTapped(_ sender: UIButton) {
        gFrombuttonClicked!(self)
    }
    
    @IBAction func tobuttonTapped(_ sender: UIButton) {
        gTobuttonClicked!(self)
    }
}
