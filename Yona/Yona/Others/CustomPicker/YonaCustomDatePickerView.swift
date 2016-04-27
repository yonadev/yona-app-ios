

import Foundation
import UIKit

class YonaCustomDatePickerView: UIView {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    typealias CancelListener = () -> ()
    typealias DoneListener = (String) -> ()
    var gCancelListener: CancelListener?
    var gDoneListener: DoneListener?
    var selectedValue: String?
    var parentView: UIView?
    
    @IBOutlet weak var pickerTitleLabel: UIBarButtonItem!
    @IBAction func cancelAction(sender: AnyObject) {
        gCancelListener?()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if selectedValue != nil{
            gDoneListener?(selectedValue!)
        }else{
            gDoneListener?("")
        }
        
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        selectedValue = String(dateFormatter.stringFromDate(datePicker.date))
    }
    
    func loadDatePickerView() -> UIView {
        var views = NSBundle.mainBundle().loadNibNamed("YonaCustomDatePickerView", owner: self, options: nil)
        let view = views[0] as! UIView
        view.frame.origin.y = UIScreen.mainScreen().bounds.height + 200
        view.frame.size.width = UIScreen.mainScreen().bounds.width
        return view
    }
    
    
    func configure(onView v:UIView, withCancelListener cancel: CancelListener, andDoneListener done: DoneListener) {
        gCancelListener = cancel
        gDoneListener = done
        parentView = v
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
    }
    
    func pickerTitleLabel(title: String) {
        self.pickerTitleLabel.title = title
    }
    
    func hideShowDatePickerView(isToShow show: Bool) {
        UIView.animateWithDuration(0.3,
                                   animations: {
                                    if show {
                                        self.frame.origin.y = self.parentView!.frame.size.height - 200
                                    } else {
                                        self.frame.origin.y = self.parentView!.frame.size.height + 200
                                    }
            },completion: nil)
    }
    
}