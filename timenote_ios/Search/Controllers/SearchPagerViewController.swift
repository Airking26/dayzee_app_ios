//
//  SearchPagerViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/25/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol PagerDeleguate {
    func swipeToViewController(_ index : Int)
    func swipeToNext()
}

protocol PagerControllDeleguate {
    func swipeToViewController(_ index : Int)
}


class SearchPagerViewController : UIPageViewController {
    
    private var pagerControllersNames = ["TopWrapperViewController", "ExploreViewController", "PeopleViewController", "HashTagSearchViewController"]
    private var pagerControllersStoryboradName = "Search"
    private var pagerControllerIndex = 0
    private var pagerControllers : [UIViewController] = []
    
    var pagerControllDeleguate  : PagerControllDeleguate?
    var isUISwipeEnabled : Bool = true {
        didSet(newValue) {
            self.dataSource = newValue ? self : nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // No data source to disable swipe actions
        //self.dataSource = self
        self.delegate = self
        
        for i in 0..<self.pagerControllersNames.count {
            self.pagerControllers.append(self.getViewController(self.pagerControllersNames[i], self.pagerControllersStoryboradName, i))
        }
        self.setViewControllers([self.pagerControllers.first!], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    
    private func setViewConntrollerData(_ viewController : UIViewController, _ index: Int = -1) {
        // Add data to view controller
    }
    
    private func getViewController(_ controllerName : String, _ storyBoardName : String, _ index : Int = -1) -> UIViewController {
        let viewController = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: controllerName)
        self.setViewConntrollerData(viewController, index)
        return viewController
    }
    
    func setControllers(_ viewControllersName : [String], _ viewControllerStoriboardName : String) {
        self.pagerControllersNames = viewControllersName
        self.pagerControllersStoryboradName = viewControllerStoriboardName
        for i in 0..<self.pagerControllersNames.count {
            self.pagerControllers.append(self.getViewController(self.pagerControllersNames[i], self.pagerControllersStoryboradName, i))
        }
    }

}

extension SearchPagerViewController : PagerDeleguate {
    
    func swipeToViewController(_ index: Int) {
        let direction = (index > self.pagerControllerIndex) ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse
        self.pagerControllerIndex = index
        self.setViewControllers([self.pagerControllers[index]], direction: direction, animated: true, completion: nil)
    }
    
    
    func swipeToNext() {
        guard self.pagerControllerIndex != self.pagerControllers.count - 1 else {
            self.swipeToViewController(0)
            return
        }
        self.pagerControllerIndex = self.pagerControllerIndex + 1
        self.setViewControllers([self.pagerControllers[self.pagerControllerIndex]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
    }
}

extension SearchPagerViewController : UIPageViewControllerDelegate , UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.pagerControllerIndex = self.pagerControllers.firstIndex(of: viewController)!
        guard self.pagerControllerIndex > 0 else { return nil }
        return self.pagerControllers[self.pagerControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.pagerControllerIndex = self.pagerControllers.firstIndex(of: viewController)!
        guard self.pagerControllerIndex < self.pagerControllers.count - 1 else { return nil }
        return self.pagerControllers[self.pagerControllerIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true {
            let previousPagerIndex = self.pagerControllerIndex
            self.pagerControllerIndex = self.pagerControllers.firstIndex(of: (pageViewController.viewControllers?.first)!)!
            var newIndex = previousPagerIndex
            if previousPagerIndex > self.pagerControllerIndex { newIndex = previousPagerIndex - 1 }
            else { newIndex = previousPagerIndex + 1 }
            self.pagerControllDeleguate?.swipeToViewController(newIndex)
        }
    }
}
