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


protocol ButtonEvents {
    func buttonAction(index: Int)
}


enum TourScreen: Int {
    case FirstScreen = 0
    case SecondScreen
    case ThirdScreen
    case FourthScreen
}

class TourScreenViewController: AVPageContentViewController {
    var delegate: ButtonEvents? = nil
    @IBOutlet var imageV: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        switch self.viewControllerIndex {
//            
//        case TourScreen.FirstScreen.rawValue:
//            self.titleLabel?.text = "a"
//            self.descLabel?.text = "a"
//            
//        case TourScreen.SecondScreen.rawValue:
//            self.titleLabel?.text = "b"
//            self.descLabel?.text = "b"
//            
//        case TourScreen.ThirdScreen.rawValue:
//            self.titleLabel?.text = "c"
//            self.descLabel?.text = "c"
//            
//        case TourScreen.FourthScreen.rawValue:
//            self.titleLabel?.text = "d"
//            self.descLabel?.text = "d"
//            
//        default:
//            self.titleLabel?.text = ""
//            self.descLabel?.text = ""
//        }
    }
    
    
    
    @IBAction func nextAction(sender: UIButton) {
        delegate?.buttonAction(self.viewControllerIndex)
        if let welcome = R.storyboard.welcome.welcomeStoryboard {
            self.navigationController?.pushViewController(welcome, animated: false)
        }
    }
}



