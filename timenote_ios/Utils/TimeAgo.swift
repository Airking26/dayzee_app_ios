//
//  TimeAgo.swift
//  Timenote
//
//  Created by Aziz Essid on 7/13/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

public func timeAgoSince(_ date: Date) -> String {
    
    let calendar = Calendar.current
    let now = Date()
    let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
    let components = (calendar as NSCalendar).components(unitFlags, from: date, to: now, options: [])
    
    if let year = components.year, year >= 2 {
        return "il y a \(year) ans"
    }
    
    if let year = components.year, year >= 1 {
        return "l'année dernière"
    }
    
    if let month = components.month, month >= 2 {
        return "il y a \(month) mois"
    }
    
    if let month = components.month, month >= 1 {
        return "le mois dernier"
    }
    
    if let week = components.weekOfYear, week >= 2 {
        return "il y a \(week) semaine"
    }
    
    if let week = components.weekOfYear, week >= 1 {
        return "la semaine derniere"
    }
    
    if let day = components.day, day >= 2 {
        return "il y a \(day) jour"
    }
    
    if let day = components.day, day >= 1 {
        return "hier"
    }
    
    if let hour = components.hour, hour >= 2 {
        return "il y a \(hour) heure"
    }
    
    if let hour = components.hour, hour >= 1 {
        return "il y a une heure"
    }
    
    if let minute = components.minute, minute >= 2 {
        return "il y a \(minute) minutes"
    }
    
    if let minute = components.minute, minute >= 1 {
        return "il y a une minute"
    }
    
    if let second = components.second, second >= 3 {
        return "il y a \(second) seconds"
    }
    
    return "maintenant"
    
}
