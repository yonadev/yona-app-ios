//
//  YonaTwoButtonTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 21/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaTwoButtonTableViewCellProtocol {
    func didSelectRightButton(button: UIButton)
    func didSelectLeftButton(button: UIButton)
}

class YonaTwoButtonTableViewCell : UITableViewCell{

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    var delegate : YonaTwoButtonTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        leftButton.layer.cornerRadius = leftButton.frame.size.height/2
        leftButton.layer.masksToBounds = true
        leftButton.backgroundColor = UIColor.yiDarkishPinkColor()
        leftButton.setTitleColor(UIColor.yiWhiteColor(), forState: UIControlState.Normal)
        
        rightButton.layer.cornerRadius = rightButton.frame.size.height/2
        rightButton.layer.masksToBounds = true
        rightButton.backgroundColor = UIColor.yiPeaColor()
        rightButton.setTitleColor(UIColor.yiWhiteColor(), forState: UIControlState.Normal)
    }
    
    
    @IBAction func rightButtonAction(sender: AnyObject) {
    }
    
    
    @IBAction func leftButtonAction(sender: AnyObject) {
       
    }
}