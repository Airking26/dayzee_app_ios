//
//  PasswordRestoreViewController.swift
//  Timenote
//
//  Created by Dev on 11/12/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import UIKit
import SwiftEntryKit

class PasswordRestoreViewController: UIViewController {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var firstPasswordTextField: UITextField!
    @IBOutlet weak var secondPasswordTextField: UITextField!
    
    public var isForgotPassword: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initUI()
    }
    
    // MARK: - Actions
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.closeWindow()
    }
    
    @IBAction func validateButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.isForgotPassword ? self.changePassword() : self.modifyPassword()
    }
    
    // MARK: - Private methods
    
    private func initUI() {
        self.oldPasswordTextField.isHidden = self.isForgotPassword
    }
    
    private func modifyPassword() {
        self.checkNewPassword {
            UserManager.shared.changePassword(oldPassword: oldPasswordTextField.text, newPassword: secondPasswordTextField.text) { [weak self] isSuccess in
                self?.showCompletionAlert(isSuccess: isSuccess)
            }
        }
    }
    
    private func changePassword() {
        self.checkNewPassword {
            UserManager.shared.changePassword(password: secondPasswordTextField.text) { [weak self] isSuccess in
                self?.showCompletionAlert(isSuccess: isSuccess)
            }
        }
    }
    
    private func checkNewPassword(action: () -> Void) {
        let firstPass = firstPasswordTextField.text ?? ""
        let secondPass = secondPasswordTextField.text ?? "."
        if firstPass == secondPass {
            action()
        } else {
            AlertManager.shared.showErrorWithTilteAndDesciption(title: "passwordsNotEqual".localized,
                                                                desciption: "passwordsNotEqualDescription".localized)
        }
    }
    private func showCompletionAlert(isSuccess: Bool) {
        let title = isSuccess ? "passwordChanged" : "passwordChangeError"
        let description = isSuccess ? "" : "passwordChangeErrorDescription"
        AlertManager.shared.showErrorWithTilteAndDesciption(title: title.localized,
                                                            desciption: description.localized,
                                                            isBlue: isSuccess)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.closeWindow()
        }
    }
    
    private func closeWindow() {
        self.dismiss(animated: true, completion: nil)
    }

}
