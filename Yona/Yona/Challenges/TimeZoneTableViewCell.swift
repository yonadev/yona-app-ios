//
//  TimeZoneTableViewCell.swift
//  Yona
//
//  Created by Chandan on 20/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeZoneTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    private var values = (from: "", to: "")
    let pickerData = ["11", "12", "13"]
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
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, self.frame.width, 300))
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donePicker"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donePicker"))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
//        textField1.inputView = picker
//        textField1.inputAccessoryView = toolBar
        
    }
    
    @IBAction func tobuttonTapped(sender: UIButton) {
        gTobuttonClicked!(self)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        print(values.from + values.to)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fromButton.setTitle(pickerData[row] , forState: UIControlState.Normal)
//        textField1.text = pickerData[row]
    }
}
