//
//  ActivLabel.swift
//  Timenote
//
//  Created by Dev on 12/28/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol ActivLabelDelegate {
    func didSelect(_ text: String, with type: ActiveTyp)
}

class ActivLabel: UILabel {
    
    var delegate: ActivLabelDelegate?
    var enabledTypes: [ActiveTyp] = [.mention]
    var typeAttributes: [ActiveTyp : [NSAttributedString.Key : Any]?] = [:]
    var defaultTextAttributes: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 13)!,
        NSAttributedString.Key.foregroundColor : UIColor.label
    ]
    
    // MARK: - Private methods
    
    func highlight() {
        let newAttributtedText = NSMutableAttributedString()
        let words = self.attributedText?.string.components(separatedBy: " ")
        words?.forEach { [weak self] in
            guard let self = self,
                  let type = self.checkWordType(word: $0),
                  let attributes = self.typeAttributes[type]
            else {
                let attributed = NSAttributedString(string: $0 + " ",
                                                    attributes: self?.defaultTextAttributes)
                newAttributtedText.append(attributed)
                return
            }
            
            var suffix = ""
            var word = $0
            let prefix = String(word.prefix(while: { $0.isPunctuation }))
            
            if let range = word.range(of: prefix) {
                word.removeSubrange(range)
            }
            
            if let index = word.firstIndex(where: { $0.isPunctuation }) {
                suffix = String(word.suffix(from: index))
            }
            
            if let range = word.range(of: suffix) {
                word.removeSubrange(range)
            }
            
            let attributedPrefix = NSAttributedString(string: prefix,
                                                      attributes: self.defaultTextAttributes)
            let attributedSufix = NSAttributedString(string: suffix + " ",
                                                      attributes: self.defaultTextAttributes)
            let attributedText = NSAttributedString(string: word,
                                                attributes: attributes)
            
            newAttributtedText.append(attributedPrefix)
            newAttributtedText.append(attributedText)
            newAttributtedText.append(attributedSufix)
        }
        self.attributedText = newAttributtedText
    }
    
    private func checkWordType(word: String) -> ActiveTyp? {
        if word.contains(ActiveTyp.mention.pattern) && self.enabledTypes.contains(.mention) {
            return .mention
        } else if word[0].contains(ActiveTyp.hashtag.pattern) && self.enabledTypes.contains(.hashtag) {
            return .hashtag
        } else if self.enabledTypes.contains(.username(pattern: word)) && self.enabledTypes.contains(.username(pattern: word)) {
            return .username(pattern: word)
        }
        return nil
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let text = self.attributedText?.string
        else { return }
        
        var touchedWord = ""
        let location = touch.location(in: self)
        let words = text.components(separatedBy: " ")
        let touchedIndex = self.processInteraction(at: location, wasTap: true)
        words.forEach {
            let range = text.range(of: $0)
            let index = text.index(text.startIndex, offsetBy: touchedIndex)
            if range?.contains(index) ?? false {
                var set = CharacterSet.punctuationCharacters
                set.remove(charactersIn: "@#")
                touchedWord = $0.components(separatedBy: set).joined()
            }
        }
        if let type = self.checkWordType(word: touchedWord) {
            touchedWord = touchedWord.components(separatedBy: CharacterSet.punctuationCharacters).joined()
            self.delegate?.didSelect(touchedWord, with: type)
        }
    }
    
    private func processInteraction(at location: CGPoint, wasTap: Bool) -> Int {
        
        let label = self
        
        guard let attributedText = label.attributedText else {
            return 0 // nothing to do
        }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: label.bounds.size)
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        
        
        let characterIndex = layoutManager.characterIndex(for: location,
                                                             in: textContainer,
                                                             fractionOfDistanceBetweenInsertionPoints: nil)
        return characterIndex
    }

}
