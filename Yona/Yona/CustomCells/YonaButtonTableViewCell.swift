//
//  YonaButtonTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 21/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaButtonTableViewCellProtocol {
    func didSelectButton(button: UIButton)
    
}

class YonaButtonTableViewCell : UITableViewCell{

   
    @IBOutlet weak var theButton: UIButton!

    var delegate : YonaButtonTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        theButton.layer.cornerRadius = theButton.frame.size.height/2
        theButton.layer.masksToBounds = true
        theButton.layer.borderColor = UIColor.yiMidBlueColor().CGColor
        theButton.layer.borderWidth = 1
        theButton.backgroundColor = UIColor.yiWhiteColor()
        theButton.setTitleColor(UIColor.yiMidBlueColor(), forState: UIControlState.Normal)
    
        theButton.setTitle(NSLocalizedString("friendprofile.button.title", comment: ""), forState: UIControlState.Normal)
    }
    
    func setButtonTitle(title:String) {
        theButton.setTitle(NSLocalizedString("friendprofile.button.title", comment: ""), forState: UIControlState.Normal)
    
    }
    
    @IBAction func buttonAction(sender: UIButton) {
       delegate?.didSelectButton(sender)
    }
}