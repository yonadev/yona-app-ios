//
//  YonaVPNFlowInstructionsVPNViewController.swift
//  Yona
//
//  Created by Anders Liebl on 26/07/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import StoreKit

class YonaVPNFlowInstructionsVPNViewController : UIViewController{
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
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaVPNFlowInstructionsVPNViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async(execute: {
//            self.setupUI()
            self.addScrollViews(1)
            
            
        })

        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC * 1)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime){
            self.page1?.startAnimation()
        }
    }
    
    
    func setupUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        actionButton.setTitle(NSLocalizedString("vpnflowmainscreen.button2.text", comment: ""), for: .normal)
        actionButton.backgroundColor = UIColor.yiDarkishPinkColor()
        actionButton.alpha = 0.0
    }
    
    func addScrollViews(_ page : Int) {
        let width = view.frame.size.width
        
        switch page {
        case 1:
            page1 = R.storyboard.vpnFlow.yonaInstructionPage1(())
            if var fr = page1?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                page1?.view.frame = fr
                page1?.delegate = self
                scrollView.addSubview(page1!.view!)
            }
            scrollView.contentSize = CGSize(width: width, height: scrollView.frame.size.height)
        case 2:
            if page2 != nil {
                return
            }
            page2 = R.storyboard.vpnFlow.yonaInstructionPage2(())
            if var fr = page2?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width
                page2?.view.frame = fr
                page2?.delegate = self
                scrollView.addSubview(page2!.view!)
            }
            scrollView.contentSize = CGSize(width: width*2, height: scrollView.frame.size.height)
        case 3:
            if page3 != nil {
                return
            }
            page3 = R.storyboard.vpnFlow.yonaInstructionPage3(())
            if var fr = page3?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*2
                page3?.view.frame = fr
                page3?.delegate = self
                scrollView.addSubview(page3!.view!)
                
            }
            scrollView.contentSize = CGSize(width: width*3, height: scrollView.frame.size.height)
        default:
            return
        }
        
    }
 
    // Mark: - buttons actions
    
    @IBAction func downloadOpenVPNAction(_ sender : UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "downloadOpenVPNAction", label: "Download VPN action button pressed to go to appstore", value: nil).build() as! [AnyHashable: Any])
        
        appStoreCall()
    
    }
    
    func appStoreCall() {
        
#if (arch(i386) || arch(x86_64))   // IN ORDER TO TEST ON SIMULATOR, THIS HAS TO BE DONE
    UserDefaults.standard.set(true,   forKey: "SIMULATOR_OPENVPN")
    UserDefaults.standard.set(VPNSetupStatus.openVPNAppInstalled.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
    
    UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                        NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
    UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()
    
    dismiss(animated: true, completion: {
        self.navigationController?.popViewController(animated: true)
    })

#endif
    
       /*
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
        */
        
        if UIApplication.shared.canOpenURL(URL(string: "https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8")!) {
            UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8")!)
        }
        

    }
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        UINavigationBar.appearance().tintColor = UIColor.yiWhiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.yiWhiteColor(),
                                                            NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 14)!]
        UIBarButtonItem.appearance().tintColor = UIColor.yiMidBlueColor()

        dismiss(animated: true, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
}

    //MARK: YonaInstructionsProtocol

extension YonaVPNFlowInstructionsVPNViewController: YonaInstructionsProtocol {
    
    func didFinishAnimations(_ sender : AnyObject) {
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
            UIView.animate(withDuration: 0.3, animations: {
                self.actionButton.alpha = 1.0
            })
        }
    }
    
    func didRequestReRun() {
        scrollView.scrollRectToVisible((page1?.view!.frame)!, animated: true)
        progressPageControl.currentPage = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.actionButton.alpha = 0.0
        })
        page1?.startAnimation()
        
    }
}
