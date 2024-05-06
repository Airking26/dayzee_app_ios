//
//  AppDelegate.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 4/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import Siren
import GooglePlaces
import GoogleMaps
import GoogleSignIn
import GoogleAPIClientForREST
import AWSS3
import Firebase
import Branch
import RealmSwift
import Unrealm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    static let TimenoteDeepLinkKey  = "AppDelegate_TimenoteDeepLinkKey"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        registerRealmObjects()
        UserManager.shared.start()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [TimenoteDetailViewController.self]
        Siren.shared.rulesManager = RulesManager(globalRules: .critical)
        Siren.shared.wail()
        GMSServices.provideAPIKey("AIzaSyC5T3wZFKmn-9IpJy5hUHXb2s5z1ef-bBM")
        GMSPlacesClient.provideAPIKey("AIzaSyC5T3wZFKmn-9IpJy5hUHXb2s5z1ef-bBM")
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIA5JWTNYVYN77HAPGS", secretKey: "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")
        let configuration = AWSServiceConfiguration(region: .EUWest3, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        configureFirebase(for: application)
        
        self.handleDeepLink(url: launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL)

        setupBranchSDK(launchOptions: launchOptions)
        restoreGooglesignIn()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if url.absoluteString.contains("link_click_id") == true{
            return Branch.getInstance().application(app, open: url, options: options)
        }
        self.handleDeepLink(url: url)
        if !GIDSignIn.sharedInstance.handle(url) {
            return false
        }
        return true
    }
    
    ///Register notifications
    private func configureFirebase(for application: UIApplication) {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
//        print("Device tocken - \(Messaging.messaging().fcmToken)")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    private func registerRealmObjects() {
        Realm.registerRealmables(UserResponseDto.self, SocialMediasDto.self, SocialMediaDto.self, TimenotesLocalData.self, TimenoteDataDto.self, SignResponeDto.self, UserLocationDto.self, UserAddressDto.self, FCMUpdateDto.self, CategorieDto.self, TimenoteDto.self, TimenoteJoinUserDto.self, TimenotePriceDto.self, CreateTimenoteDto.self, TimenoteCommentDto.self, TopDto.self, FilterNearbyDto.self, UserUpdateDto.self, UserGroupDto.self, PreferenceDto.self, PreferenceUpdateDto.self, PreferencePatchDto.self, CalendarDateDto.self, enums: [TimenoteFeedType.self, UserGenderDto.self, UserStatusAccountDto.self, FCMTokenPlateformDto.self, UserDateFormatDto.self, FilterOptionDto.self])
    }
    
    private func restoreGooglesignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private func handleDeepLink(url: URL?) {
        if let url = url, let scheme = url.scheme, scheme.localizedCaseInsensitiveContains("com.Dayzee") == true, let view = url.host {
            var parameter: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach({parameter[$0.name] = $0.value})
            switch view {
            case "dayzee":
                TimenoteManager.shared.timenoteDeepLink.send(parameter["dayzeeId"])
            case "user":
                UserManager.shared.userDeepLink.send(parameter["userId"])
            default:
                break;
            }
        }
    }
    
    private func setupBranchSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if #available(iOS 15, *) {
            Branch.getInstance().checkPasteboardOnInstall()
        } else {}
        // listener for Branch Deep Link data
        BranchScene.shared().initSession(launchOptions: launchOptions) { (params, error, scene) in
            // do stuff with deep link data
            guard let data = params as? [String:AnyObject],
                  let scene = (scene as? UIWindowScene) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
            else { return }
            
            if let timenoteId = data["timenote_id"] as? String {
                TimenoteManager.shared.handleDeepLink(timenoteID: timenoteId, at: scene)
            } else if let accessToken = data["accessToken"] as? String {
                print("Data - \(data)")
                UserManager.shared.handleRestoreUserPassword(at: scene, accessToken: accessToken)
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        UserDefaults.standard.set(fcmToken, forKey: UserManager.UserFCMTokenKey)
//        print("DEVICE TOKEN " + (fcmToken ?? ""))
        WebService.shared.updateUserFCMToken()
    }
}

// MARK: APNs

extension AppDelegate : UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO Register Device Token
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // TODO Handle Error while registering to remote notifications
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        var userInfo = response.notification.request.content.userInfo
        let createdAt = response.notification.date
        userInfo["createdAt"] = createdAt
        guard let identifier = userInfo["type"] as? String,
              let type = Int(identifier)
        else { return }
        APNsManager.shared.handleNotificationInteraction(identifier: type, userInfo: userInfo, id: response.notification.request.identifier)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let createdAt = notification.date
        var userInfo = notification.request.content.userInfo
        userInfo["createdAt"] = createdAt
        guard let identifier = userInfo["type"] as? String,
              let type = Int(identifier)
        else { return }
        APNsManager.shared.handleReceivedNotification(identifier: type, userInfo: userInfo, id: notification.request.identifier)
        completionHandler([.alert, .badge, .sound])
    }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
