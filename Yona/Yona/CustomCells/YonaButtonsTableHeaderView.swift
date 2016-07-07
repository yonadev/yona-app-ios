//
//  YonaButtonsTableHeaderView.swift
//  Yona
//
//  Created by Anders Liebl on 19/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

protocol YonaButtonsTableHeaderViewProtocol {
    func leftButtonPushed()
    func rightButtonPushed()
}

class YonaButtonsTableHeaderView: UITableViewHeaderFooterView {

    override func awakeFromNib() {
        super.awakeFromNib()
        headerTextLabel.backgroundColor = UIColor.yiTableBGGreyColor()
    }
    
    var delegate : YonaButtonsTableHeaderViewProtocol?
    @IBOutlet weak var headerTextLabel: UILabel!

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBAction func leftButtonPushed(sender :UIButton) {
        delegate?.leftButtonPushed()
    }

    @IBAction func rightButtonPushed(sender :UIButton) {
        delegate?.rightButtonPushed()
    }

    func configureAsLast() {
        leftButton.hidden = true
        rightButton.hidden = false
    }

    func configureAsFirst() {
        leftButton.hidden = false
        rightButton.hidden = true
    }

    func configureWithNone() {
        leftButton.hidden = true
        rightButton.hidden = true
    }
    
    func configureWithBoth() {
        leftButton.hidden = false
        rightButton.hidden = false
    }

}