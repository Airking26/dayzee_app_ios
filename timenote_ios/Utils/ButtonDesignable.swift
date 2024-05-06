//
//  ButtonDesignable.swift
//  Timenote
//
//  Created by Dev on 12/17/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ButtonDesignable: UIButton {
        
    /// Label font size represented at design model.
    @IBInspectable var designableFontSize: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.titleLabel?.textAlignment = .center
        adjustFontSize()
    }
    
    func adjustFontSize() {
        let scaleFactor = UIScreen.main.bounds.height / UIView.designableScreenHeight
        titleLabel?.font = titleLabel?.font.withSize(self.designableFontSize * scaleFactor)
    }
    
}
