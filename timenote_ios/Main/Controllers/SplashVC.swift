//
//  ViewController.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 4/21/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit

class SplashVC: UIViewController {

    static let IsNotFirstConnexionKey        = "SplashVC_IsNotFirstConnexionKey"
    
    @IBOutlet weak var animatedImageView: UIAnimatedSwitchImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure background switch animation
        //self.configureAnimatedImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard UserDefaults.standard.value(forKey: SplashVC.IsNotFirstConnexionKey) != nil else {
            UserDefaults.standard.setValue(true, forKey: SplashVC.IsNotFirstConnexionKey)
            UserManager.shared.isUserWithNoAccount = true
            self.goHomeTapped()
            return
        }
        if UserManager.shared.isLogged || UserManager.shared.isUserWithNoAccount { self.goHomeTapped() } else {
            self.signInTapped()
        }
    }

    private func configureAnimatedImageView() {
        self.animatedImageView.animationSwitchIsRestarting = true
        self.animatedImageView.animationSwitchTick = 10.0
        self.animatedImageView.animationSwitchDuration = 0.3
        self.animatedImageView.animationSwitchImages = [UIImage(named: "login_photo1"),UIImage(named: "login_photo2"),UIImage(named: "login_photo3")]
        self.animatedImageView.startSwitchAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    
    private func signInTapped() {
        performSegue(withIdentifier: "goToAuthentication", sender: nil)
    }
    private func goHomeTapped() {
        performSegue(withIdentifier: "goToHome", sender: nil)
    }
}

