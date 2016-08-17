//
//  PKSwipeTableViewCell.swift
//  PKSwipeTableViewCell
//
//  Created by Pradeep Kumar Yadav on 16/04/16.
//  Copyright © 2016 iosbucket. All rights reserved.
//

protocol PKSwipeCellDelegateProtocol {
    func swipeBeginInCell(cell:PKSwipeTableViewCell)
    func swipeDoneOnPreviousCell()->PKSwipeTableViewCell?
}

protocol YonaUserCellDelegate {
    func messageNeedToBeDeleted(cell: YonaUserTableViewCell, message: Message);
}

protocol CommentCellDelegate {
    func deleteComment(cell: CommentControlCell, comment: Comment);
    func showSendComment();

}

protocol DeleteTimezoneCellDelegateProtocol {
    func deleteTimezone(cell: TimeZoneTableViewCell);
}

import UIKit

class PKSwipeTableViewCell: UITableViewCell , PKSwipeCellDelegateProtocol {
    
    //MARK: Variables
    //Set the delegate object
    internal var commentDelegate:CommentCellDelegate?
    internal var yonaUserDelegate:YonaUserCellDelegate?
    internal var pkdelegate:PKSwipeTableViewCell?
    internal var timezoneCellDelegate:DeleteTimezoneCellDelegateProtocol?

    //set the view of right Side
    internal var isPanEnabled = true
    private var viewRightAccessory = UIView()
    private var backview:UIView = UIView()
    
    
    //MARK: Cell Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        resetCellState()
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if #available(iOS 8.0, *) {
            initializeCell()
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if #available(iOS 8.0, *) {
            initializeCell()
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: Gesture Method
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer.classForCoder()) {
            let point =  (gestureRecognizer as! UIPanGestureRecognizer).translationInView(self.superview)
            return ((fabs(point.x) / fabs(point.y))) > 1 ? true : false
        }
        return false
    }
    
    //MARK: Private Functions
    /**
    This Method is used to initialize the cell with pan gesture and back views.
    
    */
    @available(iOS 8.0, *)
    private func initializeCell() {
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        let cellFrame = CGRectMake(0, 0,self.screenBoundsFixedToPortraitOrientation().height, self.frame.size.height)
        let viewBackground = UIView(frame: cellFrame)
        self.backgroundView = viewBackground
        self.backview =  UIView(frame:cellFrame)
        self.backview.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.exclusiveTouch = true
        self.contentView.exclusiveTouch = true
        self.backview.exclusiveTouch = true
    }
    
    /**
     This function is used to get the screen frame independent of orientation
     
     - returns: frame of screen
     */
    @available(iOS 8.0, *)
    func screenBoundsFixedToPortraitOrientation()->CGRect {
        let screen = UIScreen.mainScreen()
        if screen.respondsToSelector("fixedCoordinateSpace") {
            return screen.coordinateSpace.convertRect(screen.bounds, toCoordinateSpace: screen.fixedCoordinateSpace)
        }
        return screen.bounds
    }
    
    /**
    This Method will be called when user will start the panning
    
    - parameter panGestureRecognizer: panGesture Object
    */
    func handlePanGesture(panGestureRecognizer : UIPanGestureRecognizer) {
        if isPanEnabled == false{
            return
        }
        if  ((self.pkdelegate?.respondsToSelector(Selector.init(stringLiteral: "swipeDoneOnPreviousCell"))) != nil) {
            let cell = self.pkdelegate?.swipeDoneOnPreviousCell()
            if cell != self && cell != nil {
                cell?.resetCellState()
            }
        }
        if  ((self.pkdelegate?.respondsToSelector(Selector.init(stringLiteral: "swipeBeginInCell"))) != nil) {
            self.pkdelegate?.swipeBeginInCell(self)
        }
        let translation =  panGestureRecognizer.translationInView(panGestureRecognizer.view)
        let velocity = panGestureRecognizer .velocityInView(panGestureRecognizer.view)
        let panOffset = translation.x
        let actualTranslation = CGPointMake(panOffset, translation.y)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began && panGestureRecognizer.numberOfTouches() > 0 {
            //start swipe
            self.backgroundView!.addSubview(backview)
            self.backgroundView?.bringSubviewToFront(self.backview)
            self.backview.autoresizingMask = [UIViewAutoresizing.FlexibleHeight ,UIViewAutoresizing.FlexibleWidth]
            animateContentViewForPoint(actualTranslation, velocity: velocity)
        } else if(panGestureRecognizer.state == UIGestureRecognizerState.Changed && panGestureRecognizer.numberOfTouches() > 0) {
            //animate
            animateContentViewForPoint(actualTranslation, velocity: velocity)
        } else {
            //reset the state
            self.resetCellFromPoint(actualTranslation, withVelocity: velocity)
        }
    }
    
    /**
    This function is called when panning will start to update the frames to show the panning
    
    - parameter point:    point of panning
    - parameter velocity: velocity of panning
    */
    private func animateContentViewForPoint(point:CGPoint, velocity:CGPoint) {
        if (point.x < 0) {
            self.contentView.frame = CGRectOffset(self.contentView.bounds, point.x, 0)
            self.viewRightAccessory.frame = CGRectMake(max(CGRectGetMaxX(self.frame)-CGRectGetWidth(self.viewRightAccessory.frame),CGRectGetMaxX(self.contentView.frame)), CGRectGetMinY(self.viewRightAccessory.frame), CGRectGetWidth(self.viewRightAccessory.frame), CGRectGetHeight(self.viewRightAccessory.frame))
        } else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                self.resetCellState()
                }) { (Bool) -> Void in
            }
        }
    }
    
    /**
    This function is called to reset the panning state. If panning is less then it will reset to the original position depending on panning direction.
    
    - parameter point:    point of panning
    - parameter velocity: velocity of panning
    */
    private func resetCellFromPoint(point:CGPoint, withVelocity velocity:CGPoint) {
        if (point.x > 0 && point.x <= CGRectGetHeight(self.frame)) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                self.viewRightAccessory.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetWidth(self.viewRightAccessory.frame), CGRectGetHeight(self.frame))
                }) { (Bool) -> Void in
            }
        } else if point.x < 0 {
            if (point.x < -CGRectGetWidth(self.viewRightAccessory.frame)) {
                // SCROLL MORE THAN VIEW ACCESSORY
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.contentView.frame = CGRectOffset(self.contentView.bounds, -CGRectGetWidth(self.viewRightAccessory.frame), 0);
                    }) { (Bool) -> Void in
                }
            } else if -point.x < CGRectGetWidth(self.viewRightAccessory.frame) {
                // IF SCROLL MORE THAN 50% THEN MAKE THE OPTIONS VISIBLE
                if -point.x > self.viewRightAccessory.frame.size.width / 2.0 {
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.contentView.frame = CGRectOffset(self.contentView.bounds, -CGRectGetWidth(self.viewRightAccessory.frame), 0)
                        self.viewRightAccessory.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - CGRectGetWidth(self.viewRightAccessory.frame), 0, CGRectGetWidth(self.viewRightAccessory.frame), CGRectGetHeight(self.frame))
                        
                        
                        }) { (Bool) -> Void in
                    }
                    
                }else {  // IF SCROLL LESS THEN MOVE TO ORIGINAL STATE
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
                        self.viewRightAccessory.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetWidth(self.viewRightAccessory.frame), CGRectGetHeight(self.frame))
                        }) { (Bool) -> Void in
                    }
                }
            }
        }
    }
    
    //MARK: public Methods
    /**
    This function is used to add the view in right side
    
    - parameter view: view to be displayed on the right hsnd side of the cell
    */
    internal func addRightOptionsView(view:UIView) {
        viewRightAccessory.removeFromSuperview()
        viewRightAccessory = view
        viewRightAccessory.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        self.backview.addSubview(viewRightAccessory)
    }

    /**
    This function is used to reset the cell state back to original position to hide the right view options.
    */
    func resetCellState() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 0, 0);
            self.viewRightAccessory.frame = CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetWidth(self.viewRightAccessory.frame), CGRectGetHeight(self.frame))
            }) { (Bool) -> Void in
        }
    }
    
    func swipeBeginInCell(cell: PKSwipeTableViewCell) {
    }
    
    func swipeDoneOnPreviousCell() -> PKSwipeTableViewCell? {
        return self
    }
}