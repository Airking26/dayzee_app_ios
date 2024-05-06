//
//  GradientView.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet { self.updateViewGradient() }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet { self.updateViewGradient() }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet { self.updateViewGradient() } 
    }

    override class var layerClass: AnyClass {
        get { return CAGradientLayer.self }
    }

    func updateViewGradient() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
        
        if (self.isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
}
