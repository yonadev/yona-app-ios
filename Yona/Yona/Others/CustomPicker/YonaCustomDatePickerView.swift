

import Foundation
import UIKit

class YonaCustomDatePickerView: UIView {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var title: UIBarButtonItem!
    typealias CancelListener = () -> ()
    typealias DoneListener = (NSDate) -> ()
    var gCancelListener: CancelListener?
    var gDoneListener: DoneListener?
    var selectedValue: NSDate?
    var parentView: UIView?
    
    @IBOutlet weak var cancelButtonTitle: UIBarButtonItem!
    @IBOutlet weak var okButtonTitle: UIBarButtonItem!
    @IBOutlet weak var pickerTitleLabel: UIBarButtonItem!
    
    @IBAction func cancelAction(sender: AnyObject) {
        gCancelListener?()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if selectedValue != nil{
            gDoneListener?(selectedValue!)
        }else{
            gDoneListener?(NSDate())
        }
        
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        selectedValue = datePicker.date
    }
    
    func loadDatePickerView() -> UIView {
        var views = NSBundle.mainBundle().loadNibNamed("YonaCustomDatePickerView", owner: self, options: nil)
        let view = views![0] as! UIView
        view.frame.origin.y = UIScreen.mainScreen().bounds.height + 200
        view.frame.size.width = UIScreen.mainScreen().bounds.width
        return view
    }
    
    
    func configure(onView v:UIView, withCancelListener cancel: CancelListener, andDoneListener done: DoneListener) {
        gCancelListener = cancel
        gDoneListener = done
        parentView = v
        title.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.yiBlackColor()], forState: UIControlState.Normal)
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
    }
    
    func pickerTitleLabel(title: String) {
        self.pickerTitleLabel.title = title
    }
    
    func hideShowDatePickerView(isToShow show: Bool) -> YonaCustomDatePickerView {
        cancelButtonTitle.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.yiMidBlueColor()], forState: UIControlState.Normal)
        okButtonTitle.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.yiMidBlueColor()], forState: UIControlState.Normal)
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    if show {
                                        self.frame.origin.y = self.parentView!.frame.size.height - 200
                                    } else {
                                        self.frame.origin.y = self.parentView!.frame.size.height + 200
                                    }
            },completion: nil)
        
        return self
    }
    
    
    func configureWithTime(date: NSDate) {
        selectedValue = date
        self.datePicker.setDate(date, animated: true)
    }
    
    
}
