//
//  ConfigUtil.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

// This class is defined to implement all default values of the Utils class like Managers Extensions UI ...

class ConfigUtil {
    
    // GoogleLocationManager
    static let lastUserLocationKey      : String    = "LAST_USER_LOCATION_KEY"
    static let savedUserLocationKey     : String    = "LAST_SAVED_LOCATION_KEY"

    // DataPickerTextField
    static let defaultPickerDataValue       = ["No values"]
    static let defaultPickerDataIdentifier  = "No Indentifier"
    
    // DatePickerTextField / Date
    static let dateFormat           = "dd/MM/yyyy"
    static let dateFormatTime       = "dd/MM/yyyy HH:mm"
    static let timenoteShareOption  = ["Tout le monde", "Uniquement moi", "Groupe", "Mes amis", "Créer un nouveau groupe"]
    
}
