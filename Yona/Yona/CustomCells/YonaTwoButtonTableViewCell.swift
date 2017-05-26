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

class YonaTwoButtonTableViewCell : UITableViewCell {

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    

    var delegate : YonaTwoButtonTableViewCellProtocol?
    var message : Message?
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()

        addGradient()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.text =  NSLocalizedString("notifications.accept.type", comment: "")
        
        /*leftButton.layer.cornerRadius = leftButton.frame.size.height/2
        leftButton.layer.masksToBounds = true
        leftButton.backgroundColor = UIColor.yiDarkishPinkColor()
        leftButton.setTitleColor(UIColor.yiWhiteColor(), forState: UIControlState.Normal) */
        
        leftButton.setTitle(NSLocalizedString("notifications.accept.reject", comment: ""), forState: UIControlState.Normal)
        
       /* rightButton.layer.cornerRadius = rightButton.frame.size.height/2
        rightButton.layer.masksToBounds = true
        rightButton.backgroundColor = UIColor.yiPeaColor()
        rightButton.setTitleColor(UIColor.yiWhiteColor(), forState: UIControlState.Normal) */
    
        rightButton.setTitle(NSLocalizedString("notifications.accept.accept", comment: ""), forState: UIControlState.Normal)
    }
    
    func setNumber(message: Message){
        self.message = message
        let num = message.UserRequestmobileNumber
        let text = String(format:  NSLocalizedString("notifications.accept.number", comment: ""), num)
        
        numberLabel.text = text

    }
    
    @IBAction func rightButtonAction(sender: UIButton) {
        delegate?.didSelectRightButton(sender)
    }
    
    
    @IBAction func leftButtonAction(sender: UIButton) {
       delegate?.didSelectLeftButton(sender)
    }
    
    func addGradient() {
        
        let colorTop =  UIColor.yiBgGradientOneColor().CGColor
        let colorBottom = UIColor.yiBgGradientTwoColor().CGColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 0.5]
        gradientLayer.frame =  gradientView.bounds
        
        gradientView.layer.addSublayer(gradientLayer)

    }
    
    @IBAction func callNumber () {
        if let msg = message {
            if let aURL = NSURL(string: "telprompt://\(msg.UserRequestmobileNumber)") {
                UIApplication.sharedApplication().openURL(aURL)
            }
        }

    }
    
}
