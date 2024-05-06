//
//  SignInVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
         
    static let EmptyFieldText   = Locale.current.isFrench ? "Veuillez bien remplir tout les champs requis" : "Please fill all the fields"
    
    @IBOutlet weak var emailOrUsernameTextField: UITextField! { didSet { self.emailOrUsernameTextField.delegate = self }}
    @IBOutlet weak var passwordTextField: UITextField! { didSet { self.passwordTextField.delegate = self }}
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    private func initUI() {
        let forgotPasswordTap = UITapGestureRecognizer(target: self, action: #selector(self.forgotPasswordIsTapped(_:)))
        self.forgotPasswordLabel.addGestureRecognizer(forgotPasswordTap)
    }
    
    @objc func forgotPasswordIsTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: Locale.current.isFrench ? "Réinitialisation de votre mot de passe" : "Password reset", message: Locale.current.isFrench ? "Entrez votre adresse e-mail pour réinitialiser votre mot de passe" : "Enter your email adress to reset your password", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = Locale.current.isFrench ? "Entrez votre e-mail" : "Enter your email"
        }
        let connectAction = UIAlertAction(title: Locale.current.isFrench ? "Validez" : "Submit", style: .default) { (action) in
            UserManager.shared.forgotPassword(email: alertController.textFields?.first?.text) { (success) in
                guard !success else { return }
                alertController.title = Locale.current.isFrench ? "Votre email est incorrect" : "Your email is incorrect"
                self.present(alertController, animated: true, completion: nil)
            }
        }
        let retourAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Cancel", style: .cancel, handler: nil)
        retourAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(connectAction)
        alertController.addAction(retourAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func connectTimeNoteIsTapped(_ sender: Any) {
        guard let emailOrUsername = self.emailOrUsernameTextField.text, let password = self.passwordTextField.text, !emailOrUsername.isEmpty, !password.isEmpty else {
            AlertManager.shared.showErrorWithTilteAndDesciption(title: SignInVC.EmptyFieldText, desciption: "")
            return
        }
        UserManager.shared.signin(emailOrUsername: emailOrUsername, password: password) { (token) in
            guard let _ = token else { return }
            guard !password.starts(with: "DAYZEE-") else {
                let alert = UIAlertController(title: Locale.current.isFrench ? "Veuillez entrez votre nouveau mot de passe" : "Please enter a new password", message: "", preferredStyle: .alert)
                alert.addTextField { (textField : UITextField!) -> Void in
                    textField.placeholder = Locale.current.isFrench ? "Entrez le mot de passe" : "Enter a password"
                }
                alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Changer" : "Submit", style: .default, handler: { (alertAction) in
                    guard let password = alert.textFields?.first?.text, !password.isEmpty else { return self.present(alert, animated: true, completion: nil)}
                    UserManager.shared.changePassword(oldPassword: alert.textFields?.first?.text,
                                                      newPassword: alert.textFields?.first?.text) { (success) in
                        guard success else { return self.present(alert, animated: true, completion: nil) }
                        AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre modification de mot de passe à été effectué." : "Your new password has been updated successfully", desciption: "", isBlue: true)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SignInVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailOrUsernameTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.passwordTextField.resignFirstResponder()
        default:
            break;
        }
        return true
    }
    
}
