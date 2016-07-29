//
//  YonaVPNFlowInstructionsMobileConfigViewController.swift
//  Yona
//
//  Created by Anders Liebl on 28/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation



class YonaVPNFlowInstructionsMobileConfigViewController : UIViewController , YonaInstructionsProtocol {
    @IBOutlet weak var progressPageControl: UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var actionButton : UIButton!
    
    var page1 :YonaInstructionMobilePage1?
    var page2 :YonaInstructionMobilePage2?
    var page3 :YonaInstructionMobilePage3?
    var page4 :YonaInstructionMobilePage4?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.setHidesBackButton(true, animated: false)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dispatch_async(dispatch_get_main_queue(), {
            
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        dispatch_async(dispatch_get_main_queue(), {
            self.addScrollViews(1)
            
            
        })
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.page1?.startAnimation()
            //            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    
    func setupUI() {
        
        view.backgroundColor = UIColor.yiGrapeColor()
        //navigationItem.title = NSLocalizedString("vpnflowmainscreen.title.text", comment: "")
        actionButton.setTitle(NSLocalizedString("vpnflowintro2.button2.text", comment: ""), forState: UIControlState.Normal)
        actionButton.backgroundColor = UIColor.yiDarkishPinkColor()
        actionButton.alpha = 0.0
    }
    
    func addScrollViews(page : Int) {
        let width = view.frame.size.width
        
        switch page {
        case 1:
            if page1 != nil {
                return
            }
            page1 = R.storyboard.vPNFlow.yonaInstructionMobilePage1!
            
            if var fr = page1?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                page1?.view.frame = fr
                page1?.delegate = self
                scrollView.addSubview(page1!.view!)
            }
            scrollView.contentSize = CGSizeMake(width, scrollView.frame.size.height)
        case 2:
            if page2 != nil {
                return
            }
            page2 = R.storyboard.vPNFlow.yonaInstructionMobilePage2!
            if var fr = page2?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width
                page2?.view.frame = fr
                page2?.delegate = self
                scrollView.addSubview(page2!.view!)
                scrollView.contentSize = CGSizeMake(width*2, scrollView.frame.size.height)
            }
        case 3:
            if page3 != nil {
                return
            }
            page3 = R.storyboard.vPNFlow.yonaInstructionMobilePage3!
            if var fr = page3?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*2
                page3?.view.frame = fr
                page3?.delegate = self
                scrollView.addSubview(page3!.view!)
                
            }
            scrollView.contentSize = CGSizeMake(width*3, scrollView.frame.size.height)
        case 4:
            if page4 != nil {
                return
            }
            page4 = R.storyboard.vPNFlow.yonaInstructionMobilePage4!

            if var fr = page4?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*3
                page4?.view.frame = fr
                page4?.delegate = self
                scrollView.addSubview(page4!.view!)
                
            }
            scrollView.contentSize = CGSizeMake(width*4, scrollView.frame.size.height)

        default:
            return
        
        }
    
    }
    
    //MARK: Protocol implementation
    
    
    func didFinishAnimations(sender : AnyObject) {
        if sender is YonaInstructionMobilePage1 {
            addScrollViews(2)
            scrollView.scrollRectToVisible((page2?.view!.frame)!, animated: true)
            progressPageControl.currentPage = 1
            page2?.startAnimation()
        }
        if sender is YonaInstructionMobilePage2 {
            addScrollViews(3)
            scrollView.scrollRectToVisible((page3?.view!.frame)!, animated: true)
            progressPageControl.currentPage = 2
            page3?.startAnimation()
        }
        
        if sender is YonaInstructionMobilePage3 {
            addScrollViews(4)
            scrollView.scrollRectToVisible((page4?.view!.frame)!, animated: true)
            progressPageControl.currentPage = 3
            page4?.startAnimation()
        }
        if sender is YonaInstructionMobilePage4{
            UIView.animateWithDuration(0.3, animations: {
                self.actionButton.alpha = 1.0
            })
            
        }
        
    }
    
    func didRequestReRun() {
        scrollView.scrollRectToVisible((page1?.view!.frame)!, animated: true)
        progressPageControl.currentPage = 0
        UIView.animateWithDuration(0.2, animations: {
            self.actionButton.alpha = 0.0
        })
        page1?.startAnimation()
        
    }
    
    
    
    // Mark: - buttons actions
    
    @IBAction func installMobilConfigFile(sender : UIButton) {
        NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.configurationInstaling.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        navigationController?.popViewControllerAnimated(true)
        
        
    }
    
}