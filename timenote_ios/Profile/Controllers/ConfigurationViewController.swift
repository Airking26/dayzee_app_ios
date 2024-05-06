//
//  CinfigurationViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 19/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine
import GoogleSignIn
import GoogleAPIClientForREST
import GTMAppAuth

protocol ConfigurationViewDelegate {
    func reloadTimenotes()
}

class ConfigurationViewController : UIViewController {
    
    @IBOutlet weak var dateFormatDataPicker: DataPickerTextField! { didSet {
        self.dateFormatDataPicker.setPickerData(UserDateFormatDto.all, self.dateFormatDataPicker.debugDescription)
        self.dateFormatDataPicker.pickerViewDelegate = self
    }}
    @IBOutlet weak var privacySwitch: UISwitch!
    @IBOutlet weak var synchronizationSwitch: UISwitch!
    @IBOutlet weak var visibilityDataPicker: DataPickerTextField! { didSet {
        self.visibilityDataPicker.setPickerData(Locale.current.isFrench ? ["Tout le monde", "Uniquement moi"] : ["Everyone", "Only me"], self.visibilityDataPicker.debugDescription)
        self.visibilityDataPicker.pickerViewDelegate = self
        
    }}
    
    var delegate: ConfigurationViewDelegate?
    
    private var isPending = false
    private var cancellableBag  = Set<AnyCancellable>()
    private var user  : UserResponseDto? { didSet {
        guard self.isViewLoaded else { return }
        self.configureView()
    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.shared.userInformationPublisher.assign(to: \.self.user, on: self).store(in: &self.cancellableBag)
        self.configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        synchronizationSwitch.isOn = GIDSignIn.sharedInstance.hasPreviousSignIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let followViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? FollowAskedViewController {
            followViewController.isPending = self.isPending
        } else if let followViewController = segue.destination as? NotificationDashboardViewController,
                  let viewType = sender as? NotificationViewType {
            followViewController.viewType = viewType
        }
    }
    
// MARK: - Private methods
    
    private func configureView() {
        guard let userInformation = self.user else { return }
        self.dateFormatDataPicker.text = userInformation.dateFormat.toString()
        self.privacySwitch.isOn = userInformation.status == .PRIVATE
        self.visibilityDataPicker.text = UserManager.shared.visibility ?? (Locale.current.isFrench ? "Tout le monde" : "Everyone")
    }
    
// MARK: - Google sign in
    
    private func googleSignIn(completion: @escaping (Bool?) -> Void) {
        let signInConfig = GIDConfiguration.init(clientID: "797286347530-93hgk4j19nn3ioegld3lt7114cl8q4v6.apps.googleusercontent.com")
        if !GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.signIn(with: signInConfig,
                                            presenting: self)
            { user, error in
                guard error == nil,
                      let user = user
                else { return }
                if !(user.grantedScopes?.contains(kGTLRAuthScopeCalendar) ?? false) {
                    GIDSignIn.sharedInstance.addScopes([kGTLRAuthScopeCalendar,kGTLRAuthScopeCalendarEvents], presenting: self) { [weak self] _, error in
                        self?.delegate?.reloadTimenotes()
                        if let error = error {
                            print("Error - \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
// MARK: - Actions
    
    @IBAction func isPrivateSwitch(_ sender: UISwitch) {
        UserManager.shared.updateUserPrivacyAccount(isPrivate: sender.isOn)
    }
    
    @IBAction func isSynchronizationEnabled(_ sender: UISwitch) {
        //Login or logout google
        sender.isOn ? googleSignIn(completion: { complete in
            sender.isOn = complete ?? true
        }) : GIDSignIn.sharedInstance.signOut()
        delegate?.reloadTimenotes()
    }
    
    @IBAction func modifyPassword(_ sender: UIButton) {
        UserManager.shared.handleRestoreUserPassword(at: self, isForgotPassword: false)
    }
    
    @IBAction func logoutIsTapped(_ sender: UIButton) {
        UserManager.shared.logOut()
        self.dismiss(animated: true, completion: nil)
        (self.presentingViewController as? UINavigationController)?.popToRootViewController(animated: true)
    }

    @IBAction func pendingIsTapped(_ sender: UIButton) {
        self.isPending = true
        self.performSegue(withIdentifier: "goToFollowAsked", sender: self)
    }
    
    @IBAction func requestedIsTapped(_ sender: UIButton) {
        self.isPending = false
        self.performSegue(withIdentifier: "goToFollowAsked", sender: self)
    }
    
    @IBAction func hiddenEventsButtonTapped(_ sender: UIButton) {
        self.isPending = false
        let sender:NotificationViewType = .hiddenEventsList
        self.performSegue(withIdentifier: "goToNotification", sender: sender)
    }
    
    @IBAction func hiddenUsersButtonTapped(_ sender: UIButton) {
        self.isPending = false
        let sender:NotificationViewType = .hiddenUsersList
        self.performSegue(withIdentifier: "goToNotification", sender: sender)
    }
}

extension ConfigurationViewController : DataPickerTextFieldDelegate {
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        switch value {
        case "Date":
            UserManager.shared.updateDateFormatAccount(isDate: true)
        case Locale.current.isFrench ? "Date et heure" : "Date and time":
            UserManager.shared.updateDateFormatAccount(isDate: false)
        case Locale.current.isFrench ? "Tout le monde" : "Everyone":
            UserManager.shared.visibility = value
        case Locale.current.isFrench ? "Uniquement moi" : "Only me":
            UserManager.shared.visibility = value
        default:
            return
        }
    }
    
}
