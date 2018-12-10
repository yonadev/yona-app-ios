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
    
    @IBAction func leftButtonPushed(_ sender :UIButton) {
        delegate?.leftButtonPushed()
    }

    @IBAction func rightButtonPushed(_ sender :UIButton) {
        delegate?.rightButtonPushed()
    }

    func configureAsLast() {
        leftButton.isHidden = true
        rightButton.isHidden = false
    }

    func configureAsFirst() {
        leftButton.isHidden = false
        rightButton.isHidden = true
    }

    func configureWithNone() {
        leftButton.isHidden = true
        rightButton.isHidden = true
    }
    
    func configureWithBoth() {
        leftButton.isHidden = false
        rightButton.isHidden = false
    }

}
