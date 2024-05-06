//
//  OutlinedLabel.swift
//  Timenote
//
//  Created by Aziz Essid on 8/24/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class OutlinedLabel: UILabel {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    override func drawText(in rect: CGRect) {
        let shadowOffset = self.layer.shadowOffset
        let textColor = self.textColor

        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(0.5)
        context!.setLineJoin(CGLineJoin.round)

        context!.setTextDrawingMode(CGTextDrawingMode.stroke);
        self.textColor = UIColor.black
        super.drawText(in: rect)

        context!.setTextDrawingMode(CGTextDrawingMode.fill)
        self.textColor = textColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        super.drawText(in: rect)

        self.layer.shadowOffset = shadowOffset
    }
}
