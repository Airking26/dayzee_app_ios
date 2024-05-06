//
//  SignUpVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import ActiveLabel

class SignUpVC: UIViewController {

    static let EmptyFieldText   = Locale.current.isFrench ? "Veuillez bien remplir tout les champs requis" : "Please fill all fields"

    @IBOutlet weak var usernameTextField: UITextField! { didSet { self.usernameTextField.delegate = self }}
    @IBOutlet weak var emailTextField: UITextField! { didSet { self.emailTextField.delegate = self }}
    @IBOutlet weak var passwordTextField: UITextField! { didSet { self.passwordTextField.delegate = self }}
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var privacyPolicyLabel: ActiveLabel!
    
    private let defaultCheckboxImage = UIImage(named: "checkbox_empty")
    private let selectedCheckboxImage = UIImage(named: "checkbox_tapped")
    private var policyIsAdmit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initUI()
    }
    
    // MARK: - Private methods
    
    private func initUI() {
        self.privacyPolicyLabel.text = ""
        let mutableAttributedString = NSMutableAttributedString(string: "termsOfUseAndPrivacyFull".localized)
        let terms = ActiveType.custom(pattern: "termsOfUse".localized)
        let privacyPolicy = ActiveType.custom(pattern: "privacyPolicy".localized)
        self.privacyPolicyLabel.attributedText = mutableAttributedString
        self.privacyPolicyLabel.enabledTypes = [terms, privacyPolicy]
        self.privacyPolicyLabel.customColor[terms] = .label
        self.privacyPolicyLabel.customColor[privacyPolicy] = .label
        self.privacyPolicyLabel.handleCustomTap(for: terms) { _ in
            self.openWebContent(from: WebService.Consts.PrivacyPolicyURL)
        }
        self.privacyPolicyLabel.handleCustomTap(for: privacyPolicy) { _ in
            self.openWebContent(from: WebService.Consts.TermOfUseURL)
        }
    }
    
    private func openWebContent(from urlString: String) {
        if let url = URL(string: urlString) {
            let vc = WebContentVC()
            vc.contentURl = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func privacyPolicyButtonTapped(_ sender: UIButton) {
        self.policyIsAdmit.toggle()
        self.privacyPolicyButton.setImage( self.policyIsAdmit ? selectedCheckboxImage : defaultCheckboxImage, for: .normal)
    }
    
    @IBAction func signupIsTapped(_ sender: UIButton) {
        guard let email = self.emailTextField.text, let username = self.usernameTextField.text, let password = self.passwordTextField.text, !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            AlertManager.shared.showErrorWithTilteAndDesciption(title: SignUpVC.EmptyFieldText, desciption: "")
            return
        }
        guard self.policyIsAdmit else {
            AlertManager.shared.showErrorWithTilteAndDesciption(title: "PrivacyPolicyAlert".localized, desciption: "")
            return
        }
        UserManager.shared.checkUsername(userName: username) { (success) in
            guard success else { return AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre nom d'utilisateur est déjà utilisé" : "This username is already used", desciption: "") }
            UserManager.shared.signup(email: email, userName: username, password: password) { (token) in
                guard let _ = token else { return }
                UserManager.shared.isUserSignup = true
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension SignUpVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case self.usernameTextField:
            self.emailTextField.becomeFirstResponder()
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
        case self.passwordTextField:
            self.passwordTextField.resignFirstResponder()
        default:
            break;
        }
        return true
    }
}
