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
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "WalkThroughViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
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
            setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            if let welcome = R.storyboard.welcome.welcomeViewController {
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
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "nextActionWalkthrough", label: "Go to next walkthrough", value: nil) as AnyObject as! [NSObject : AnyObject])
        delegate?.buttonAction(self.viewControllerIndex)
        
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        if let welcome = R.storyboard.welcome.welcomeViewController {
            self.navigationController?.pushViewController(welcome, animated: false)
        }
    }
}