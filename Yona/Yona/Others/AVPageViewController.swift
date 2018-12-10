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
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        self.delegate = self
        self.dataSource = self
    }
    
    func setupControllers(_ contentViews: Array<UIViewController>, viewControllerFrameRect: CGRect, withPresentingViewControllerIndex index:Int) {
        self.contentViews = contentViews
        self.presentingIndex = index
        self.setupViewControllerIndex(contentViews)
        self.view.frame = viewControllerFrameRect
        let viewController = NSArray(object: self.viewController(atIndex: self.presentingIndex))
        self.setViewControllers(
            viewController as? [UIViewController],
            direction: UIPageViewControllerNavigationDirection.forward,
            animated: true,
            completion: { [weak self] (finished: Bool) in
                if finished {
                    DispatchQueue.main.async(execute: {
                        self!.setViewControllers(
                            viewController as? [UIViewController],
                            direction: UIPageViewControllerNavigationDirection.forward,
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
    
    func setupViewControllerIndex(_ viewControllers: Array<UIViewController>) {
        for i in 0 ..< viewControllers.count - 1 {
            let vc = self.contentViews![i] as! AVPageContentViewController
            vc.viewControllerIndex = i
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! AVPageContentViewController
        var index = viewController.viewControllerIndex as Int
        
        if(index == 0 || index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.viewController(atIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let viewController = viewController as! AVPageContentViewController
        var index = viewController.viewControllerIndex as Int
        
        if(index == NSNotFound || index == self.contentViews!.count - 1) {
            return nil
        }
        index += 1
        return self.viewController(atIndex: index)
    }
    
    func gotoNextViewController(_ index: Int) {
        setupControllers(self.contentViews!, viewControllerFrameRect: self.view.frame, withPresentingViewControllerIndex: index)
    }
}
