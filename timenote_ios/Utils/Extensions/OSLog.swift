//
//  OSLog.swift
//  Timenote
//
//  Created by Aziz Essid on 8/3/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // Cycle for the Google Location Manager
    static let googleLocationManagerCycle   = OSLog(subsystem: subsystem, category: "GoogleLocationManager")
    // Cycle for the Persisted Property Wrapper
    static let persistedCycle               = OSLog(subsystem: subsystem, category: "PW_PersistedCycle")
    // Cycle for Categorie Manager
    static let categorieManager             = OSLog(subsystem: subsystem, category: "CategorieManager")
    // Cycle for Timenote Manager
    static let timenoteManager             = OSLog(subsystem: subsystem, category: "TimenoteManager")
    // Cycle for User Manager
    static let userManager                  = OSLog(subsystem: subsystem, category: "UserManager")
}
