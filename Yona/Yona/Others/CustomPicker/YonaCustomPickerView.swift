

import UIKit
import Foundation

class YonaCustomPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var cancelButtonTitle: UIBarButtonItem!
    @IBOutlet weak var okButtonTitle: UIBarButtonItem!

    
    typealias CancelListener = () -> ()
    typealias DoneListener = (String) -> ()
    var gCancelListener: CancelListener?
    var gDoneListener: DoneListener?
    var data: AnyObject!
    var selectedValue: String?
    var parentView: UIView?
    
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

    
    func loadPickerView() -> UIView {
        var views = NSBundle.mainBundle().loadNibNamed("YonaCustomPickerView", owner: self, options: nil)
        
        return views![0] as! UIView
    }
    
    
    func setData(onView v:UIView, data d: AnyObject, withCancelListener cancel: CancelListener, andDoneListener done: DoneListener) {
        data = d
        gCancelListener = cancel
        gDoneListener = done
        parentView = v
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
    }
    
    
    func showHidePicker(isToShow show: Bool) -> YonaCustomPickerView {
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
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(data.objectAtIndex(row) as! Int)
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = String(data.objectAtIndex(row) as! Int)
    }
}
