//
//  WalkThroughViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

public class WalkThroughViewController: UIViewController, ButtonEvents {
    @IBOutlet var pageController: AVPageViewController!
    
    
    var allControllers = [UIViewController]()
    let margin: CGFloat = 0.0
    
    public override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let viewController = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) as? String where viewController != YonaConstants.screenNames.walkThrough {
            self.navigationController?.pushViewController(getScreen(viewController), animated: false)
        }
        
    }
    
    func getScreen(viewControllerName: String) -> UIViewController{
        var rootController: UIViewController!
        if let viewName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.screenToDisplay) as? String {
            switch viewName {
            case YonaConstants.screenNames.smsValidation:
                rootController = R.storyboard.sMSValidation.sMSValidationViewController
            case YonaConstants.screenNames.passcode:
                rootController = R.storyboard.passcode.passcodeStoryboard
            case YonaConstants.screenNames.login:
                rootController = R.storyboard.login.loginStoryboard
            case YonaConstants.screenNames.welcome:
                rootController = R.storyboard.welcome.welcomeStoryboard
            
            default:
                rootController = R.storyboard.welcome.welcomeStoryboard
                
            }
            return rootController
        }
        return rootController
    }
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        for i in 1..<5 {
            let ide = "WalkThrough" + "\(i)"
            let vc: TourScreenViewController = self.storyboard!.instantiateViewControllerWithIdentifier(ide) as! TourScreenViewController
            vc.delegate = self
            allControllers.append(vc)
        }
        
        self.pageController?.setupControllers(allControllers, viewControllerFrameRect: CGRectMake(margin, margin, self.view.frame.size.width - 2 * margin, self.view.frame.size.height ), withPresentingViewControllerIndex: 0)
        self.addChildViewController(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        self.pageController!.didMoveToParentViewController(self)
    }
    
    func buttonAction(presentViewControllerIndex: Int) {
        if presentViewControllerIndex < self.allControllers.count - 1 {
            self.pageController!.gotoNextViewController(presentViewControllerIndex + 1)
        } else {
            // last index
            print("welcome")
            if let welcome = R.storyboard.welcome.welcomeStoryboard {
                self.navigationController?.pushViewController(welcome, animated: false)
            }
        }
    }
    
}


protocol ButtonEvents: class {
    func buttonAction(index: Int)
}


enum TourScreen: Int {
    case FirstScreen = 0
    case SecondScreen
    case ThirdScreen
    case FourthScreen
}

class TourScreenViewController: AVPageContentViewController {
    weak var delegate: ButtonEvents?
    @IBOutlet var imageV: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descLabel: UILabel?
    
    @IBAction func nextAction(sender: UIButton) {
        delegate?.buttonAction(self.viewControllerIndex)
        if let welcome = R.storyboard.welcome.welcomeStoryboard {
            self.navigationController?.pushViewController(welcome, animated: false)
        }
    }
}



