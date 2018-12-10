//
//  TimelineTimeZoneCell.swift
//  Yona
//
//  Created by Anders Liebl on 07/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


class TimeLineTimeZoneCell : TimeZoneControlCell {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userInitial: UILabel!

    @IBOutlet weak var spacerView : UIView!
    var firstName = ""
    var lastName = ""
    var nickname = ""
    
    //time labels
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doInitialSetup()
        drawTheCell()
        dravTheUser()
//        gradientView.setGradientSmooth(UIColor.yiBgGradientTwoColor(), color2: UIColor.yiBgGradientOneColor())
    }

    
    
   override func doInitialSetup() {
        if goalType != nil {
            goalType!.text = goalNameText
        }
//        var fra = backgroundMinsView.frame
//        fra.size.width = frame.size.width-64
//        backgroundMinsView.frame = fra
//        
        pxPerSpread = self.backgroundMinsView.frame.size.width / 96
        pxPerMinute = pxPerSpread / 15
        
        fourleftConstraint.constant = fourLeftIndent * pxPerSpread - fourAm.frame.size.width/2
        self.fourAm.setNeedsLayout()
        
        eightAmConstraint.constant = eightLeftIndent * pxPerSpread - eightAM.frame.size.width/2
        self.eightAM.setNeedsLayout()
        
        sixteenHundredConstraint.constant = sixteenLeftIndent * pxPerSpread - sixteenHundred.frame.size.width/2
        self.sixteenHundred.setNeedsLayout()
        
        twentyHundredConstraint.constant = twentyLeftIndent * pxPerSpread - twentyHundred.frame.size.width/2
        self.twentyHundred.setNeedsLayout()
   
        userInitial.text = ""
        userInitial.textColor = UIColor.yiWhiteColor()
        
        
        userIcon.layer.borderWidth = 0.0
        userIcon.layer.masksToBounds = true
        userIcon.layer.cornerRadius = userIcon.frame.size.width/2
        

    }

    
    
    
    func setTimeLineData (_ timelineDayActivity : TimeLinedayActivitiesForUsers, animated: Bool) {
        spreadCells = timelineDayActivity.spread
        activitySpread = timelineDayActivity.spreadCells
        
        //goalNameText = timelineDayActivity.goalName
        
        
        totalMinutesBeyondGoal = timelineDayActivity.totalMinutesBeyondGoal
        totalActivityDurationMinutes = timelineDayActivity.totalActivityDurationMinutes
        if let bud = timelineDayActivity.buddy {
            firstName = bud.UserRequestfirstName
            lastName = bud.UserRequestlastName
            nickname = bud.buddyNickName
            userIcon.backgroundColor = UIColor.yiWindowsBlueColor()
        } else if let theUser = timelineDayActivity.user {
            firstName = theUser.firstName
            lastName = theUser.lastName
            nickname = theUser.nickname
            userIcon.backgroundColor = UIColor.yiGrapeColor()
        }

    }

    
    fileprivate func dravTheUser () {
        if nickname.characters.count > 0 {
            userInitial.text = "\(nickname.capitalized.characters.first!)"
        }

        //will crash if empty
//        if firstName.characters.count > 0 && lastName.characters.count > 0{
//            userInitial.text =  "\(firstName.capitalizedString.characters.first!) \(lastName.capitalizedString.characters.first!)"
//        }
        
    }

}
