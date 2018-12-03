//
//  YonaButtonTableViewCell.swift
//  Yona
//
//  Created by Anders Liebl on 21/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaButtonTableViewCellProtocol {
    func didSelectButton(_ button: UIButton)
    
}

class YonaButtonTableViewCell : UITableViewCell{

   
    @IBOutlet weak var theButton: UIButton!

    var delegate : YonaButtonTableViewCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        theButton.layer.cornerRadius = theButton.frame.size.height/2
        theButton.layer.masksToBounds = true
        theButton.layer.borderColor = UIColor.yiMidBlueColor().cgColor
        theButton.layer.borderWidth = 1
        theButton.backgroundColor = UIColor.yiWhiteColor()
        theButton.setTitleColor(UIColor.yiMidBlueColor(), for: UIControl.State())
    
        theButton.setTitle(NSLocalizedString("friendprofile.button.title", comment: ""), for: UIControl.State())
    }
    
    func setButtonTitle(_ title:String) {
        theButton.setTitle(NSLocalizedString("friendprofile.button.title", comment: ""), for: UIControl.State())
    
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
       delegate?.didSelectButton(sender)
    }
}
