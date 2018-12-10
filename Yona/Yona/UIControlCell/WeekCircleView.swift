//
//  WeekCircleView.swift
//  Yona
//
//  Created by Anders Liebl on 30/06/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import UIKit

enum circleViewStatus {
    case overGoal
    case underGoal
    case review
    case noData
    
    func circleColor() -> UIColor{
        switch self {
        case .overGoal:
            return UIColor.yiDarkishPinkColor()
        case .underGoal:
            return UIColor.yiPeaColor()
        case .review:
            return UIColor.yiMangoColor()
        case .noData:
            return UIColor.yiGraphBarTwoColor()
        }
    }

    func circleBorderColor() -> UIColor{
        switch self {
        case .overGoal:
            return UIColor.yiDarkishPinkBorderColor()
        case .underGoal:
            return UIColor.yiPeaColor()
        case .review:
            return UIColor.yiMangoColor()
        case .noData:
            return UIColor.yiGraphBarTwoColor()
        }
    }

}

class WeekCircleView: UIView {

    
    @IBOutlet weak var dateText : UILabel!
    var theData : Date?
    var activity : SingleDayActivityGoal?
    var status : circleViewStatus = .noData
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.yiGraphBarTwoColor().cgColor
        dateText.textColor = UIColor.yiWhiteColor()
        
        layer.borderColor = UIColor.yiGraphBarTwoColor().cgColor
        layer.borderWidth = 1.0
        layer.backgroundColor = status.circleColor().cgColor
        layer.borderColor = status.circleBorderColor().cgColor

        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.yiGraphBarTwoColor().cgColor
        dateText.textColor = UIColor.yiWhiteColor()
        
        layer.borderColor = UIColor.yiGraphBarTwoColor().cgColor
        layer.borderWidth = 1.0

        layer.backgroundColor = status.circleColor().cgColor
        layer.borderColor = status.circleBorderColor().cgColor

    }
    
    func configureUI(_ aDate : Date, status : circleViewStatus = .noData) {
        theData = aDate
        self.status = status
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE\nd"
        dateText.text = dateFormatter.string(from: aDate)
        layer.backgroundColor = status.circleColor().cgColor
        layer.borderColor = status.circleBorderColor().cgColor
    }
    
}
