//
//  APNs.swift
//  Timenote
//
//  Created by Moshe Assaban on 6/2/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationType: Int {
    case TIMENOTE_SHARE = 0
    case TIMENOTE_ALARM = 1
    case FOLLOW         = 2
    case FOLLOW_ASK     = 3
    case FOLLOW_NEW     = 4
    case JOINED_EVENT   = 5
    case TAGGED_EVENT   = 6
}

struct NotificationTimenoteShare : Codable {
    private(set) var id     : String?
    let type                : String
    var notificationType    : Int?
    let timenoteID          : String?
    let body                : String?
    
    init(dictionary: [AnyHashable: Any], id: String) throws {
        self = try JSONDecoder().decode(NotificationTimenoteShare.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.notificationType = Int(self.type)
        self.id = id
    }
}

struct NotificationTimenote : Codable, Equatable {
    let id          : String
    let createdAt   : String
    let hasBeenRead: Bool?
    let picture     : String?
    let type        : Int
    let belongTo    : String?
    let username    : String?
    let idData      : String?
    let eventName   : String?
    
    var createdDate: Date? { get {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: self.createdAt )
        return date
    }}

    var description: String { get {
        switch self.type {
        case 0:
            let result = Locale.current.isFrench ?
                "\(username ?? "") vous a partagé un évènement: \(eventName ?? "")" : "\(username ?? "-") shared you an event: \(eventName ?? "")"
            return result
        case 2:
            let result = Locale.current.isFrench ?
                "\(username ?? "") vous suit" : "\(username ?? "") follows you"
            return result
        case 3:
            let result = Locale.current.isFrench ?
                "\(username ?? "") a demandé à vous suivre" : "\(username ?? "") has requested to follow you"
            return result
        case 4:
            let result = Locale.current.isFrench ?
                "Vous suivez maintenan \(username ?? "")" : "You are now following \(username ?? "")"
            return result
        case 5:
            let result = Locale.current.isFrench ?
                "\(username ?? "") a rejoint votre évènement: \(eventName ?? "")" : "\(username ?? "") has joined your event: \(eventName ?? "")"
            return result
        case 6:
            let result = Locale.current.isFrench ?
                "\(username ?? "") vous a tagué sur un évènement: \(eventName ?? "")" : "\(username ?? "") has tagged you on an event: \(eventName ?? "")"
            return result
        default:
            return ""
        }
    }}
    
    static func == (lhs: NotificationTimenote, rhs: NotificationTimenote) -> Bool {
        return (lhs.id == rhs.id && lhs.hasBeenRead == rhs.hasBeenRead && lhs.type == rhs.type)
    }
}

struct NotificationFollow : Codable {
    private(set) var id     : String?
    let type                : String
    var notificationType    : Int?
    let userID              : String
    let body                : String?
    let createdAt           : String
    
    init(dictionary: [AnyHashable: Any], id: String) throws {
        self = try JSONDecoder().decode(NotificationFollow.self, from: JSONSerialization.data(withJSONObject: dictionary))
        self.notificationType = Int(self.type)
        self.id = id
    }
}

class APNsManager: NSObject {

    public static let shared                = APNsManager()
    public static let NotificationRegisterdKey      : String    = "APNsManager_NotificationRegisterdKey"
    public static let NotificationTimenoteKey       : String    = "APNsManager_NotificationTimenoteKey"
    public static let NotificationTimenoteAlarmKey  : String    = "APNsManager_NotificationTimenoteAlarmKey"
    public static let NotificationFollowAskedKey    : String    = "APNsManager_NotificationFollowAskedKey"
    public static let NotificationFollowAcceptedKey : String    = "APNsManager_NotificationFollowAcceptedKey"

    @Persisted(key: APNsManager.NotificationRegisterdKey)
    public  var notificationsRegistered     : [NotificationTimenote]!
    @Persisted(key: APNsManager.NotificationTimenoteKey)
    public  var notificationTimenote        : [NotificationTimenote]!
    @Persisted(key: APNsManager.NotificationFollowAskedKey)
    public  var notificationFollowAsked     : [NotificationTimenote]!
    @Persisted(key: APNsManager.NotificationFollowAcceptedKey)
    public  var notificationFollowAccepted  : [NotificationTimenote]!
    @Persisted(key: APNsManager.NotificationTimenoteAlarmKey)
    public  var notificationTimenoteAlarm   : [NotificationTimenoteShare]!

    override init() {
        super.init()
        self.initializeValuesIfNeeded()
    }
    
    private func initializeValuesIfNeeded() {
        if self.notificationsRegistered == nil {
            self.notificationsRegistered = []
        }
        if self.notificationTimenote == nil {
            self.notificationTimenote = []
        }
        if self.notificationFollowAsked == nil {
            self.notificationFollowAsked = []
        }
        if self.notificationFollowAccepted == nil {
            self.notificationFollowAccepted = []
        }
        if self.notificationTimenoteAlarm == nil {
            self.notificationTimenoteAlarm = []
        }
    }
    
    public func requestPushAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay]) {
             (granted, error) in
             guard granted else { return }
             self.getNotificationSettings()
         }
    }

    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    public func removeNotification(with id: String) {
        WebService.shared.removeNotification(with: id)
        notificationsRegistered.removeAll(where: {$0.id == id})
    }
    
    public func acceptFollowRequested(userId id: String, notificationId: String) {
        UserManager.shared.acceptFollow(userId: id)
        self.removeNotification(with: notificationId)
    }
    
    public func declineFollowRequested(userID id: String, notificationId: String) {
        UserManager.shared.declineFollow(userId: id)
        self.removeNotification(with: notificationId)
    }
    
    public func handleReceivedNotifications(notifications: [NotificationTimenote]) {
        notifications.forEach { notification in
            if !notificationsRegistered.contains(where: { $0 == notification }) {
                notificationsRegistered.removeAll(where: { $0.id == notification.id })
                notificationsRegistered.append(notification)
                switch notification.type {
                case 3:
                    self.notificationFollowAsked.append(notification)
                case 2:
                    self.notificationFollowAccepted.append(notification)
                case 0:
                    self.notificationTimenote.append(notification)
                default:
                    break
                }
            }
        }
    }
    
    public func handleNotificationInteraction(notification: NotificationTimenote) {
        switch NotificationType(rawValue: notification.type) {
        case .TIMENOTE_SHARE:
            guard let timenoteNotification = self.notificationTimenote.first(where: {$0.id == notification.id}) else { return }
            TimenoteManager.shared.timenoteDeepLink.send(timenoteNotification.idData)
        case .TIMENOTE_ALARM:
            guard let timenoteNotification = self.notificationTimenoteAlarm.first(where: {$0.id == notification.id}) else { return }
            TimenoteManager.shared.timenoteDeepLink.send(timenoteNotification.timenoteID)
        case .FOLLOW_NEW:
            guard let followNotification = self.notificationFollowAccepted.first(where: {$0.id == notification.id}) else { return }
            UserManager.shared.userDeepLink.send(followNotification.idData)
        case .FOLLOW:
            guard let followNotification = self.notificationFollowAccepted.first(where: {$0.id == notification.id}) else { return }
            UserManager.shared.userDeepLink.send(followNotification.idData)
        case .FOLLOW_ASK:
            guard let followNotification = self.notificationFollowAsked.first(where: {$0.id == notification.id}) else { return }
            UserManager.shared.newFollowAsked.send(followNotification.idData)
        case .TAGGED_EVENT, .JOINED_EVENT:
            guard let timenoteNotification = self.notificationsRegistered.first(where: {$0.id == notification.id}) else { return }
            TimenoteManager.shared.timenoteDeepLink.send(timenoteNotification.idData)
        default:
            break
        }
    }

    public func handleNotificationInteraction(identifier: Int ,userInfo: [AnyHashable : Any], id: String) {
        if self.notificationsRegistered.contains(where: {$0.id == id}) == false {
            self.handleReceivedNotification(identifier: identifier, userInfo: userInfo, id: id)
        }
        guard let notification = self.notificationsRegistered.first(where: {$0.id == id}) else { return }
        self.handleNotificationInteraction(notification: notification)
    }

    public func handleReceivedNotification(identifier: Int ,userInfo: [AnyHashable : Any], id: String) {
        guard let type = NotificationType(rawValue: identifier),
              let idData = userInfo["gcm.notification.userID"] as? String ?? userInfo["gcm.notification.timenoteID"] as? String
        else { return }
        let createdAt = (userInfo["createdAt"] as? Date ?? Date()).toString()
        let notification = NotificationTimenote(id: id,
                                                createdAt: createdAt,
                                                hasBeenRead: userInfo["hasBeenRead"] as? Bool ?? true,
                                                picture: nil,
                                                type: type.rawValue,
                                                belongTo: nil,
                                                username: nil,
                                                idData: idData,
                                                eventName: "")
        self.distributeNotification(notification: notification,
                                    type: type, 
                                    userInfo: userInfo,
                                    id: id)
    }
    
    private func distributeNotification(notification: NotificationTimenote,
                                        type: NotificationType,
                                        userInfo: [AnyHashable : Any],
                                        id: String) {
        switch type {
        case NotificationType.TIMENOTE_SHARE:
            self.notificationsRegistered.append(notification)
            self.notificationTimenote.append(notification)
        case NotificationType.TIMENOTE_ALARM:
            if let timenote = try? NotificationTimenoteShare(dictionary: userInfo, id: id) {
                self.notificationsRegistered.append(notification)
                self.notificationTimenoteAlarm.append(timenote)
            }
        case NotificationType.FOLLOW_ASK:
            self.notificationsRegistered.append(notification)
            self.notificationFollowAsked.append(notification)
        case NotificationType.FOLLOW_NEW:
            self.notificationsRegistered.append(notification)
            self.notificationFollowAccepted.append(notification)
            break;
        case NotificationType.FOLLOW:
            self.notificationsRegistered.append(notification)
            self.notificationFollowAccepted.append(notification)
            break;
        case NotificationType.JOINED_EVENT, NotificationType.TAGGED_EVENT:
            self.notificationsRegistered.append(notification)
            break;
        }
    }
}
