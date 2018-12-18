//
//  PKSwipeTableViewCell.swift
//  PKSwipeTableViewCell
//
//  Created by Pradeep Kumar Yadav on 16/04/16.
//  Copyright © 2016 iosbucket. All rights reserved.
//

protocol PKSwipeCellDelegateProtocol {
    func swipeBeginInCell(_ cell:PKSwipeTableViewCell)
    func swipeDoneOnPreviousCell()->PKSwipeTableViewCell?
}

protocol YonaUserCellDelegate {
    func messageNeedToBeDeleted(_ cell: YonaUserTableViewCell, message: Message);
}

protocol CommentCellDelegate {
    func deleteComment(_ cell: CommentControlCell, comment: Comment);
    func showSendComment(_ comment: Comment?);
}

protocol DeleteTimezoneCellDelegateProtocol {
    func deleteTimezone(_ cell: TimeZoneTableViewCell);
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
    fileprivate var viewRightAccessory = UIView()
    fileprivate var backview:UIView = UIView()
    
    
    //MARK: Cell Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        resetCellState()
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) {
            let point =  (gestureRecognizer as! UIPanGestureRecognizer).translation(in: self.superview)
            return ((fabs(point.x) / fabs(point.y))) > 1 ? true : false
        }
        return false
    }
    
    //MARK: Private Functions
    /**
    This Method is used to initialize the cell with pan gesture and back views.
    
    */
    @available(iOS 8.0, *)
    fileprivate func initializeCell() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PKSwipeTableViewCell.handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        let cellFrame = CGRect(x: 0, y: 0,width: self.screenBoundsFixedToPortraitOrientation().height, height: self.frame.size.height)
        let viewBackground = UIView(frame: cellFrame)
        self.backgroundView = viewBackground
        self.backview =  UIView(frame:cellFrame)
        self.backview.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.isExclusiveTouch = true
        self.contentView.isExclusiveTouch = true
        self.backview.isExclusiveTouch = true
    }
    
    /**
     This function is used to get the screen frame independent of orientation
     
     - returns: frame of screen
     */
    @available(iOS 8.0, *)
    func screenBoundsFixedToPortraitOrientation()->CGRect {
        let screen = UIScreen.main
        if screen.responds(to: #selector(getter: UIScreen.fixedCoordinateSpace)) {
            return screen.coordinateSpace.convert(screen.bounds, to: screen.fixedCoordinateSpace)
        }
        return screen.bounds
    }
    
    /**
    This Method will be called when user will start the panning
    
    - parameter panGestureRecognizer: panGesture Object
    */
    @objc func handlePanGesture(_ panGestureRecognizer : UIPanGestureRecognizer) {
        if isPanEnabled == false{
            return
        }
        if  ((self.pkdelegate?.responds(to: #selector(PKSwipeTableViewCell.swipeDoneOnPreviousCell))) != nil) {
            let cell = self.pkdelegate?.swipeDoneOnPreviousCell()
            if cell != self && cell != nil {
                cell?.resetCellState()
            }
        }
        if  ((self.pkdelegate?.responds(to: Selector.init(stringLiteral: "swipeBeginInCell"))) != nil) {
            self.pkdelegate?.swipeBeginInCell(self)
        }
        let translation =  panGestureRecognizer.translation(in: panGestureRecognizer.view)
        let velocity = panGestureRecognizer .velocity(in: panGestureRecognizer.view)
        let panOffset = translation.x
        let actualTranslation = CGPoint(x: panOffset, y: translation.y)
        
        if panGestureRecognizer.state == UIGestureRecognizer.State.began && panGestureRecognizer.numberOfTouches > 0 {
            //start swipe
            self.backgroundView!.addSubview(backview)
            self.backgroundView?.bringSubviewToFront(self.backview)
            self.backview.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight ,UIView.AutoresizingMask.flexibleWidth]
            animateContentViewForPoint(actualTranslation, velocity: velocity)
        } else if(panGestureRecognizer.state == UIGestureRecognizer.State.changed && panGestureRecognizer.numberOfTouches > 0) {
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
    fileprivate func animateContentViewForPoint(_ point:CGPoint, velocity:CGPoint) {
        if (point.x < 0) {
            self.contentView.frame = self.contentView.bounds.offsetBy(dx: point.x, dy: 0)
            self.viewRightAccessory.frame = CGRect(x: max(self.frame.maxX-self.viewRightAccessory.frame.width,self.contentView.frame.maxX), y: self.viewRightAccessory.frame.minY, width: self.viewRightAccessory.frame.width, height: self.viewRightAccessory.frame.height)
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0);
                self.resetCellState()
                }, completion: { (Bool) -> Void in
            }) 
        }
    }
    
    /**
    This function is called to reset the panning state. If panning is less then it will reset to the original position depending on panning direction.
    
    - parameter point:    point of panning
    - parameter velocity: velocity of panning
    */
    fileprivate func resetCellFromPoint(_ point:CGPoint, withVelocity velocity:CGPoint) {
        if (point.x > 0 && point.x <= self.frame.height) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0);
                self.viewRightAccessory.frame = CGRect(x: self.contentView.frame.maxX, y: 0, width: self.viewRightAccessory.frame.width, height: self.frame.height)
                }, completion: { (Bool) -> Void in
            }) 
        } else if point.x < 0 {
            if (point.x < -self.viewRightAccessory.frame.width) {
                // SCROLL MORE THAN VIEW ACCESSORY
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.contentView.frame = self.contentView.bounds.offsetBy(dx: -self.viewRightAccessory.frame.width, dy: 0);
                    }, completion: { (Bool) -> Void in
                }) 
            } else if -point.x < self.viewRightAccessory.frame.width {
                // IF SCROLL MORE THAN 50% THEN MAKE THE OPTIONS VISIBLE
                if -point.x > self.viewRightAccessory.frame.size.width / 2.0 {
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.contentView.frame = self.contentView.bounds.offsetBy(dx: -self.viewRightAccessory.frame.width, dy: 0)
                        self.viewRightAccessory.frame = CGRect(x: UIScreen.main.bounds.size.width - self.viewRightAccessory.frame.width, y: 0, width: self.viewRightAccessory.frame.width, height: self.frame.height)
                        
                        
                        }, completion: { (Bool) -> Void in
                    }) 
                    
                }else {  // IF SCROLL LESS THEN MOVE TO ORIGINAL STATE
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0);
                        self.viewRightAccessory.frame = CGRect(x: self.contentView.frame.maxX, y: 0, width: self.viewRightAccessory.frame.width, height: self.frame.height)
                        }, completion: { (Bool) -> Void in
                    }) 
                }
            }
        }
    }
    
    //MARK: public Methods
    /**
    This function is used to add the view in right side
    
    - parameter view: view to be displayed on the right hsnd side of the cell
    */
    internal func addRightOptionsView(_ view:UIView) {
        viewRightAccessory.removeFromSuperview()
        viewRightAccessory = view
        viewRightAccessory.autoresizingMask = UIView.AutoresizingMask.flexibleLeftMargin
        self.backview.addSubview(viewRightAccessory)
    }

    /**
    This function is used to reset the cell state back to original position to hide the right view options.
    */
    func resetCellState() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0);
            self.viewRightAccessory.frame = CGRect(x: self.contentView.frame.maxX, y: 0, width: self.viewRightAccessory.frame.width, height: self.frame.height)
            }, completion: { (Bool) -> Void in
        }) 
    }
    
    func swipeBeginInCell(_ cell: PKSwipeTableViewCell) {
    }
    
    @objc func swipeDoneOnPreviousCell() -> PKSwipeTableViewCell? {
        return self
    }
}
