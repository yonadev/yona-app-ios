//
//  WalkThroughViewController.swift
//  Yona
//
//  Created by Chandan on 28/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class WalkThroughViewController: UIViewController {
    @IBOutlet var pageController: AVPageViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let vc: AVPageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WalkThrough1") as! AVPageContentViewController
        let vc1: AVPageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WalkThrough2") as! AVPageContentViewController
        let vc2: AVPageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WalkThrough3") as! AVPageContentViewController
        let vc3: AVPageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WalkThrough4") as! AVPageContentViewController
        
        let margin: CGFloat = 0.0
        self.setPageController()
        self.pageController?.setupControllers([vc, vc1, vc2, vc3], viewControllerFrameRect: CGRectMake(margin, margin, self.view.frame.size.width - 2 * margin, self.view.frame.size.height ), withPresentingViewControllerIndex: 0)
        self.addChildViewController(self.pageController!)
        self.view.addSubview(self.pageController!.view)
        self.pageController!.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPageController() {
        for view in (self.pageController?.view.subviews)! {
            if (view .isKindOfClass(UIPageControl)) {
                let p:UIPageControl = view as! UIPageControl
                //                p.pageIndicatorTintColor = UIColor.redColor()
                
                if (p.currentPage == -1) {
                    p.currentPageIndicatorTintColor = UIColor.yiPeaColor()
                }  else if (p.currentPage == 0) {
                    p.currentPageIndicatorTintColor = UIColor.yiGrapeColor()
                }else if (p.currentPage == 1) {
                    p.currentPageIndicatorTintColor = UIColor.yiMangoColor()
                } else if (p.currentPage == 2) {
                    p.currentPageIndicatorTintColor = UIColor.yiMidBlueColor()
                }
                p.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //If the page is over 50% scrolled change the dot to the new value.
        //If it is less, change it back if the user is holding the page.
    }
    @IBAction func loginTapped(sender: AnyObject) {
        
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
//    class WalkThrough1: AVPageContentViewController{
//        @IBAction func loginTapped(sender: AnyObject) {
//            
//        }
//    }
    
    
//    class AVPageContentViewController:UIViewController{
//        @IBAction func loginTapped(sender: AnyObject) {
//            
//        }
//    }
    
}

