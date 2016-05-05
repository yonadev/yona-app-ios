

import UIKit
import Foundation

class YonaCustomPickerView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    typealias CancelListener = () -> ()
    typealias DoneListener = (String) -> ()
    var gCancelListener: CancelListener?
    var gDoneListener: DoneListener?
    var data: AnyObject!
    var selectedValue: String?
    
    @IBAction func cancelAction(sender: AnyObject) {
        gCancelListener?()
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
        if selectedValue != nil{
            gDoneListener?(selectedValue!)
        }else{
            gDoneListener?("")
        }

//        gDoneListener?(selectedValue!)
    }
    
    
    
    
    func loadPickerView() -> UIView {
        var views = NSBundle.mainBundle().loadNibNamed("YonaCustomPickerView", owner: self, options: nil)
        return views[0] as! UIView
    }
    
    func setData(data d: AnyObject, withCancelListener cancel: CancelListener, andDoneListener done: DoneListener) {
        data = d
        gCancelListener = cancel
        gDoneListener = done
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
