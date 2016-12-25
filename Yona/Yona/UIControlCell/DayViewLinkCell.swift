//
//  DayViewLinkCell.swift
//  Yona
//
//  Created by Anders Liebl on 25/12/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


class DayViewLinkCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var violationLinkURL: UILabel!
    @IBOutlet weak var violationTime: UILabel!

    @IBOutlet weak var gradientView: GradientSmooth!
    //MARK: - override methods
    override func layoutSubviews() {
        super.layoutSubviews()
        //contentView.layoutIfNeeded()
        setupGradient()
    }
    
    func setupGradient () {
        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
        
    }


    func setData(linkURL : String, startDate : NSDate) {
        cellTitle.text = NSLocalizedString("link.cell.title", comment: "")
        
        violationLinkURL.text = linkURL
        violationLinkURL.sizeToFit()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let txt = formatter.stringFromDate(startDate)
        violationTime.text = txt
    
    
    }
}
