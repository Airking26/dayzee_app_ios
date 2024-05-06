//
//  WelcomeVC.swift
//  Timenote
//
//  Created by Dev on 12/10/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    private var hasSafeArea: Bool {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        guard let topPadding = keyWindow?.safeAreaInsets.top, topPadding > 20 else {
            return false
        }
        return true
    }
    
    @IBOutlet weak var buttonsHeightConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        self.initUI()
    }
    
    private func initUI() {
        self.buttonsHeightConstraint.constant = hasSafeArea ? 0 : 30
    }
    
    @IBAction func guestButtonTapped(_ sender: UIButton) {
        UserManager.shared.isUserWithNoAccount = true
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
