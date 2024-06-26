//
//  SceneDelegate.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 4/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Branch

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        if let userActivity = connectionOptions.userActivities.first {
            
            BranchScene.shared().scene(scene, continue: userActivity)
        }
        self.handleDeepLink(url: connectionOptions.urlContexts.first?.url)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        BranchScene.shared().scene(scene, continue: userActivity)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.handleDeepLink(url: URLContexts.first?.url)
        BranchScene.shared().scene(scene, openURLContexts: URLContexts)
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
    
}

