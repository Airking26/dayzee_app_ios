//
//  FeedVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Combine
import SkeletonView

enum Section : Hashable {
    case main
}

enum FeedSection {
    case PAST
    case FUTURE
}


class FeedViewController: UIViewController {
        
    @IBOutlet weak var pastButton: UIButton!
    @IBOutlet weak var futurButton: UIButton!

    /* VARIABLES */
    
    private var feedPagerViewController     : FeedPagerViewController!
    private var currentFeedSection          : FeedSection               = .FUTURE
    
    private var cancellableBag              = Set<AnyCancellable>()
    
    /* OVERRIDE */
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let feedPagerViewController = segue.destination as? FeedPagerViewController {
            self.feedPagerViewController = feedPagerViewController
            self.feedPagerViewController.pagerControllDeleguate = self

        }
    }
    
    @IBAction func pastIsTapped(_ sender: UIButton) {
        self.futurButton.isSelected = false
        self.pastButton.isSelected = true
        guard self.currentFeedSection != .PAST else { return }
        self.currentFeedSection = .PAST
        self.feedPagerViewController.swipeToViewController(0)
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    @IBAction func futurIsTapped(_ sender: Any?) {
        self.futurButton.isSelected = true
        self.pastButton.isSelected = false
        guard self.currentFeedSection != .FUTURE else { return }
        self.currentFeedSection = .FUTURE
        self.feedPagerViewController.swipeToViewController(1)
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    
}


extension FeedViewController : PagerControllDeleguate {
    
    func swipeToViewController(_ index: Int) {
    }
    
}
