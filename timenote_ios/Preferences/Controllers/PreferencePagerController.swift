//
//  PreferencePagerController.swift
//  Timenote
//
//  Created by Aziz Essid on 22/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PreferencePagerController : UIPageViewController {
    
    private var pagerControllersNames = ["SelectPreferencesViewController", "RatePreferencesViewController"]
    private var pagerControllersStoryboradName = "Preferences"
    private var pagerControllerIndex = 0
    private var pagerControllers : [UIViewController] = []
    
    var pagerControllDeleguate  : PagerControllDeleguate?
    var isUISwipeEnabled : Bool = true {
        didSet(newValue) {
            self.dataSource = newValue ? self : nil
        }
    }
    
    static var passthrougtDataPublisher = CurrentValueSubject<[UserPreferenceDto], Never>([])

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
        if let selectPrefsViewController = viewController as? SelectPreferencesViewController {
            selectPrefsViewController.controlDelegate = self
        }
        if let ratePrefsViewController = viewController as? RatePreferencesViewController {
            ratePrefsViewController.controlDelegate = self
        }
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

extension PreferencePagerController : PagerDeleguate {
    
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

extension PreferencePagerController : UIPageViewControllerDelegate , UIPageViewControllerDataSource {
    
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
