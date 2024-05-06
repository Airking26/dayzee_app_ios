//
//  OSLog.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

enum AppLanguage : String {
    case FRENCH = "fr"
    case ENGLISH = "en"
}

extension Locale {
    
    func toAppLanguage() -> AppLanguage {
        switch Locale.preferredLanguages[0].split(separator: "-")[0] {
        case "en":
            return AppLanguage.ENGLISH
        case "fr":
            return AppLanguage.FRENCH
        default:
            return AppLanguage.ENGLISH
        }
    }
    
    var isFrench : Bool { get { return Locale.preferredLanguages[0].split(separator: "-")[0] == "fr" }}
    
    static let applicationLanguage = Locale.preferredLanguages[0].split(separator: "-")[0]
    
}
