//
//  WebServiceDtos.swift
//  Timenote
//
//  Created by Aziz Essid on 9/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import RealmSwift
import Unrealm

struct EmailSigninRequestDto    : Encodable {
    let email               : String
    let password            : String
}

struct AccessTokenDto : Decodable {
    let accessToken : String
}

struct UsernameSigninRequestDto : Encodable {
    let userName            : String
    let password            : String
}

struct SignupRequestDto         : Encodable {
    let email               : String
    let userName            : String
    let password            : String
    let language            : String
}

struct SignResponeDto           : Decodable, Realmable {
    var user                : UserResponseDto = UserResponseDto()
    var accessToken         : String = ""
    var refreshToken        : String = ""
}

struct UserResponseDto: Codable, Hashable, Realmable {
    let id                  : String
    let certified           : Bool?
    let email               : String
    let userName            : String
    let picture             : String?
    let givenName           : String?
    let familyName          : String?
    let birthday            : String?
    let location            : UserLocationDto?
    let gender             : String?
    let descript         : String?
    let status              : UserStatusAccountDto
    let dateFormat          : UserDateFormatDto
    let language            : String
    let followers           : Int
    let following           : Int
    let isInFollowing       : Bool?
    var isInFollowers       : Bool?
    let socialMedias        : SocialMediasDto
    let createdAt           : String
    
    var genderEnum              : UserGenderDto {
        get {
            guard let _gender = self.gender,
                  let gender = UserGenderDto(rawValue: _gender)
            else { return .OTHER }
            return gender
        }
    }
    var fullName            : String { get {
        return self.userName
    }}
    
    private enum CodingKeys: String, CodingKey {
        case id, certified, email, userName, picture, givenName, familyName, birthday, location, gender, descript = "description", status, dateFormat, language, followers, following, isInFollowing, isInFollowers, socialMedias, createdAt
    }
    
    init() {
        self.init(id: "", certified: nil, email: "", userName: "", picture: nil, givenName: nil, familyName: nil, birthday: nil, location: nil, gender: nil, description: nil, status: .PUBLIC, dateFormat: .FIRST, language: "en", followers: 0, following: 0, isInFollowing: nil, isInFollowers: nil, socialMedias: SocialMediasDto(), createdAt: "")
    }
    
    init(id: String, certified: Bool?, email: String, userName: String, picture: String?, givenName: String?, familyName: String?, birthday: String?, location: UserLocationDto?, gender: UserGenderDto?, description: String?, status: UserStatusAccountDto, dateFormat: UserDateFormatDto, language: String, followers: Int, following: Int, isInFollowing: Bool?, isInFollowers: Bool?, socialMedias: SocialMediasDto, createdAt: String) {
        self.id = id
        self.certified = certified
        self.email = email
        self.userName = userName
        self.picture = picture
        self.givenName = givenName
        self.familyName = familyName
        self.birthday = birthday
        self.location = location
        self.gender = gender?.rawValue
        self.descript = description
        self.status = status
        self.dateFormat = dateFormat
        self.language = language
        self.followers = followers
        self.following = following
        self.isInFollowing = isInFollowing
        self.isInFollowers = isInFollowers
        self.socialMedias = socialMedias
        self.createdAt = createdAt
    }
    
}

struct SocialMediasDto          : Decodable, Encodable, Hashable, Realmable {
    let youtube             : SocialMediaDto
    let facebook            : SocialMediaDto
    let instagram           : SocialMediaDto
    let whatsApp            : SocialMediaDto
    let linkedIn            : SocialMediaDto
    let twitter             : SocialMediaDto
    let discord             : SocialMediaDto
    let telegram            : SocialMediaDto
    
    init() {
        youtube = SocialMediaDto()
        facebook = SocialMediaDto()
        instagram = SocialMediaDto()
        whatsApp = SocialMediaDto()
        linkedIn = SocialMediaDto()
        twitter = SocialMediaDto()
        discord = SocialMediaDto()
        telegram = SocialMediaDto()
    }
    
    init(youtube: SocialMediaDto, facebook: SocialMediaDto, instagram: SocialMediaDto, whatsApp: SocialMediaDto, linkedIn: SocialMediaDto, twitter: SocialMediaDto, discord: SocialMediaDto, telegram: SocialMediaDto) {
        self.youtube = youtube
        self.facebook = facebook
        self.instagram = instagram
        self.whatsApp = whatsApp
        self.linkedIn = linkedIn
        self.twitter = twitter
        self.discord = discord
        self.telegram = telegram
    }
    
    var firstEnable : SocialMediaDto? { get {
        if self.youtube.enabled {
            return self.youtube
        }
        else if self.facebook.enabled {
            return self.facebook
        }
        else if self.instagram.enabled {
            return self.instagram
        }
        else if self.whatsApp.enabled {
            return self.whatsApp
        }
        else if self.linkedIn.enabled {
            return self.linkedIn
        } else if self.twitter.enabled {
            return self.twitter
        } else if self.discord.enabled {
            return self.discord
        } else if self.telegram.enabled {
            return self.telegram
        } else {
            return nil
        }
    }}
    
    var firstEnableImage : String { get {
        if self.youtube.enabled {
            return "youtube"
        }
        else if self.facebook.enabled {
            return "facebook_logo"
        }
        else if self.instagram.enabled {
            return "instagram_color"
        }
        else if self.whatsApp.enabled {
            return "whatsapp"
        }
        else if self.linkedIn.enabled {
            return "linkedin_logo"
        } else if self.twitter.enabled {
            return "twitter_logo"
        } else  if self.discord.enabled {
            return "discord_logo"
        } else if self.telegram.enabled {
            return "telegram_logo"
        } else {
            return ""
        }

    }}
}

struct SocialMediaDto          : Decodable, Encodable, Hashable, Realmable {
    let url                 : String
    let enabled             : Bool
    
    init() {
        url = ""
        enabled = false
    }
    
    init(url: String, enabled: Bool) {
        self.url = url
        self.enabled = enabled
    }
}

enum UserDateFormatDto         : Int, Decodable, Encodable, RealmableEnumInt {
    case FIRST = 0
    case SECOND = 1
    
    static var all : [String] { get {
        return Locale.current.isFrench ? ["", "Date et heure", "Date"] : ["", "Date", "Date and time"]
    }}
    
    static func fromString(string: String) -> UserDateFormatDto? {
        switch string {
        case Locale.current.isFrench ? "Date et heure" : "Date and time":
            return .FIRST
        case "Date":
            return .SECOND
        default:
            return .FIRST
        }
    }
    
    public func toString() -> String {
        switch self {
        case .FIRST:
            return Locale.current.isFrench ? "Date et heure" : "Date and time"
        case .SECOND:
            return "Date"
        }
    }
}

enum UserStatusAccountDto      : Int, Decodable, Encodable, RealmableEnumInt {
    case PUBLIC     = 0
    case PRIVATE    = 1
    case BANNED     = 2
    case DELETED    = 3
    
    func toString() -> String {
        switch self {
        case .PUBLIC:
            return Locale.current.isFrench ? "Public" : "Public"
        case .PRIVATE:
            return Locale.current.isFrench ? "Privé" : "Private"
        case .BANNED:
            return Locale.current.isFrench ? "Banni" : "Banned"
        case .DELETED:
            return Locale.current.isFrench ? "Supprimé" : "Deleted"
        }
    }
    
    static var all : [String] { get {
        return Locale.current.isFrench ? ["Public", "Privé"] : ["Public", "Private"]
    }}
    
    static func fromString(string: String) -> UserStatusAccountDto {
        switch string {
        case Locale.current.isFrench ? "Public" : "Public":
            return .PUBLIC
        case Locale.current.isFrench ? "Privé" : "Private":
            return .PRIVATE
        default:
            return .PUBLIC
        }
    }
}

enum UserGenderDto: String, Codable, CaseIterable, RealmableEnumString {
        
    case MALE   = "male"
    case FEMALE = "female"
    case OTHER  = "other"
    
    var toString : String? { get {
        switch self {
        case .FEMALE:
            return Locale.current.isFrench ? "Femme" : "Women"
        case .MALE:
            return Locale.current.isFrench ? "Homme" : "Men"
        case .OTHER:
            return Locale.current.isFrench ? "Autre" : "Other"
        }
    }}
    
    static func fromString(string: String) -> UserGenderDto {
        switch string {
        case Locale.current.isFrench ? "Femme" : "Women":
            return .FEMALE
        case Locale.current.isFrench ? "Homme" : "Men":
            return .MALE
        case Locale.current.isFrench ? "Autre" : "Others":
            return .OTHER
        default:
            return .OTHER
        }
    }
}

struct UserLocationDto         : Codable, Hashable, Realmable {
    let longitude           : Double
    let latitude            : Double
    let address             : UserAddressDto
    
    init(longitude: Double, latitude: Double, address: UserAddressDto) {
        self.longitude = longitude
        self.latitude = latitude
        self.address = address
    }
    
    init() {
        longitude = 0.0
        latitude = 0.0
        address = UserAddressDto()
    }
}

struct UserAddressDto          : Codable, Hashable, Realmable {
    let address             : String
    let zipCode             : String
    let city                : String
    let country             : String
    
    init(address: String, zipCode: String, city: String, country: String) {
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.country = country
    }
    
    init() {
        address = ""
        zipCode = ""
        city = ""
        country = ""
    }
}

struct FCMUpdateDto            : Encodable, Realmable {
    var token               : String = ""
    var platform            : FCMTokenPlateformDto = .IOS
}

enum FCMTokenPlateformDto      : String, Encodable, RealmableEnumString {
    case IOS        = "iOS"
    case ANDROID    = "android"
}

struct CategorieDto            : Decodable, Encodable, Hashable, Realmable {
    var category            : String = ""
    var subcategory         : String = ""
    
    static func ==(lhs: CategorieDto, rhs: CategorieDto) -> Bool {
        return lhs.category == rhs.category && lhs.subcategory == rhs.subcategory
    }
}

struct TimenoteDto              : Decodable, Encodable, Realmable {
    var id                  : String = ""
}

struct TimenoteJoinUserDto      : Codable, Hashable, Realmable {
    var friends                 : [UserResponseDto] = []
    var total                   : Int = 0
    
    var totalString : String { get {
        switch self.total {
        case 0..<10:
            let total = self.total - (!self.friends.isEmpty ? 1 : 0)
            guard total != 0 else { return "" }
            guard total != 1 else { return Locale.current.isFrench ? " une autre personne" : " one other" }
            return " \(total) \(Locale.current.isFrench ? "autres personnes" : "others")"
        case 10..<100:
            return Locale.current.isFrench ? " des dizaines d'autres personnes" : " dozens others"
        case 100..<1000:
            return Locale.current.isFrench ? " des centaines d'autres personnes" : " hundreds others"
        case 1000..<1000000:
            return Locale.current.isFrench ? " des milliers d'autres personnes" : " thousands others"
        default:
            return Locale.current.isFrench ? " des millions d'autres personnes" : " millions others"
        }
    }}
}

struct TimenotePriceDto         : Decodable, Encodable, Hashable, Realmable {
    var value                   : Double = 0
    var currency                : String = ""
}

struct TimenotesLocalData: Codable, Realmable {
    let id: String
    var timenotes: [TimenoteDataDto]
    
    init() {
        id = ""
        timenotes = []
    }
    
    init(id: String, timenotes: [TimenoteDataDto]) {
        self.id = id
        self.timenotes = timenotes
    }
    
    static func primaryKey() -> String? {
        return "id"
    }
}

enum TimenoteFeedType: String, CaseIterable, RealmableEnumString {
    case feedFuture = "timenoteFeedFuture"
    case feedPast = "timenoteFeedPast"
    case userFutur = "userFuturTimenote"
    case userPast = "userPastTimenote"
    case recent = "timenoteRecent"
    case google = "timenoteGoogle"
    case zone = "timenoteZone"
}

struct TimenoteDataDto          : Codable, Hashable, Realmable {
    
    let id                      : String
    let createdAt               : String
    let createdBy               : UserResponseDto
    let orginzers               : [UserResponseDto]?
    let title                   : String
    let descript             : String?
    let pictures                : [String]
    let colorHex                : String?
    let location                : UserLocationDto?
    let stringLocation          : String?
    let category                : CategorieDto?
    let startingAt              : String
    let endingAt                : String
    let hashtags                : [String]
    let urlTitle                : String?
    let url                     : String?
    let price                   : TimenotePriceDto?
    let likedBy                 : Int
    let joinedBy                : TimenoteJoinUserDto?
    let comments                : Int
    var participating           : Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, createdAt, createdBy, orginzers, title, descript = "description", pictures, colorHex, location, stringLocation, category, startingAt, endingAt, hashtags, urlTitle, url, price, likedBy, joinedBy, comments, participating
    }
    
    static func primaryKey() -> String? {
        return "id"
    }
    
    init() {
        self.init(id: "", createdAt: "", createdBy: UserResponseDto(), orginzers: nil, title: "", description: nil, pictures: [], colorHex: nil, location: nil, stringLocation: nil, category: nil, startingAt: "", endingAt: "", hashtags: [], urlTitle: nil, url: nil, price: nil, likedBy: 0, joinedBy: nil, comments: 0, participating: false)
    }
    
    init(id: String, createdAt: String, createdBy: UserResponseDto, orginzers: [UserResponseDto]?, title: String, description: String?, pictures: [String], colorHex: String?, location: UserLocationDto?, stringLocation: String?, category: CategorieDto?, startingAt: String, endingAt: String, hashtags: [String], urlTitle: String?, url: String?, price: TimenotePriceDto?, likedBy: Int, joinedBy: TimenoteJoinUserDto?, comments: Int, participating: Bool) {
        self.id = id
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.orginzers = orginzers
        self.title = title
        self.descript = description
        self.pictures = pictures
        self.colorHex = colorHex
        self.location = location
        self.stringLocation = stringLocation
        self.category = category
        self.startingAt = startingAt
        self.endingAt = endingAt
        self.hashtags = hashtags
        self.urlTitle = urlTitle
        self.url = url
        self.price = price
        self.likedBy = likedBy
        self.joinedBy = joinedBy
        self.comments = comments
        self.participating = participating
    }
    
    var startingDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.startingAt )
        return date
    }}
    
    var endingDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.endingAt )
        return date
    }}
    
    var createdDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.createdAt )
        return date
    }}
    
    var visibleLocation: String? {
        get {
            guard let components = stringLocation?.components(separatedBy: ",")
            else { return nil }
            if components.count >= 2 {
                let result = "\(components[0]), \(components[1])"
                return result
            }
            
            return nil
        }
    }
}

struct CreateTimenoteDto : Encodable, Realmable {
    var createdBy   : String = ""
    var organizers  : [String] = []
    var title       : String = ""
    var description : String?
    var pictures    : [String] = []
    var colorHex    : String?
    var location    : UserLocationDto?
    var category    : CategorieDto?
    var startingAt  : String = ""
    var endingAt    : String = ""
    var hashtags    : [String] = []
    var urlTitle    : String?
    var url         : String?
    var price       : TimenotePriceDto = TimenotePriceDto()
    var sharedWith  : [String] = []
}

struct TimenoteCommentDto   : Decodable, Hashable, Realmable {
    static func == (lhs: TimenoteCommentDto, rhs: TimenoteCommentDto) -> Bool {
        lhs.id == rhs.id
    }
    var id          : String = ""
    var createdAt   : String = ""
    var createdBy   : UserResponseDto = UserResponseDto()
    var description : String = ""
    var hastags     : [String]?
    var likedBy     : Int = 0
    var tagged      : [UserResponseDto] = []
    var picture       : String?
    
    var createdAtDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.createdAt)
        return date
    }}

}

struct TimenoteCreateDto    : Encodable {
    let createdBy   : String
    let timenote    : String
    let description : String?
    let hashtags    : [String]
    let tagged      : [String]
    let picture     : String?
}

struct CreateAlarmDto         : Encodable {
    let createdBy   : String
    let timenote    : String
    let date        : String
}

struct AvailableDto     : Decodable {
    let isAvailable : Bool
}

struct AlarmDto         : Decodable {
    let id          : String
    let timenote    : String
    let date        : String
}

struct CreateSignalementDto : Encodable {
    let createdBy   : String
    let timenote    : String
    let description : String
}

struct SignalementDto    : Decodable {
    let createdBy   : UserResponseDto
    let timenote    : TimenoteDataDto
    let description : String
    let createdAt   : String

    var createdAtDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.createdAt)
        return date
    }}
}

struct TopDto   : Decodable, Encodable, Hashable, Realmable {
    var category    : CategorieDto = CategorieDto()
    var users       : [UserResponseDto] = []
    
    static func ==(lhs: TopDto, rhs: TopDto) -> Bool {
        let lhSet = Set(lhs.users)
        let rhSet = Set(rhs.users)
        return lhs.category == rhs.category && lhs.users.count == rhs.users.count && lhSet.isSubset(of: rhSet)
    }
}

enum FilterOptionDto    : Int, Encodable , RealmableEnumInt{
    case fromFollowers      = 0
    case notFromFollowers   = 1
    case all                = 2
    
    var string : String { get {
        switch self {
        case .fromFollowers:
            return Locale.current.isFrench ? "Mes amis" : "Friends"
        case .all:
            return Locale.current.isFrench ? "Tout le monde" : "Everyone"
        case .notFromFollowers:
            return Locale.current.isFrench ? "Découverte" : "Discover"
        }
    }}
    
    static var allValues: [String] { get {
        return Locale.current.isFrench ? ["Tout le monde", "Découverte", "Mes amis"] : [ "Everyone", "Discover", "Friends"]
    }}
    
    static func fromString(string: String?) -> FilterOptionDto? {
        switch string {
        case  Locale.current.isFrench ? "Mes amis" : "Friends":
            return FilterOptionDto.fromFollowers
        case Locale.current.isFrench ? "Tout le monde" : "Everyone":
            return FilterOptionDto.all
        case Locale.current.isFrench ? "Découverte" : "Discover":
            return FilterOptionDto.notFromFollowers
        default:
            return nil
        }
    }
}

struct FilterNearbyDto : Encodable, Realmable {
    var userID      : String?
    var location    : UserLocationDto = UserLocationDto()
    var maxDistance : Int = 0
    var categories  : [CategorieDto] = []
    var date        : String = ""
    var price       : TimenotePriceDto = TimenotePriceDto()
    var type        : FilterOptionDto = .all
}

struct CalendarDateDto  : Encodable, Realmable {
    let from    : String
    let to      : String
    
    init(from: String, to: String) {
        self.from = from
        self.to = to
    }
    
    init() {
        self.init(from: "", to: "")
    }
}

struct UserUpdateDto : Encodable, Realmable {
    let givenName       : String?
    let familyName      : String?
    let picture         : String?
    var location        : UserLocationDto?
    let birthday        : String?
    let description     : String?
    var genderEnum          : UserGenderDto {
        get {
            guard let _gender = self.gender,
                  let gender = UserGenderDto(rawValue: _gender)
            else { return .OTHER }
            return gender
        }
    }
    let gender         : String?
    let status          : UserStatusAccountDto
    var dateFormatEnum      : UserDateFormatDto {
        get {
            guard let dateFormat = dateFormat,
                  let dateFormatEnum = UserDateFormatDto(rawValue: dateFormat)
            else { return .FIRST }
            return dateFormatEnum
        }
    }
    let dateFormat: Int?
    let socialMedias    : SocialMediasDto?
    
    init(givenName: String?, familyName: String?, picture: String?, location: UserLocationDto?, birthday: String?, description: String?, gender: UserGenderDto?, status: UserStatusAccountDto, dateFormat: UserDateFormatDto?, socialMedias: SocialMediasDto?) {
        self.givenName = givenName
        self.familyName = familyName
        self.picture = picture
        self.location = location
        self.birthday = birthday
        self.description = description
        self.gender = gender?.rawValue
        self.status = status
        self.dateFormat = dateFormat?.rawValue
        self.socialMedias = socialMedias
    }
    
    init() {
        self.givenName = nil
        self.familyName = nil
        self.picture = nil
        self.location = nil
        self.birthday = nil
        self.description = nil
        self.gender = nil
        self.status = .PUBLIC
        self.dateFormat = nil
        self.socialMedias = nil
    }
    
}

struct FCMTokenDto   : Encodable {
    let token       : String
    let platform    : String = "iOS"
}

struct UserGroupDto : Decodable, Hashable, Realmable {
    var id          : String = ""
    var name        : String = ""
    var users       : [UserResponseDto] = []
}

struct CreateGroupDto   : Encodable {
    let name    : String
    let users   : [String]
}

struct ShareTimenoteDto : Encodable {
    let timenote    : String
    let users       : [String]
}

struct HideTimenoteDto: Encodable {
    /// User id.
    let createdBy: String
    /**
     Timenote id.
     
     Seted when need to hide users event.
     */
    let timenote: String?
    /**
     User id.
     
     Seted when need to hide all users events.
     */
    let user: String?
}

struct FilterProfileDto : Encodable, Hashable {
    var upcoming    : Bool
    var alarm       : Bool
    var created     : Bool
    var joined      : Bool
    var sharedWith  : Bool
    
    var hasNoFilter : Bool { get {
        return self.alarm || self.created || self.joined || self.sharedWith
    }}
    
}

struct PreferenceDto    : Decodable, Encodable, Hashable, Realmable {
    var category    : CategorieDto = CategorieDto()
    var rating      : Double = 0.0
}

struct PreferenceUpdateDto : Encodable, Realmable {
    var preferences : [PreferenceDto] = []
}

struct PreferencePatchDto    : Decodable, Encodable, Realmable {
    var category    : CategorieDto = CategorieDto()
    var users       : [UserResponseDto] = []
    var rating      : Double = 0.0
}

struct NotificationDto: Codable, Realmable {
    let id: String
    let createdAt: String
    let hasBeenRead: Bool
    ///Picture int the notification
    let picture: String?
    let type: Int
    let belongTo: String
    let username: String
    ///Id of an event or an id of a profile (depending on field 'type')
    let idData: String
    ///Is not always present, it will depend on the field 'type'
    let eventName: String?
    
    var createdDate : Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.createdAt )
        return date
    }}
    
    init(id: String, createdAt: String, hasBeenReaded: Bool, picture: String?, type: Int, belongTo: String, username: String, idData: String, eventName: String?) {
        self.id = id
        self.createdAt = createdAt
        self.hasBeenRead = hasBeenReaded
        self.picture = picture
        self.type = type
        self.belongTo = belongTo
        self.username = username
        self.idData = idData
        self.eventName = eventName
    }
    
    init() {
        self.init(id: "", createdAt: "", hasBeenReaded: true, picture: nil, type: 0, belongTo: "", username: "", idData: "", eventName: nil)
    }
}
