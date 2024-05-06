//
//  Enum.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 4/21/20.
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


struct Suggestion {
    let category: String
    let users: [User]
}

struct SuggestionDTO {
    let suggestions: [Suggestion]
}
