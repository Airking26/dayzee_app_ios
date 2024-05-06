//
//  EditProfileViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/6/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import ImagePicker
import Combine
import GooglePlaces
import YPImagePicker

enum LocalisationType {
    case FULL
    case CITY
    case NONE
}

class EditProfileViewController : UIViewController {

    /* IBOUTLET */

    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var userProfilImageView: UIImageView!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldUserFullName: UITextField!
    @IBOutlet weak var textFieldUserPlace: UITextField! { didSet {
        self.textFieldUserPlace.addTarget(self, action: #selector(self.showAdresseSelection), for: .editingDidBegin)
    }}
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var textFieldUserBirthday: DatePickerTextField! { didSet {
        self.textFieldUserBirthday.datePickerView.maximumDate = Date()
    }}
    @IBOutlet weak var textFieldUserSex: DataPickerTextField! { didSet {
        var all: [String] = []
        UserGenderDto.allCases.forEach {
            all.append($0.toString ?? "")
        }
        self.textFieldUserSex.setPickerData(all, self.textFieldUserSex.debugDescription)
    }}
    @IBOutlet weak var textFIeldUserPrivate: DataPickerTextField! { didSet {
        self.textFIeldUserPrivate.setPickerData(UserStatusAccountDto.all, self.textFIeldUserPrivate.debugDescription)
    }}
    @IBOutlet weak var textFieldUserDateFormat: DataPickerTextField! { didSet {
        self.textFieldUserDateFormat.setPickerData(UserDateFormatDto.all, self.textFieldUserDateFormat.debugDescription)

    }}
    @IBOutlet weak var textFieldUserDescription: UITextField!
    @IBOutlet weak var yputubeTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var whatsappTextField: UITextField!
    @IBOutlet weak var linkedinTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var discordTextField: UITextField!
    @IBOutlet weak var telegramTextField: UITextField!
    @IBOutlet weak var YoutubeSwitch: UISwitch!
    @IBOutlet weak var facebookSwitch: UISwitch!
    @IBOutlet weak var InstagramSwitch: UISwitch!
    @IBOutlet weak var whatsappSwitch: UISwitch!
    @IBOutlet weak var linkedinSwitch: UISwitch!
    @IBOutlet weak var twitterSwitch: UISwitch!
    @IBOutlet weak var discordSwitch: UISwitch!
    @IBOutlet weak var telegramSwitch: UISwitch!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var locationStack: UIStackView!

    //Social networking stack outlets
    @IBOutlet weak var youTubeStack: UIStackView!
    @IBOutlet weak var facebookStack: UIStackView!
    @IBOutlet weak var instagrammStack: UIStackView!
    @IBOutlet weak var whatsappStack: UIStackView!
    @IBOutlet weak var linkedinStack: UIStackView!
    @IBOutlet weak var twitterStack: UIStackView!
    @IBOutlet weak var discordStack: UIStackView!
    @IBOutlet weak var telegramStack: UIStackView!
    @IBOutlet weak var certifiedView: UIView!

    private var imagePickerController   : ImagePickerController = ImagePickerController()
    private var YPimagePicker           : YPImagePicker?
    private var image: UIImage?
    private var localisationType        : LocalisationType      = .FULL
    private var selectedPlace: GMSPlace?
    private var imageUrl: URL? { didSet {
        guard self.imageUrl != nil else { return }
        if self.isUploading { self.saveUserIsTapped(self.confirmButton) }
        self.image = nil
    }}
    private var isUploading     : Bool = false
    public var user             : UserResponseDto?  = UserManager.shared.userInformation
    private var cancellableBag  = Set<AnyCancellable>()

    /* IBACTION */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.setImagePicker()
        AWS3Manager.shared.imageUploadPublisher.assign(to: \.self.imageUrl, on: self).store(in: &self.cancellableBag)
        self.textFieldUserBirthday.isTimeActivated = false
        self.textFieldUserBirthday.datePickerView.minimumDate = nil
    }

    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setImagePicker() {
        var imagePickerConfiguration = YPImagePickerConfiguration()
        imagePickerConfiguration.showsCrop = .rectangle(ratio: 1)
        imagePickerConfiguration.onlySquareImagesFromCamera = true
        imagePickerConfiguration.showsPhotoFilters = true
        imagePickerConfiguration.startOnScreen = YPPickerScreen.photo
        imagePickerConfiguration.screens = [.library, .photo]
        imagePickerConfiguration.library.onlySquare = true
        imagePickerConfiguration.library.isSquareByDefault = true
        imagePickerConfiguration.library.defaultMultipleSelection = false
        imagePickerConfiguration.library.maxNumberOfItems = 1
        imagePickerConfiguration.library.minNumberOfItems = 1
        self.YPimagePicker = YPImagePicker(configuration: imagePickerConfiguration)
        self.YPimagePicker?.didFinishPicking(completion: { (items, success) in
            if let image = items.singlePhoto?.image {
                self.image = image
                DispatchQueue.main.async {
                    self.userProfilImageView.image = self.image
                    self.imageUrl = nil
                    AWS3Manager.shared.uploadVideo(with: image, isProfil: true)
                }
            }
            self.YPimagePicker?.dismiss(animated: true, completion: nil)
        })
    }

    @IBAction func saveUserIsTapped(_ sender: UIButton) {
        self.updateUserInfo()
    }

    @IBAction func userPictureIsTapped(_ sender: UITapGestureRecognizer) {
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        if let imagePicker = self.YPimagePicker {
            self.present(imagePicker, animated: true, completion: nil)
        }
        //self.present(self.imagePickerController, animated: true, completion: nil)
    }

    @objc public func showAdresseSelection() {
        GoogleLocationManager.shared.presentGoogleAutoComplete(self)
    }

    @IBAction func shareProfilIsTapped(_ sender: UIButton) {
        self.present(UIActivityViewController(activityItems: ["com.Dayzee://user?userId=\(self.user?.id ?? "")"], applicationActivities: nil), animated: true)
    }

    @IBAction func didEnableLink(_ sender: UISwitch) {
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        switch sender {
        case YoutubeSwitch:
            self.YoutubeSwitch.isOn = !(yputubeTextField.text?.isEmpty ?? true) && sender.isOn
        case facebookSwitch:
            self.facebookSwitch.isOn = !(facebookTextField.text?.isEmpty ?? true) && sender.isOn
        case InstagramSwitch:
            self.InstagramSwitch.isOn = !(instagramTextField.text?.isEmpty ?? true) && sender.isOn
        case whatsappSwitch:
            self.whatsappSwitch.isOn = !(whatsappTextField.text?.isEmpty ?? true) && sender.isOn
        case linkedinSwitch:
            self.linkedinSwitch.isOn = !(linkedinTextField.text?.isEmpty ?? true) && sender.isOn
        case twitterSwitch:
            self.twitterSwitch.isOn = !(twitterTextField.text?.isEmpty ?? true) && sender.isOn
        case discordSwitch:
            self.discordSwitch.isOn = !(discordTextField.text?.isEmpty ?? true) && sender.isOn
        case telegramSwitch:
            self.telegramSwitch.isOn = !(telegramTextField.text?.isEmpty ?? true) && sender.isOn
        default:
            break
        }
    }

    private func configureView() {
        guard let user = self.user else { return }
        self.confirmButton.isHidden = user.id != UserManager.shared.userInformation?.id
        self.labelUserName.text = user.userName
        if let pictureString = user.picture, let url = URL(string: pictureString) {
            self.userProfilImageView.sd_setImage(with: url)
        }
        self.textFieldUserName.text = user.fullName
        self.certifiedView.isHidden = !(user.certified ?? false)
        self.textFieldUserFullName.text = user.givenName
        self.textFieldUserFullName.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.textFieldUserPlace.text = user.location?.address.address
        self.textFieldUserPlace.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        if let date = user.birthday?.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSX") {
            self.textFieldUserBirthday.datePickerView.date = date
            self.textFieldUserBirthday.text = date.toString()
        }
        self.textFieldUserBirthday.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        locationStack.isHidden = !(user.location?.address.address != nil)
        self.locationSwitch.isOn = user.location?.address.address != nil
        self.locationSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.textFieldUserSex.text = user.genderEnum.toString
        self.textFieldUserSex.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.textFIeldUserPrivate.text = user.status.toString()
        self.textFIeldUserPrivate.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.textFieldUserDateFormat.text = user.dateFormat == .SECOND ? "Date" : Locale.current.isFrench ? "Date et heure" : "Date and time"
        self.textFieldUserDateFormat.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.textFieldUserDescription.text = user.descript
        self.textFieldUserDescription.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id

        youTubeStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.yputubeTextField.text = user.socialMedias.youtube.url
        self.yputubeTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        facebookStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.facebookTextField.text = user.socialMedias.facebook.url
        self.facebookTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        instagrammStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.instagramTextField.text = user.socialMedias.instagram.url
        self.instagramTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        whatsappStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.whatsappTextField.text = user.socialMedias.whatsApp.url
        self.whatsappTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        linkedinStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.linkedinTextField.text = user.socialMedias.linkedIn.url
        self.linkedinTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        twitterStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.twitterTextField.text = user.socialMedias.twitter.url
        self.twitterTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        discordStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.discordTextField.text = user.socialMedias.discord.url
        self.discordTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        telegramStack.isHidden = !(user.id == UserManager.shared.userInformation?.id)
        self.telegramTextField.text = user.socialMedias.telegram.url
        self.telegramTextField.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        
        self.YoutubeSwitch.isOn = user.socialMedias.youtube.enabled
        self.YoutubeSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.facebookSwitch.isOn = user.socialMedias.facebook.enabled
        self.facebookSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.InstagramSwitch.isOn = user.socialMedias.instagram.enabled
        self.InstagramSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.whatsappSwitch.isOn = user.socialMedias.whatsApp.enabled
        self.whatsappSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.linkedinSwitch.isOn = user.socialMedias.linkedIn.enabled
        self.linkedinSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.twitterSwitch.isOn = user.socialMedias.twitter.enabled
        self.twitterSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.discordSwitch.isOn = user.socialMedias.discord.enabled
        self.discordSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
        self.telegramSwitch.isOn = user.socialMedias.telegram.enabled
        self.telegramSwitch.isUserInteractionEnabled = user.id == UserManager.shared.userInformation?.id
    }

    @IBAction func geolocIsTapped(_ sender: UIButton) {
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        self.showGeoloc()
    }

    private func updateUserInfo() {
        self.isUploading = true
        guard !AWS3Manager.shared.isUploadingProfil else { return }
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        guard let userName = self.textFieldUserName.text?.trimmedText, !userName.isEmpty else { return AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre nom d'utilisateur est incorrect" : "Username is not incorect", desciption: "")}
        DispatchQueue.main.async {
            self.confirmButton.isUserInteractionEnabled = false
        }
        let imageURL = self.imageUrl?.absoluteString == nil ? UserManager.shared.userInformation?.picture : self.imageUrl?.absoluteString
        if self.locationSwitch.isOn {
            GoogleLocationManager.shared.getTimenoteLocation(place: self.selectedPlace) { (userLocation) in
                self.saveUserInfo(userName: userName, userFullName: self.textFieldUserFullName.text?.trimmedText, imageURL: imageURL, userLocation: userLocation)
            }
        } else {
            self.saveUserInfo(userName: userName, userFullName: self.textFieldUserFullName.text?.trimmedText, imageURL: imageURL, userLocation: nil)
        }
    }

    private func saveUserInfo(userName: String, userFullName: String?, imageURL: String?, userLocation: UserLocationDto?) {
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        let userDto = UserUpdateDto(givenName: userFullName, familyName: userFullName, picture: imageURL, location: userLocation, birthday: !self.textFieldUserBirthday.text!.isEmpty ? self.textFieldUserBirthday.datePickerView.date.iso8601withFractionalSeconds : nil, description: self.textFieldUserDescription.text, gender: UserGenderDto.fromString(string: self.textFieldUserSex.text!), status: UserStatusAccountDto.fromString(string: self.textFIeldUserPrivate.text!), dateFormat: UserDateFormatDto.fromString(string: textFieldUserDateFormat.text!), socialMedias: SocialMediasDto(youtube: SocialMediaDto(url: self.yputubeTextField.text!, enabled: self.YoutubeSwitch.isOn), facebook: SocialMediaDto(url: self.facebookTextField.text!, enabled: self.facebookSwitch.isOn), instagram: SocialMediaDto(url: self.instagramTextField.text!, enabled: self.InstagramSwitch.isOn), whatsApp: SocialMediaDto(url: self.whatsappTextField.text!, enabled: self.whatsappSwitch.isOn), linkedIn: SocialMediaDto(url: self.linkedinTextField.text!, enabled: self.linkedinSwitch.isOn), twitter: SocialMediaDto(url: self.twitterTextField.text!, enabled: self.twitterSwitch.isOn), discord: SocialMediaDto(url: self.discordTextField.text!, enabled: self.discordSwitch.isOn), telegram: SocialMediaDto(url: self.telegramTextField.text!, enabled: self.telegramSwitch.isOn)))
        UserManager.shared.updateUserInfo(userData: userDto)
        AWS3Manager.shared.imageUploadPublisher.value = nil
        self.isUploading = false
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func showGeoloc() {
        let alert = UIAlertController(title: "Localisation", message: nil, preferredStyle: .actionSheet)
        let none = UIAlertAction(title: "Pas de localisation", style: .default, handler: { (alertAction) in
        })
        none.setValue(self.localisationType == .NONE ? UIColor.systemYellow : UIColor.link, forKey: "titleTextColor")
        alert.addAction(none)
        let city = UIAlertAction(title: "Ville", style: .default, handler: { (alertAction) in
        })
        city.setValue(self.localisationType == .CITY ? UIColor.systemYellow : UIColor.link, forKey: "titleTextColor")
        alert.addAction(city)
        let full = UIAlertAction(title: "Adresse", style: .default, handler: { (alertAction) in
        })
        full.setValue(self.localisationType == .FULL ? UIColor.systemYellow : UIColor.link, forKey: "titleTextColor")
        alert.addAction(full)
        let retour = UIAlertAction(title: "Retour", style: .cancel, handler: nil)
        retour.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(retour)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension EditProfileViewController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard self.user?.id == UserManager.shared.userInformation?.id else { return }
        self.textFieldUserPlace.text = GoogleLocationManager.getFullAdresseOf(place)
        self.selectedPlace = place
        viewController.dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

}
