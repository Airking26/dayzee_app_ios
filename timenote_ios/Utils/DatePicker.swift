//
//  DatePicker.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

// Delegate to controll the update of the selected date of the textField
// The protocol is called only when the textField editing has ended

protocol DatePickerTextFieldDelegate {
    func didUpdateSelectedDate(_ date : Date, _ dateToString : String, textField: UITextField?)
}

// This class allow to have a Date Picker TextField wich has the basic setup

class DatePickerTextField : UITextField {
    
    // Date picker
    var datePickerView = UIDatePicker()
    
    // Date picker delegate to controll the textField update
    var datePickerDelegate : DatePickerTextFieldDelegate?
    var isTimeActivated : Bool { set {
            self.datePickerView.datePickerMode = newValue ? .dateAndTime : .date
        } get {
            return self.datePickerView.datePickerMode == .date
        }
    }
    var isMonthYear : Bool  = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor.clear
        // Setup of the UIDatePicker
        if #available(iOS 13.4, *) {
            // Force wheel for iOS 13 and more
            self.datePickerView.preferredDatePickerStyle = .wheels
        }
        self.inputView = self.datePickerView
        self.addTarget(self, action: #selector(datePickerTextFieldEditingDidEnd), for: .editingDidEnd)
    }
    
    @objc func datePickerTextFieldEditingDidEnd() {
        // Delegate is called for editingDidEnd
        var dateToString = ""
        switch self.datePickerView.datePickerMode {
        case .date:
            dateToString = self.datePickerView.date.toDateDayString()
        case .time:
            dateToString = self.datePickerView.date.getHour()
        case .dateAndTime:
            dateToString = self.datePickerView.date.toDateTimeString()
        default:
            break;
        }
        if self.isMonthYear {
            dateToString = self.datePickerView.date.toMonthYearString()
        }
        self.datePickerDelegate?.didUpdateSelectedDate(self.datePickerView.date, dateToString, textField: self)
        // You can modify the date to string formater in the Config Util class
        self.text = dateToString
    }
    
    
    
}
