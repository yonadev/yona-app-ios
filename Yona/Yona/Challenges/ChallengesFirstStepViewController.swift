
//
//  ChallengesFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class ChallengesFirstStepViewController: UIViewController,UIScrollViewDelegate {
    
    @IBOutlet var tegoedView: UIView!
    @IBOutlet var tegoedBadgeLabel: UILabel!
    
    @IBOutlet var tijdzoneView: UIView!
    @IBOutlet var tijdzoneBadgeLabel: UILabel!
    
    @IBOutlet var nogoView: UIView!
    @IBOutlet var nogoBadgeLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setSelectedCategory(categoryView: UIView) {
        categoryView.addBottomBorderWithColor(UIColor.yiWhiteColor(), width: 4.0)
        categoryView.alpha = 1.0
        
    }
    
    private func setDeselectOtherCategory() {
        tegoedView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        tijdzoneView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        nogoView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        
        tegoedView.alpha = 0.5
        tijdzoneView.alpha = 0.5
        nogoView.alpha = 0.5
    }
    
    private func setupUI() {
        
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //    Looks for single or multiple taps.
        let tegoedTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChallengesFirstStepViewController.categoryTapEvent(_:)))
        self.tegoedView.addGestureRecognizer(tegoedTap)
        
        let tijdzoneTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChallengesFirstStepViewController.categoryTapEvent(_:)))
        self.tijdzoneView.addGestureRecognizer(tijdzoneTap)
        
        let nogoTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChallengesFirstStepViewController.categoryTapEvent(_:)))
        self.nogoView.addGestureRecognizer(nogoTap)
        
        setDeselectOtherCategory()
        setSelectedCategory(self.tegoedView)
    }
    
    //Calls this function when the tap is recognized.
    func categoryTapEvent(sender: UITapGestureRecognizer? = nil) {
        
        setDeselectOtherCategory()
        setSelectedCategory((sender?.view)!)
      
    }
    
}

private extension Selector {
    
    static let categoryTapEvent = #selector(ChallengesFirstStepViewController.categoryTapEvent(_:))
    
}

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: self.borderColor!)
        }
    }
}

