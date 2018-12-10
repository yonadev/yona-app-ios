

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
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        gCancelListener?()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        
        if selectedValue != nil{
            gDoneListener?(selectedValue!)
        }else{
            gDoneListener?("")
        }
    }

    
    func loadPickerView() -> UIView {
        var views = Bundle.main.loadNibNamed("YonaCustomPickerView", owner: self, options: nil)
        
        return views![0] as! UIView
    }
    
    
    func setData(onView v:UIView, data d: AnyObject, withCancelListener cancel: @escaping CancelListener, andDoneListener done: @escaping DoneListener) {
        data = d
        gCancelListener = cancel
        gDoneListener = done
        parentView = v
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    
    func showHidePicker(isToShow show: Bool) -> YonaCustomPickerView {
        cancelButtonTitle.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.yiMidBlueColor()], for: UIControlState())
        okButtonTitle.setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.yiMidBlueColor()], for: UIControlState())

        UIView.animate(withDuration: 0.3,
                                   animations: {
                                    if show {
                                        self.frame.origin.y = self.parentView!.frame.size.height - 200
                                    } else {
                                        self.frame.origin.y = self.parentView!.frame.size.height + 200
                                    }
            },completion: nil)
        
        return self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(data.object(at: row) as! Int)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = String(data.object(at: row) as! Int)
    }
}
