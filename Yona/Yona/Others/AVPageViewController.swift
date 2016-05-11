//
//  AVPageViewController.swift
//  AVLighterPageViewController
//
//  Created by Angel Vasa on 13/01/16.
//  Copyright © 2016 Angel Vasa. All rights reserved.
//

import UIKit

class AVPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var contentViews: Array<UIViewController>?
    var presentingIndex: Int = 0
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.delegate = self
        self.dataSource = self
    }
    
    func setupControllers(contentViews: Array<UIViewController>, viewControllerFrameRect: CGRect, withPresentingViewControllerIndex index:Int) {
        self.contentViews = contentViews
        self.presentingIndex = index
        self.setupViewControllerIndex(contentViews)
        self.view.frame = viewControllerFrameRect
        let viewController = NSArray(object: self.viewController(atIndex: self.presentingIndex))
        self.setViewControllers(
            viewController as? [UIViewController],
            direction: UIPageViewControllerNavigationDirection.Forward,
            animated: true,
            completion: { [weak self] (finished: Bool) in
                if finished {
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.setViewControllers(
                            viewController as? [UIViewController],
                            direction: UIPageViewControllerNavigationDirection.Forward,
                            animated: false,
                            completion: nil
                        )
                    })
                }
                
            })
    }
    
    
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewController(atIndex index:Int) -> UIViewController {
        let vc = self.contentViews![index] as! AVPageContentViewController
        vc.viewControllerIndex = index
        return vc
    }
    
    func setupViewControllerIndex(viewControllers: Array<UIViewController>) {
        for i in 0 ..< viewControllers.count - 1 {
            let vc = self.contentViews![i] as! AVPageContentViewController
            vc.viewControllerIndex = i
        }
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! AVPageContentViewController
        var index = viewController.viewControllerIndex as Int
        
        if(index == 0 || index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewController(atIndex: index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! AVPageContentViewController
        var index = viewController.viewControllerIndex as Int
        
        if(index == NSNotFound || index == self.contentViews!.count - 1) {
            return nil
        }
        index += 1
        return self.viewController(atIndex: index)
    }
    
    
    func gotoNextViewController(index: Int) {
        setupControllers(self.contentViews!, viewControllerFrameRect: self.view.frame, withPresentingViewControllerIndex: index)
    }
    

    
}
