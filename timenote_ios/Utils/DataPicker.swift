//
//  DataPicker.swift
//  Timenote
//
//  Created by Aziz Essid on 8/15/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit

// This protocol is defined to controll the didSelectRow of the picker
// This function is called each time the value is modified

protocol DataPickerTextFieldDelegate {
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier : String, value : String)
}

// This class allow to create a data picker textField with only calling
// setPickerData and passing in parameter an [String] wich will be the data shown by the picker
// It is only for single row component, you can also set you
// You can pass a delegate to control the selection of the data picker
// You can add an identifier in case you have multiple DataPickerTextField and want to control the selection

class DataPickerTextField : UITextField {
    
    // Variables that are needed to implement the UIPickerView controll of data
    private var dataValues          : [String]                      = ConfigUtil.timenoteShareOption
    private var pickerView          : UIPickerView                  = UIPickerView()
    private var pickerIdentifier    : String                        = ConfigUtil.timenoteShareOption.first!
    
    // Delegate to allow the view controller to manager the selection of data
    var pickerViewDelegate  : DataPickerTextFieldDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Allow to have the text data as the current selected data of the picker
        self.inputView = self.pickerView
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.tintColor = UIColor.clear
        self.addTarget(self, action: #selector(textFieldEditingDidBegin), for: .editingDidBegin)
    }
    
    @objc func textFieldEditingDidBegin() {
        if !self.text!.isEmpty {
            // Reset the picker data to the selected values
            self.pickerView.reloadComponent(0)
            guard let indexText = self.dataValues.firstIndex(of: self.text!) else {
                self.text = self.dataValues.isEmpty ? "" : self.dataValues[0]
                self.pickerView.selectRow(0, inComponent: 0, animated: true)
                return
            }
            self.pickerView.selectRow(indexText, inComponent: 0, animated: true)
        } else {
            // Set the data to first value when the text is empty and so the first time the editing has began
            self.text = self.dataValues[0]
        }
    }
    
    // Main and only function to set the data shown by the DataPicker
    func setPickerData(_ newDataValues : [String]?, _ identifier : String) {
        self.pickerIdentifier = identifier
        self.dataValues = newDataValues ?? ConfigUtil.timenoteShareOption
    }
}

extension DataPickerTextField : UIPickerViewDelegate , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataValues.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataValues[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = self.dataValues[row]
        self.pickerViewDelegate?.didSelectRow(pickerView: pickerView, row: row, component: component, identifier: self.pickerIdentifier, value: self.dataValues[row])
    }
}
