//
//  Objects.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 4/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit

struct User {
    let firstName               : String
    let lastName                : String
    let userName                : String
    let email                   : String
    let location                : Location?
    let image                   : UIImage?
    let sitewebURL              : String?
    let description             : String?
    let facebookID              : String?
    let googleID                : String?
    let certification           : UserCertification
    let contentCertification    : UserCertification
    let statistics              : [Statistic]?
    let calendar                : UserCalendar
    let gender                  : Gender
    let isAccountPrivate        : Bool
    let linkedAccounts          : [LinkedAccount]?
    let notificationsDown       : [User]
    let preferences             : [Preference]
}

struct Timenote {
    let user            : User
    let title           : String
    let image           : UIImage
    let themeColor      : CustomColor
    let font            : CustomFont
    let location        : Location
    let creationDate    : Date
    let startDate       : Date
    let endDate         : Date
    let hashtags        : [String]
    let description     : String?
    let isFree          : Bool
    let ticketURL       : String?
    let price           : Double?
    let ticketQuantity  : Int
    let category        : PreferenceCategory
    let comments        : [Comment]
    let usersLiked      : [User]
    // to think
    let status          : TimenoteStatus
}

struct Location {
    let latitude            : Double
    let longitude           : Double
    let address             : String?
    let formattedAddress    : String?
}

struct UserCalendar {
    let name        : CalendarName
    let events      : [Timenote]
    let isLinked    : Bool
}

struct Statistic {
    let user: User
    let userFollowing   : [User]
    let userFollowed    : [User]
}

struct LinkedAccount {
    let type    : AccountType
    let url     : String?
}

enum SubcategoryType {
    case slider
    case bite
}

struct PreferenceSubCategory {
    let name        : String
    let image       : UIImage?
    let rate        : Int
    let type        : SubcategoryType
    let dataSeleted : Any?
}

struct PreferenceCategory {
    let name            : String
    let image           : UIImage
    let subCategories   : [PreferenceSubCategory]
}

struct Preference {
    let category: PreferenceCategory
}

struct CustomFont {
    enum CustomFontName {
        case arial
        case helvetica
        case system
    }

    enum CustomFontWeight {
        case light
        case regular
        case italic
        case medium
        case semibold
        case bold
    }

    let name    : CustomFontName
    let weight  : CustomFontWeight
    let size    : Int
}

struct Comment {
    let user        : User
    let text        : String
    let taggedUsers : [User]
}

struct Alarm {
    let timenote    : Timenote
    let endDate     : Date
    let user        : User
}

struct Filters {
    let category    : PreferenceCategory
    let isFree      : Bool
    let distance    : Int
    let from        : UserCertification
    let advertise   : Bool
}
