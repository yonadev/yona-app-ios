//
//  YonaDefaultTableHeaderView.swift
//  Yona
//
//  Created by Anders Liebl on 19/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class YonaDefaultTableHeaderView: UITableViewHeaderFooterView {

    override func awakeFromNib() {
        super.awakeFromNib()
        coverUpView.backgroundColor = UIColor.yiWhiteThreeColor()
        headerTextLabel.backgroundColor = UIColor.yiTableBGGreyColor()
    }
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var coverUpView : UIImageView!
}