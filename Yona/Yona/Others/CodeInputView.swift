import UIKit

class CodeInputView: UIView, UIKeyInput {
    weak var delegate: CodeInputViewDelegate?
    var nextTag = 1
    var secureCode = ""
    var secure:Bool = false
    // MARK: - UIResponder

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // MARK: - UIView

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Add four digitLabels
        var frame = CGRect(x: 5, y: 0, width: 55, height: 55)
        for index in 1...4 {
            let digitLabel = UILabel(frame: frame)
            digitLabel.font = UIFont.systemFontOfSize(42)
            digitLabel.backgroundColor = UIColor.yiWhiteColor()
            digitLabel.tag = index
            digitLabel.text = " "
            digitLabel.textAlignment = .Center
            self.addSubview(digitLabel)
            frame.origin.x += 55 + 10
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIKeyInput

    func hasText() -> Bool {
        return nextTag > 1 ? true : false
    }

   
    
    func insertText(text: String) {
        
        if nextTag < 5 {
            (self.viewWithTag(nextTag) as! UILabel).text = text
            
            if (nextTag == 1){
             secureCode = (self.viewWithTag(nextTag) as! UILabel).text!
            } else {
             secureCode += (self.viewWithTag(nextTag) as! UILabel).text!
            }
            if secure == true {
                (self.viewWithTag(nextTag) as! UILabel).text! = "\u{2022}"
            }
            
            nextTag += 1
            
            if nextTag == 5 {
                delegate?.codeInputView(self, didFinishWithCode: secureCode)
                
            }
        }
    }

    func deleteBackward() {
        if nextTag > 1 {
            nextTag -= 1
            (self.viewWithTag(nextTag) as! UILabel).text = " "
            
            secureCode = String(secureCode.characters.dropLast())
        }
    }

    func clear() {
        while nextTag > 1 {
            deleteBackward()
        }
    }

    // MARK: - UITextInputTraits

    var keyboardType: UIKeyboardType { get { return .NumberPad } set { } }
}

protocol CodeInputViewDelegate: class {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String)

}
