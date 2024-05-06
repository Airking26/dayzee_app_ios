//
//  Enum.swift
//  Timenote
//
//  Created by Aziz Essid on 6/9/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

enum TimenoteStatus {
    case ongoing
    case done
    case upcoming
    case signaled
    case deleted
}

enum Gender {
    case male
    case female
    case other
}

enum CalendarName {
    case Google
    case Oulook
}

enum AccountType {
    case Youtube
    case Whatsapp
    case FBMessenger
}

enum CustomColor {
    case red
    case pink
    case yellow
    case blue
    case purple
    case custom
}

enum UserCertification {
    case Certified
    case Public
    case Private
    case Banned
}

enum NotificationDashboardType {
    case none
    case follow
    case mention
}

enum NotificationViewType {
    case notification, hiddenUsersList, hiddenEventsList
}

enum ReportType: String, CaseIterable {
    case spam = "spamReport"
    case sexual = "sexualReport"
    case dontLike = "dontLikeReport"
    case hateful = "hatefulReport"
    case scam = "scamReport"
    case falseInfo = "falseInfoReport"
    case bullying = "bullyingReport"
    case violence = "violenceReport"
    case intelectual = "intellectualReport"
    case sucid = "sucidReport"
    case sales = "salesReport"
}

enum CategoryImageName: String {
    case esport = "esport"
    case sport = "sport"
    case youtube = "youtubers"
    case culture = "culture"
    case forKids = "forKids"
    case shopping = "shopping"
    case eventsTrade = "fair_trade"
    case music = "music"
    case religion = "religion"
    case holidays = "holidays"
    case crypto = "crypto"
    case behindScreen = "behindScreen"
    case interestingCalendars = "calendar"
    case socialMeeting = "socialMeeting"
    case infuencers = "infuencers"
    case common = "common"
    
    init?(rawValue: String) {
        switch rawValue {
        case "esport":
            self = .esport
        case "sport":
            self = .sport
        case "youtube channels":
            self = .youtube
        case "culture":
            self = .culture
        case "for kids":
            self = .forKids
        case "shopping":
            self = .shopping
        case "events & trade fair show":
            self = .eventsTrade
        case "music":
            self = .music
        case "religion":
            self = .religion
        case "holidays":
            self = .holidays
        case "crypto":
            self = .crypto
        case "behind the screen":
            self = .behindScreen
        case "interesting calendars":
            self = .interestingCalendars
        case "social & meeting":
            self = .socialMeeting
        case "influencers":
            self = .infuencers
        case "common":
            self = .common
        default:
            self = .common
        }
    }
}
