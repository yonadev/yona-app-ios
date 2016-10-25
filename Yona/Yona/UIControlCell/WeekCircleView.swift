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
        case overGoal:
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
        case overGoal:
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
    var theData : NSDate?
    var activity : SingleDayActivityGoal?
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.yiGraphBarTwoColor().CGColor
        dateText.textColor = UIColor.yiWhiteColor()
        
        layer.borderColor = UIColor.yiGraphBarTwoColor().CGColor
        layer.borderWidth = 1.0
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.yiGraphBarTwoColor().CGColor
        dateText.textColor = UIColor.yiWhiteColor()
        
        layer.borderColor = UIColor.yiGraphBarTwoColor().CGColor
        layer.borderWidth = 1.0
    }
    
    func configureUI(aDate : NSDate, status : circleViewStatus = .noData) {
        theData = aDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EE\nd"
        dateText.text = dateFormatter.stringFromDate(aDate)
        layer.backgroundColor = status.circleColor().CGColor
        layer.borderColor = status.circleBorderColor().CGColor
    }
    
}