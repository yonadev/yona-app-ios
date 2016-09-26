//
//  YonaVPNFlowInstructionsVPNViewController.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import StoreKit

class YonaVPNFlowInstructionsVPNViewController : UIViewController , YonaInstructionsProtocol, SKStoreProductViewControllerDelegate{
    @IBOutlet weak var progressPageControl: UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var actionButton : UIButton!

    var page1 :YonaInstructionPage1?
    var page2 :YonaInstructionPage2?
    var page3 :YonaInstructionPage3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yiGrapeColor()

        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "YonaVPNFlowInstructionsVPNViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
//            self.setupUI()
            self.addScrollViews(1)
            
            
        })

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 1))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.page1?.startAnimation()
        }
    }
    
    
    func setupUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        actionButton.setTitle(NSLocalizedString("vpnflowmainscreen.button2.text", comment: ""), forState: UIControlState.Normal)
        actionButton.backgroundColor = UIColor.yiDarkishPinkColor()
        actionButton.alpha = 0.0
    }
    
    func addScrollViews(page : Int) {
        let width = view.frame.size.width
        
        switch page {
        case 1:
            page1 = R.storyboard.vPNFlow.yonaInstructionPage1!
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
            page2 = R.storyboard.vPNFlow.yonaInstructionPage2!
            if var fr = page2?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width
                page2?.view.frame = fr
                page2?.delegate = self
                scrollView.addSubview(page2!.view!)
            }
            scrollView.contentSize = CGSizeMake(width*2, scrollView.frame.size.height)
        case 3:
            if page3 != nil {
                return
            }
            page3 = R.storyboard.vPNFlow.yonaInstructionPage3!
            if var fr = page3?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*2
                page3?.view.frame = fr
                page3?.delegate = self
                scrollView.addSubview(page3!.view!)
                
            }
            scrollView.contentSize = CGSizeMake(width*3, scrollView.frame.size.height)
        default:
            return
        }
        
    }

    
    
    //MARK: Protocol implementation
    
    
    func didFinishAnimations(sender : AnyObject) {
        if sender is YonaInstructionPage1 {
            addScrollViews(2)
            scrollView.scrollRectToVisible((page2?.view!.frame)!, animated: true)
            progressPageControl.currentPage = 1
            page2?.startAnimation()
        }
        if sender is YonaInstructionPage2 {
            addScrollViews(3)
            scrollView.scrollRectToVisible((page3?.view!.frame)!, animated: true)
            progressPageControl.currentPage = 2
            page3?.startAnimation()
        }

        if sender is YonaInstructionPage3{
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
    
    @IBAction func downloadOpenVPNAction(sender : UIButton) {
        
        appStoreCall()
    
    }
    
    func appStoreCall() {
        
#if (arch(i386) || arch(x86_64))   // IN ORDER TO TEST ON SIMULATOR, THIS HAS TO BE DONE
    NSUserDefaults.standardUserDefaults().setBool(true,   forKey: "SIMULATOR_OPENVPN")
    NSUserDefaults.standardUserDefaults().setInteger(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
    
    UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
                                                        NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
    UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
    
    dismissViewControllerAnimated(true, completion: {
        self.navigationController?.popViewControllerAnimated(true)
    })

#endif
    
        
        UINavigationBar.appearance().tintColor = UIColor.yiMidBlueColor()
        UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()

        let storeViewController = SKStoreProductViewController()
        
        storeViewController.delegate = self
        
        let produtc = [SKStoreProductParameterITunesItemIdentifier:590379981]
        storeViewController.loadProductWithParameters(produtc, completionBlock: {
                result, error in
            if (result) {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.presentViewController(storeViewController, animated: true, completion: {})
                })
            }
            })

    
    }
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.yiWhiteColor(),
                                                            NSFontAttributeName: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()

        dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
}