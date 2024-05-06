//
//  UITimenoteImageCarousel.swift
//  Timenote
//
//  Created by Aziz Essid on 7/25/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import iCarousel

// Pan gesture for Timenote carousel

class UIPanGestureImage : UIPanGestureRecognizer {
    
    private var imageView   : UIView!
    
    init(view: UIView, target: Any?, action: Selector?) {
        self.imageView = view
        super.init(target: target, action: action)
    }
   
    override func shouldRequireFailure(of otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.velocity(in: view).x == 0
    }
    
}

// Timenote class to handle images scroll carousel

class UITimenoteImageCarousel : iCarousel {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.type = .linear
        self.centerItemWhenSelected = true
        self.bounces = true
        self.stopAtItemBoundary = true
        self.clipsToBounds = true
        self.backgroundColor = .clear
    }
    
}
