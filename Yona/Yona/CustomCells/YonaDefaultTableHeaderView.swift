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
        headerTextLabel.backgroundColor = UIColor.yiTableBGGreyColor()
    }
    
    @IBOutlet weak var headerTextLabel: UILabel!
    
}