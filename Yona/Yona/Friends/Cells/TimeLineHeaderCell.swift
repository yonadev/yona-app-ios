//
//  TimeLineHeaderCell.swift
//  Yona
//
//  Created by Anders Liebl on 06/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class TimeLineHeaderCell: UITableViewCell {
    
    @IBOutlet weak var typeTiltle: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    @IBOutlet weak var gradientView: GradientSmooth!
    
    override func awakeFromNib() {
        infoLabel.text = NSLocalizedString("meday.nogo.minutes", comment: "")
        typeTiltle.textColor = UIColor.yiBlackColor()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
    }
    override func prepareForReuse() {
        typeTiltle.text = ""
        
    }
    
    func setCellTitle (_ text : String) {
        typeTiltle.text = text
    }
    
    
    
}
