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
    
    var delegate : YonaVPNFlowMainViewController?
    
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

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "YonaVPNFlowInstructionsMobileConfigViewController")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        DispatchQueue.main.async(execute: {
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        DispatchQueue.main.async(execute: {
            self.addScrollViews(1)
            
            
        })
        
        let delayTime = DispatchTime.now() + Double(Int64(NSEC_PER_SEC * 1)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime){
            self.page1?.startAnimation()
            //            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    
    func setupUI() {
        
        view.backgroundColor = UIColor.yiGrapeColor()
        //navigationItem.title = NSLocalizedString("vpnflowmainscreen.title.text", comment: "")
        actionButton.setTitle(NSLocalizedString("vpnflowintro2.button2.text", comment: ""), for: UIControlState())
        actionButton.backgroundColor = UIColor.yiDarkishPinkColor()
        actionButton.alpha = 0.0
    }
    
    func addScrollViews(_ page : Int) {
        let width = view.frame.size.width
        
        switch page {
        case 1:
            if page1 != nil {
                return
            }
            page1 = R.storyboard.vpnFlow.yonaInstructionMobilePage1(())
            
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
            page2 = R.storyboard.vpnFlow.yonaInstructionMobilePage2(())
            if var fr = page2?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width
                page2?.view.frame = fr
                page2?.delegate = self
                scrollView.addSubview(page2!.view!)
                scrollView.contentSize = CGSize(width: width*2, height: scrollView.frame.size.height)
            }
        case 3:
            if page3 != nil {
                return
            }
            page3 = R.storyboard.vpnFlow.yonaInstructionMobilePage3(())
            if var fr = page3?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*2
                page3?.view.frame = fr
                page3?.delegate = self
                scrollView.addSubview(page3!.view!)
                
            }
            scrollView.contentSize = CGSize(width: width*3, height: scrollView.frame.size.height)
        case 4:
            if page4 != nil {
                return
            }
            page4 = R.storyboard.vpnFlow.yonaInstructionMobilePage4(())

            if var fr = page4?.view.frame {
                fr.size.width = width
                fr.size.height = scrollView.frame.size.height
                fr.origin.x = width*3
                page4?.view.frame = fr
                page4?.delegate = self
                scrollView.addSubview(page4!.view!)
                
            }
            scrollView.contentSize = CGSize(width: width*4, height: scrollView.frame.size.height)

        default:
            return
        
        }
    
    }
    
    //MARK: Protocol implementation
    
    
    func didFinishAnimations(_ sender : AnyObject) {
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
    
    
    
    // Mark: - buttons actions
    
    @IBAction func installMobilConfigFile(_ sender : UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "installMobilConfigFile", label: "Install mobile config button pressed", value: nil).build() as! [AnyHashable: Any])
        
        UserDefaults.standard.set(VPNSetupStatus.configurationInstaling.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.vpnSetupStatus)
        delegate?.installMobileProfile()
        
        
    }
    
    
}
