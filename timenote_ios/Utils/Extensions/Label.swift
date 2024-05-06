//
//  Label.swift
//  Timenote
//
//  Created by Aziz Essid on 12/10/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    var isTruncated: Bool {
        guard let labelText = self.text, let font = self.font else {
            return false
        }
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: self.frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
    
    var truncatedText: String? {
        guard let font = self.font, let text = self.text, self.isTruncated else { return nil }
        let characterWidthSize = text.size(OfFont: font).width / CGFloat(text.count)
        let numberOfCharacters = Int((self.bounds.width - 55) / characterWidthSize) * self.numberOfLines
        let truncatedText = text.substring(toIndex: numberOfCharacters)
        return truncatedText
    }
    
    func addNextIfTruncated() {
        guard let truncatedText = self.truncatedText, let font = self.font, truncatedText != self.text else { return }
        let newTruncatedMutableAttributedString = NSMutableAttributedString(string: String(truncatedText.dropLast(12)), attributes: [NSAttributedString.Key.font : font])
        let nextMutableAttributedString = NSAttributedString(string: "... ", attributes: [NSAttributedString.Key.font : font])
        let greyNextMutableAttributedString = NSAttributedString(string: "suite", attributes: [NSAttributedString.Key.font : font,NSAttributedString.Key.foregroundColor: UIColor.gray])
        newTruncatedMutableAttributedString.append(nextMutableAttributedString)
        newTruncatedMutableAttributedString.append(greyNextMutableAttributedString)
        self.attributedText = newTruncatedMutableAttributedString
    }
}
