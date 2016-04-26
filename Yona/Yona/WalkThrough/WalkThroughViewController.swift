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
            print("welcome")
            if let welcome = R.storyboard.welcome.welcomeStoryboard {
                self.navigationController?.pushViewController(welcome, animated: false)
            }
            // last index
        }
    }
    
}


protocol ButtonEvents {
    func buttonAction(index: Int)
}


class TourScreenViewController: AVPageContentViewController {
    var delegate: ButtonEvents? = nil
    @IBOutlet var imageV: UIImageView?
    
    @IBAction func nextAction(sender: UIButton) {
        print(self.viewControllerIndex)
        delegate?.buttonAction(self.viewControllerIndex)
        
    }
}






