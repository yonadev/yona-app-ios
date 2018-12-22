//
//  WalkThroughViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

open class WalkThroughViewController: UIViewController, ButtonEvents {
    @IBOutlet var pageController: AVPageViewController!
        
    var allControllers = [UIViewController]()
    let margin: CGFloat = 0.0
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "WalkThroughViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as? [AnyHashable: Any])
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if !(AppDelegate.sharedApp.isCrashlyticsInitialized) {
            showAlert()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        for i in 1..<5 {
            let ide = "WalkThrough" + "\(i)"
            let vc: TourScreenViewController = self.storyboard!.instantiateViewController(withIdentifier: ide) as! TourScreenViewController
            vc.delegate = self
            allControllers.append(vc)
        }
        
        self.pageController?.setupControllers(allControllers, viewControllerFrameRect: CGRect(x: margin, y: margin, width: self.view.frame.size.width - 2 * margin, height: self.view.frame.size.height ), withPresentingViewControllerIndex: 0)
        self.addChild(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        self.pageController!.didMove(toParent: self)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: NSLocalizedString("fabric-alert-title", comment:""), message: NSLocalizedString("fabric-failure", comment:""), preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    func buttonAction(_ presentViewControllerIndex: Int) {
        if presentViewControllerIndex < self.allControllers.count - 1 {
            self.pageController!.gotoNextViewController(presentViewControllerIndex + 1)
        } else {
            // last index
            print("welcome")
            setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
            if let welcome = R.storyboard.welcome.welcomeViewController(()) {
                self.navigationController?.pushViewController(welcome, animated: false)
            }
        }
    }
    
}


protocol ButtonEvents: class {
    func buttonAction(_ index: Int)
}


enum TourScreen: Int {
    case firstScreen = 0
    case secondScreen
    case thirdScreen
    case fourthScreen
}

class TourScreenViewController: AVPageContentViewController {
    weak var delegate: ButtonEvents?
    @IBOutlet var imageV: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descLabel: UILabel?
    
    @IBAction func nextAction(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "nextActionWalkthrough", label: "Go to next walkthrough", value: nil).build() as? [AnyHashable: Any])
        delegate?.buttonAction(self.viewControllerIndex)
        
        setViewControllerToDisplay(ViewControllerTypeString.welcome, key: YonaConstants.nsUserDefaultsKeys.screenToDisplay)
        if let welcome = R.storyboard.welcome.welcomeViewController(()) {
            self.navigationController?.pushViewController(welcome, animated: false)
        }
    }
}
