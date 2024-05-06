//
//  DateCollectionViewCell.swift
//  Timenote
//
//  Created by Aziz Essid on 7/7/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

class DateCollectionViewCell : JTACDayCell {
    
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var pinView: UIView!
    
    private var day : Date? = nil
    
    public func configure(date: Date, isSelected: Bool, isToggled : Bool, belongsTo: DateOwner, hasData: Bool) {
        self.day = date
        let todayDate = Date()
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = true
            self.dayNumberLabel.text = date.getDay()
            if date.getDayInt() == todayDate.getDayInt() && date.getYearInt() == todayDate.getYearInt() && date.getMonth() == todayDate.getMonth() {
                self.dayNumberLabel.borderWidth = 1
                self.dayNumberLabel.borderColor = .systemYellow
            } else {
                self.dayNumberLabel.borderWidth = 0
            }
            self.select(isSelected: isSelected)
            if belongsTo != .thisMonth {
                self.dayNumberLabel.textColor = .systemGray3
                self.isUserInteractionEnabled = false
            }
            self.pinView.backgroundColor = hasData ? .systemYellow : .clear
            self.layoutIfNeeded()
        }
    }
    
    func select(isSelected: Bool) {
        guard isSelected else { return self.unselect() }
        UIView.animate(withDuration: 0.5) {
            DispatchQueue.main.async {
                self.dayNumberLabel.backgroundColor = .systemYellow
                self.dayNumberLabel.textColor = .white
            }
        }
    }
    
    public func unselect() {
        UIView.animate(withDuration: 0.5) {
            self.dayNumberLabel.backgroundColor = .clear
            self.dayNumberLabel.textColor = .label
        }
    }
    
    public func getDate() -> Date? {
        return self.day
    }
    
}
