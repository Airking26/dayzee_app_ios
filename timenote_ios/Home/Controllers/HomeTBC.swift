//
//  HomeTBC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Combine

class HomeTBC: UITabBarController {

    private var cancellablebag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        guard !UserManager.shared.isUserWithNoAccount else {
            DispatchQueue.main.async {
                self.selectedIndex = 2
            }
            super.viewDidLoad()
            return
        }
        super.viewDidLoad()
        if UserManager.shared.isUserSignup {
            UserManager.shared.isUserSignup = false
            self.showUserPref()
        }
        // Do any additional setup after loading the view.
        let _ = TimenoteManager.shared.timenoteNearbyOptionPublisher.sink { (_) in
            guard !TimenoteManager.shared.firstUpdateFilter else { return }
            DispatchQueue.main.async {
                self.selectedIndex = 2
            }
        }.store(in: &self.cancellablebag)
        let _ = TimenoteManager.shared.timenoteLastDuplicate.sink { (value) in
            guard let _ = value else { return }
            DispatchQueue.main.async {
                (self.viewControllers?.first as? UINavigationController)?.dismiss(animated: true, completion: nil)
                self.selectedIndex = 3
            }
        }.store(in: &self.cancellablebag)
        let _ = TimenoteManager.shared.newTimenotePublisher.sink { (value) in
            guard let _ = value else { return }
            DispatchQueue.main.async {
                self.selectedIndex = 4
            }
        }.store(in: &self.cancellablebag)
        let _ = TimenoteManager.shared.timenoteDeepLink.sink { (deepLinkValue) in
            guard let timenoteId = deepLinkValue else { return }
            self.showTimenoteDetail(timenoteId: timenoteId)
        }.store(in: &self.cancellablebag)
        let _ = UserManager.shared.userDeepLink.sink { (deepLinkValue) in
            guard let userId = deepLinkValue else { return }
            self.showUserProfil(userId: userId)
        }.store(in: &self.cancellablebag)
        let _ = UserManager.shared.newFollowAsked.sink { (newFollowUserId) in
            guard let userId = newFollowUserId else { return }
            UserManager.shared.newFollowAsked.send(nil)
            self.showAskedFollowList(userId: userId)
        }.store(in: &self.cancellablebag)
        
        DispatchQueue.global().async { [weak self] in
            self?.loadUserProfielImage()
        }
    }
    
    deinit {
        self.cancellablebag.forEach({$0.cancel()})
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard !UserManager.shared.isUserWithNoAccount else {
            guard tabBar.items?.lastIndex(of: item) != 2 else { return }
            self.showNoAccountAlert()
            return
        }
        if item == tabBar.items?.first && self.selectedIndex == 0 {
            TimenoteManager.shared.updateTimenoteHomePublicher.send(true)
        }
    }
    
    private func loadUserProfielImage() {
        let _ = UserManager.shared.userInformationPublisher.sink { (value) in
            DispatchQueue.global().async {
                if let picture = value?.picture, let url = URL(string: picture), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if self.tabBar.items?.count == 5 {
                            self.tabBar.items?[4].image = image.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFill)?.sd_roundedCornerImage(withRadius: 15, corners: .allCorners, borderWidth: 0, borderColor: .clear)?.withRenderingMode(.alwaysOriginal)
                            self.tabBar.items?[4].selectedImage = image.sd_resizedImage(with: CGSize(width: 30, height: 30), scaleMode: .aspectFill)?.sd_roundedCornerImage(withRadius: 15, corners: .allCorners, borderWidth: 0, borderColor: .clear)?.withRenderingMode(.alwaysOriginal)
                        }
                    }
                }
            }
        }.store(in: &self.cancellablebag)
    }
    
    private func showNoAccountAlert() {
        let alertController = UIAlertController(title: Locale.current.isFrench ? "Vous n'avez pas de compte..." : "You are not logged", message: Locale.current.isFrench ? "Veuillez vous authentifier pour effectuer cette action." : "Please signin to make this action", preferredStyle: .alert)
        let connectAction = UIAlertAction(title: Locale.current.isFrench ? "Je me connecte" : "Sign-in", style: .default) { (action) in
            UserManager.shared.isUserWithNoAccount = false
            self.navigationController?.popToRootViewController(animated: true)
        }
        let retourAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Back", style: .cancel) { (action) in
            self.selectedIndex = 2
        }
        retourAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(connectAction)
        alertController.addAction(retourAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showUserPref() {
        let storyboard = UIStoryboard(name: "Preferences", bundle: nil)
        guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        guard let prefPagerViewController = navigationController.viewControllers.first as? PreferencePagerController else { return }
        prefPagerViewController.modalPresentationStyle = .overFullScreen
        DispatchQueue.main.async {
            CategorieManager.shared.getCategories()
            UIApplication.getTopViewController()?.present(navigationController, animated: true, completion: nil)
        }
    }
    
    private func showTimenoteDetail(timenoteId: String) {
        TimenoteManager.shared.getTimenote(timenoteId: timenoteId) { (timenote) in
            guard let timenote = timenote else { return }
            let storyboard = UIStoryboard(name: "TimenoteDetail", bundle: nil)
            guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let timenoteDetailViewController = navigationController.viewControllers.first as? TimenoteDetailViewController else { return }
            timenoteDetailViewController.timenote = timenote
            timenoteDetailViewController.forceEditing = false
            timenoteDetailViewController.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.async {
                UIApplication.getTopViewController()?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    private func showUserProfil(userId: String) {
        UserManager.shared.getUser(userId: userId) { (user) in
            guard let user = user else { return }
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let profilViewController = navigationController.viewControllers.first as? ProfileViewController else { return }
            profilViewController.user = user
            profilViewController.modalPresentationStyle = .overFullScreen
            DispatchQueue.main.async {
                UIApplication.getTopViewController()?.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    private func showAskedFollowList(userId: String) {
        if UIApplication.getTopViewController()?.typeString() == NotificationDashboardViewController.typeString() {
            self.showUserProfil(userId: userId)
        } else {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let profilViewController = navigationController.viewControllers.first as? ProfileViewController else { return }
            profilViewController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                UIApplication.getTopViewController()?.present(navigationController, animated: true) {
                    profilViewController.performSegue(withIdentifier: "goToNotification", sender: profilViewController)
                }
            }
        }
    }

}
