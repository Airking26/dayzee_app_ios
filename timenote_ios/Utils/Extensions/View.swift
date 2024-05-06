//
//  View.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIView {
    func makeDisappear(_ duration : TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }
    
    func makeAppear(_ duration : TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor.init(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowOpacity = 0.4
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    func addGradientGrey() {
        layer.sublayers?.removeAll()
        // Set gradients
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.darkGray.cgColor.copy(alpha: 0.15)!, UIColor.white.cgColor.copy(alpha: 0)!]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        // Clip gradients to background bounds
        clipsToBounds = true

        // insert gradients to button
        layer.insertSublayer(gradientLayer, at: .zero)
        
        let gradientLayerBottom = CAGradientLayer()
        gradientLayerBottom.frame = bounds
        gradientLayerBottom.colors = [UIColor.white.cgColor.copy(alpha: 0)!, UIColor.darkGray.cgColor.copy(alpha: 0.15)!]
        gradientLayerBottom.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayerBottom.endPoint = CGPoint(x: 1.0, y: 1)

        // Clip gradients to background bounds
        clipsToBounds = true

        // insert gradients to button
        layer.insertSublayer(gradientLayerBottom, at: .zero)
    }
}

extension UIView {
    
    static let designableScreenHeight: CGFloat = 844 // iPhone 13 pro, etc.
    
    func addCustomBorder(color: UIColor,
                         width: CGFloat,
                         corderRadius: CGFloat = 0.0,
                         maskedCorners: CACornerMask? = nil,
                         isShowBottomBorder: Bool = false,
                         isShowTopBorder: Bool = false,
                         isShowLeftAndRightBorders: Bool = true) {
        
        self.clipsToBounds = true
        self.layer.sublayers?.forEach {
            if $0.name == "customBorderLayer" { $0.removeFromSuperlayer() }
        }
        
        let rightBorder = CALayer()
        rightBorder.borderColor = color.cgColor
        rightBorder.borderWidth = width
        let height = isShowBottomBorder ? self.frame.height : self.frame.height + 2
        let width = isShowLeftAndRightBorders ? self.frame.width : self.frame.width + 2
        let yPos: CGFloat = isShowTopBorder ? 0 : -1
        let xPos: CGFloat = isShowLeftAndRightBorders ? 0 : -1
        rightBorder.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        rightBorder.backgroundColor = UIColor.clear.cgColor
        rightBorder.cornerRadius = cornerRadius
        if let maskedCorners = maskedCorners {
            rightBorder.maskedCorners = maskedCorners
        }
        rightBorder.name = "customBorderLayer"
        self.layer.addSublayer(rightBorder)
    }
    
}

