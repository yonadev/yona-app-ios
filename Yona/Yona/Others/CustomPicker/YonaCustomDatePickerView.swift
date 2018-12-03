

import Foundation
import UIKit

class YonaCustomDatePickerView: UIView {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    typealias CancelListener = () -> ()
    typealias DoneListener = (Date) -> ()
    var gCancelListener: CancelListener?
    var gDoneListener: DoneListener?
    var selectedValue: Date?
    var parentView: UIView?
    
    @IBOutlet weak var cancelButtonTitle: UIBarButtonItem!
    @IBOutlet weak var okButtonTitle: UIBarButtonItem!
    @IBOutlet weak var pickerTitleLabel: UIBarButtonItem!
    @IBOutlet weak var title: UIBarButtonItem!

    @IBAction func cancelAction(_ sender: AnyObject) {
        gCancelListener?()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        if selectedValue != nil{
            gDoneListener?(selectedValue!)
        }else{
            gDoneListener?(Date())
        }
        
    }
    
    @IBAction func datePickerAction(_ sender: AnyObject) {
        selectedValue = datePicker.date
    }
    
    func loadDatePickerView() -> UIView {
        var views = Bundle.main.loadNibNamed("YonaCustomDatePickerView", owner: self, options: nil)
        let view = views![0] as! UIView
        view.frame.origin.y = UIScreen.main.bounds.height + 200
        view.frame.size.width = UIScreen.main.bounds.width
        return view
    }
    
    
    func configure(onView v:UIView, withCancelListener cancel: @escaping CancelListener, andDoneListener done: @escaping DoneListener) {
        gCancelListener = cancel
        gDoneListener = done
        parentView = v
        title.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.yiBlackColor()], for: UIControl.State())
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func pickerTitleLabel(_ title: String) {
        self.pickerTitleLabel.title = title
    }
    
    func hideShowDatePickerView(isToShow show: Bool) -> YonaCustomDatePickerView {
        cancelButtonTitle.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.yiMidBlueColor()], for: UIControl.State())
        okButtonTitle.setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor.yiMidBlueColor()], for: UIControl.State())
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
    
    
    func configureWithTime(_ date: Date) {
        selectedValue = date
        self.datePicker.setDate(date, animated: true)
    }
    
    
}
