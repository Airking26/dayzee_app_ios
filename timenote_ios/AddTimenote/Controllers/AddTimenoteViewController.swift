//
//  AddTimenoteViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 8/3/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import Combine
import YPImagePicker

class AddTimenoteDataSource : UICollectionViewDiffableDataSource<Section, UIImage> {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as! PictureCell
            cell.configure(image: UIImage(named: "add")!, delegate: nil)
            return cell
        default:
            return UICollectionReusableView()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return collectionView.numberOfItems(inSection: 0) - 1 != indexPath.row
    }
    
}

typealias AddTimenoteSnapShot   = NSDiffableDataSourceSnapshot<Section, UIImage>

enum ShareType : String {
    case ALL        = "Tout le monde"
    case ME         = "Uniquement moi"
    case GROUP      = "Groupe"
    case FRIENDS    = "Mes amis"
}

enum FollowingTypeResult  {
    case SHARE
    case ORGANIZER
}

class AddTimenoteViewController : UIViewController {
    
    // STATIC
    
    static let DescriptionPlaceHolder   : String    = Locale.current.isFrench ? "Entrez votre description ici" : "Ennter your description here"
    
    // OUTLETS
    @IBOutlet weak var heightContrainte: NSLayoutConstraint!
    @IBOutlet weak var priceTextField: UITextField! { didSet {
        self.priceTextField.delegate = self
    }}
    @IBOutlet weak var currencyTextField: UITextField! { didSet {
        self.currencyTextField.delegate = self
    }}
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var souCategorieTextField: DataPickerTextField! { didSet {
        self.souCategorieTextField.delegate = self
    }}
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var colorsStackView: UIStackView!
    
    @IBOutlet var colorButtons: [UIButton]!
    @IBOutlet weak var groupShareTextField: DataPickerTextField! { didSet {
        self.groupShareTextField.setPickerData(Locale.current.isFrench ? ["Tout le monde", "Uniquement moi", "Groupe", "Mes amis"] : ["Everyone", "Only me", "Group", "Friends"], self.groupShareTextField.debugDescription)
        self.groupShareTextField.pickerViewDelegate = self
        self.groupShareTextField.delegate = self
        self.groupShareTextField.text = UserManager.shared.visibility ?? (Locale.current.isFrench ? "Tout le monde" : "Everyone")
    }}
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var categorieTextField: DataPickerTextField! { didSet {
        var categories = [""]
        categories.append(contentsOf: CategorieManager.shared.postCategories.map({$0.category}).compactMap({$0}))
        self.categorieTextField.setPickerData(categories, "categorieTextField")
        self.categorieTextField.pickerViewDelegate = self
        self.categorieTextField.delegate = self
    }}
    
    @IBOutlet weak var paiedTextField: DataPickerTextField! { didSet {
        self.paiedTextField.setPickerData(Locale.current.isFrench ? ["Pas de réponse", "Gratuit", "Payant"] : ["Unknown", "Free", "Paying"], self.paiedTextField.debugDescription)
        self.paiedTextField.text = Locale.current.isFrench ? "Pas de réponse" : "Unknown"
        self.paiedTextField.pickerViewDelegate = self
        self.paiedTextField.delegate = self
    }}
    @IBOutlet weak var titleTextField: UITextField! { didSet {
        self.titleTextField.delegate = self
    }}
    @IBOutlet weak var linkName: UITextField! { didSet {
        self.linkName.delegate = self
    }}
    @IBOutlet weak var screenCenterY: NSLayoutConstraint!
    @IBOutlet weak var startDateTextField: DatePickerTextField! { didSet {
        self.startDateTextField.datePickerDelegate = self
        self.startDateTextField.alpha = 0.01
        self.startDateTextField.datePickerView.maximumDate = nil
        self.startDateTextField.delegate = self
        self.startDateTextField.datePickerView.datePickerMode = .date
    }}
    @IBOutlet weak var startHourTextField: DatePickerTextField! { didSet {
        self.startHourTextField.datePickerDelegate = self
        self.startHourTextField.alpha = 0.01
        self.startHourTextField.datePickerView.maximumDate = nil
        self.startHourTextField.delegate = self
        self.startHourTextField.datePickerView.datePickerMode = .time
    }}
    @IBOutlet weak var endDateTextField: DatePickerTextField! { didSet {
        self.endDateTextField.datePickerDelegate = self
        self.endDateTextField.delegate = self
        self.endDateTextField.datePickerView.datePickerMode = .date
    }}
    @IBOutlet weak var endHourTextField: DatePickerTextField! { didSet {
        self.endHourTextField.datePickerDelegate = self
        self.endHourTextField.datePickerView.datePickerMode = .time
        self.endHourTextField.delegate = self
    }}
    @IBOutlet weak var adresseTextField: UITextField! { didSet {
        self.adresseTextField.delegate = self
    }}
    @IBOutlet weak var descriptionTextView: UITextView! { didSet {
        self.descriptionTextView.delegate = self
        self.descriptionTextView.textColor = UIColor.lightGray
    }}
    @IBOutlet weak var pictureCollectionView: UICollectionView! { didSet {
        self.pictureCollectionView.delegate = self
        self.pictureCollectionView.dragDelegate = self
        self.pictureCollectionView.dropDelegate = self
        self.pictureCollectionView.dragInteractionEnabled = true
    }}
    @IBOutlet weak var titleScreenLabel: UILabel!
    @IBOutlet weak var descriptionStackView: UIStackView!
    @IBOutlet weak var toDateStackView: UIStackView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var lienTextField: UITextField! { didSet {
        self.lienTextField.delegate = self
    }}
    @IBOutlet weak var organisateurTextField: UITextField! { didSet {
        self.organisateurTextField.addTarget(self, action: #selector(self.showOrganizers), for: .editingDidBegin)
        self.organisateurTextField.delegate = self
    }}
    @IBOutlet weak var reinitButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // VARIABLES
    private var YPimagePicker           : YPImagePicker?
    private var selectedPlace           : GMSPlace?                 = nil
    private var selectedImages          : [UIImage]                 = [] { didSet {
        self.updateUI()
    }}
    private var colorHex                : String                    = ""
    private var addTimenoteDataSource   : AddTimenoteDataSource!
    private var addTimenoteSnapShot     : AddTimenoteSnapShot!
    private var shareType               : ShareType                 = .ALL
    private var followingTypeResult     : FollowingTypeResult       = .ORGANIZER
    private var imagesURLUploaded       : TimenoteURL? { didSet {
        guard !self.selectedImagesURL.isEmpty else { return }
        if let url = self.imagesURLUploaded?.url {
            if let index = self.imagesURLUploaded?.index {
                self.selectedImagesURL.insert(url, at: index)
            } else {
                self.selectedImagesURL.append(url)
            }
        }
    }}
    private var selectedImagesURL       : [URL?]                 = [] { didSet {
        if self.selectedImagesURL.compactMap({$0}).count == self.selectedImages.count && !self.selectedImagesURL.compactMap({$0}).isEmpty {
            self.goToPreview()
        }
    }}
    private var groupe              : GroupSectionDto?      = nil
    private var cancellableBag      = Set<AnyCancellable>()
    private var timenoteDto         : CreateTimenoteDto?    = nil
    private var location            : UserLocationDto?      = nil
    private var oragnizer           : [String]              = []
    private var friends             : [String]              = []
    private var needAnimationUpdate : Bool                  = true

    public var timenoteUpdateId     : String?           = nil
    public var timenoteSelectedDto  : TimenoteDataDto?  = nil { didSet {
        guard self.isViewLoaded else { return }
        self.configureView()
    }}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureImageCollectionViewDataSource()
        self.configureImagePicker()
        AWS3Manager.shared.imageTimenoteUploadPublisher.assign(to: \.self.imagesURLUploaded, on: self).store(in: &self.cancellableBag)
        if self.timenoteUpdateId == nil {
            TimenoteManager.shared.timenoteLastDuplicate.assign(to: \.self.timenoteSelectedDto, on: self).store(in: &self.cancellableBag)
        } else {
            self.configureView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.timenoteUpdateId == nil else { return }
        self.configureView()
        self.selectedImagesURL = []
        self.groupShareTextField.resignFirstResponder()
        self.organisateurTextField.resignFirstResponder()
        self.groupShareTextField.resignFirstResponder()
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let googleSearchViewController = segue.destination as? GoogleImageSearchViewController {
            googleSearchViewController.delegate = self
        }
        if let previewViewController = segue.destination as? PreviewTimenoteViewController {
            previewViewController.timenoteDto = self.timenoteDto
            previewViewController.delegate = self
        }
        if let groupViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? UserGroupViewController {
            groupViewController.delegate = self
            groupViewController.currentGroup = self.groupe
        }
        if let followingListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.isSharing = false
            followingListViewController.delegate = self
            followingListViewController.selectedUsers = self.followingTypeResult == .ORGANIZER ? self.oragnizer : self.friends
        }
    }
    
    @objc func showOrganizers() {
        self.organisateurTextField.resignFirstResponder()
        self.followingTypeResult = .ORGANIZER
        self.performSegue(withIdentifier: "goToFollowing", sender: self)
    }
    
    private func refreshScreen() {
        self.activityIndicator.stopAnimating()
        self.oragnizer = []
        self.selectedImages = []
        self.selectedImagesURL = []
        self.location = nil
        if self.timenoteUpdateId == nil {
            self.timenoteSelectedDto = nil
            self.timenoteUpdateId = nil
        }
        self.timenoteDto = nil
        self.shareType = .ALL
        self.groupe = nil
        DispatchQueue.main.async {
            self.changeButtons(isEnabled: false)
            self.changeButtons(isEnabled: true)
            self.colorHex = ""
            self.currencyTextField.text = ""
            self.linkName.text = ""
            self.priceTextField.text = ""
            self.organisateurTextField.text = ""
            self.priceStackView.isHidden = true
            self.selectedPlace = nil
            self.titleTextField.text = ""
            self.descriptionTextView.textColor = .lightGray
            self.descriptionTextView.text = AddTimenoteViewController.DescriptionPlaceHolder
            self.descriptionStackView.isHidden = true
            self.nextButton.isUserInteractionEnabled = true
            self.adresseTextField.text = ""
            self.startDateTextField.alpha = 0
            self.startDateTextField.text = ""
            self.startHourTextField.alpha = 0
            self.startDateTextField.text = ""
            self.startDateTextField.datePickerView.date = Date()
            self.startHourTextField.datePickerView.date = Date()
            self.toDateStackView.isHidden = true
            self.endDateTextField.text = ""
            self.endHourTextField.text = ""
            self.endDateTextField.datePickerView.date = Date()
            self.endHourTextField.datePickerView.date = Date()
            self.categorieTextField.text = ""
            self.lienTextField.text = ""
            self.paiedTextField.text = Locale.current.isFrench ? "Pas de réponse" : "Unknown"
            self.groupShareTextField.text = Locale.current.isFrench ? "Tout le monde" : "Everyone"
        }
    }
    
    private func configureView() {
        guard let timenote = self.timenoteSelectedDto else { return }
        self.refreshScreen()
        DispatchQueue.main.async {
            if let _ = self.timenoteUpdateId {
                self.screenCenterY.constant = 0
                self.heightContrainte.constant = 70
                self.titleScreenLabel.text = Locale.current.isFrench ? "Editer le Dayzee" : "Edit the Dayzee"
                self.reinitButton.setTitle("", for: .normal)
                self.reinitButton.tintColor = .label
                self.reinitButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            }
            self.titleTextField.text = timenote.title
            self.descriptionStackView.isHidden = false
            if let description = timenote.descript {
                self.descriptionTextView.textColor = .label
                self.descriptionTextView.text = description
            }
            self.adresseTextField.text = timenote.location?.address.address
            self.location = timenote.location
            self.startDateTextField.alpha = 1
            self.startDateTextField.text = timenote.startingDate?.toDateTimeString()
            self.startDateTextField.datePickerView.date = timenote.startingDate ?? Date()
            self.toDateStackView.isHidden = false
            self.endDateTextField.text = timenote.endingDate?.toDateTimeString()
            self.endDateTextField.datePickerView.date = timenote.endingDate ?? Date()
            self.endDateTextField.datePickerView.minimumDate = self.startDateTextField.datePickerView.date
            self.startDateTextField.datePickerView.maximumDate = self.endDateTextField.datePickerView.date
            self.startDateTextField.datePickerView.minimumDate = Date()
            self.categorieTextField.text = timenote.category?.subcategory
            self.lienTextField.text = timenote.url
            self.linkName.text = timenote.urlTitle
            if let hex = timenote.colorHex {
                for button in self.colorButtons {
                    button.isSelected = false
                    if button.backgroundColor?.htmlRGBColor == hex {
                        button.isSelected = true
                        self.colorHex = hex
                    }
                }
            }
            if let price = timenote.price, price.value != 0 {
                self.priceStackView.isHidden = false
                self.currencyTextField.text = price.currency
                self.priceTextField.text = "\(price.value)"
                self.paiedTextField.text = Locale.current.isFrench ? "Payant" : "Paying"
            }
            for pictureUrl in timenote.pictures {
                if let url = URL(string: pictureUrl) {
                    SDWebImageSource.init(url: url).load(to: UIImageView()) { (image) in
                        if let image = image {
                            self.selectedImages.append(image)
                        }
                    }
                }
            }
        }
        TimenoteManager.shared.timenoteLastDuplicate.send(nil)
    }
    
    private func getSharingUser() -> [String] {
        switch self.shareType {
        case .ALL:
            return []
        case .FRIENDS:
            return self.friends
        case .GROUP:
            return self.groupe?.group.map({$0.user.id}) ?? []
        case .ME:
            return [UserManager.shared.userInformation?.id ?? ""]
        }
    }
    
    private func goToPreview() {
        self.activityIndicator.stopAnimating()
        let price = self.priceStackView.isHidden == true ? TimenotePriceDto(value: Double(self.priceTextField.text ?? "0.0") ?? 0.0, currency: self.currencyTextField.text ?? "") : TimenotePriceDto(value: 0, currency: "")
        let sharingUsers = self.getSharingUser()
        let allHastags = self.descriptionTextView.text.split(separator: "#").map({$0.components(separatedBy: CharacterSet.alphanumerics.inverted)[0]}).map({String($0)})
        if let location = self.location {
            self.configureTimenoteToPreview(allHastags: allHastags, location: location, price: price, sharingUsers: sharingUsers)
        } else {
            if let selectedPlace = self.selectedPlace {
                GoogleLocationManager.getPostalCodeOf(selectedPlace) { (postalCode) in
                    let location = UserLocationDto(longitude: self.selectedPlace!.coordinate.longitude, latitude: self.selectedPlace!.coordinate.latitude, address: UserAddressDto.init(address: GoogleLocationManager.getFullAdresseOf(self.selectedPlace)!, zipCode: postalCode ?? "", city: GoogleLocationManager.getCityOf(self.selectedPlace) ?? "", country: GoogleLocationManager.getCountryOf(self.selectedPlace)!))
                    self.configureTimenoteToPreview(allHastags: allHastags, location: location, price: price, sharingUsers: sharingUsers)
                }
            } else {
                self.configureTimenoteToPreview(allHastags: allHastags, location: nil, price: price, sharingUsers: sharingUsers)
            }
        }
    }
    
    private func configureTimenoteToPreview(allHastags: [String], location: UserLocationDto?, price: TimenotePriceDto, sharingUsers: [String]) {
        var startDateComponents = DateComponents()
        startDateComponents.day = Calendar.current.component(.day, from: self.startDateTextField.datePickerView.date)
        startDateComponents.month = Calendar.current.component(.month, from: self.startDateTextField.datePickerView.date)
        startDateComponents.year = Calendar.current.component(.year, from: self.startDateTextField.datePickerView.date)
        startDateComponents.hour = Calendar.current.component(.hour, from: self.startHourTextField.datePickerView.date)
        startDateComponents.day = Calendar.current.component(.day, from: self.startHourTextField.datePickerView.date)
        let startDate = Calendar.current.date(from: startDateComponents) ?? Date()
        var endDateComponents = DateComponents()
        endDateComponents.day = Calendar.current.component(.day, from: self.endDateTextField.datePickerView.date)
        endDateComponents.month = Calendar.current.component(.month, from: self.endDateTextField.datePickerView.date)
        endDateComponents.year = Calendar.current.component(.year, from: self.endDateTextField.datePickerView.date)
        endDateComponents.hour = Calendar.current.component(.hour, from: self.endHourTextField.datePickerView.date)
        endDateComponents.day = Calendar.current.component(.day, from: self.endHourTextField.datePickerView.date)
        let endDate = self.endDateTextField.text!.isEmpty ? startDate : Calendar.current.date(from: endDateComponents) ?? Date()
        self.nextButton.isUserInteractionEnabled = true
        self.timenoteDto = CreateTimenoteDto(createdBy: UserManager.shared.userInformation!.id, organizers: self.oragnizer, title: self.titleTextField.text ?? "", description: self.descriptionTextView.textColor == UIColor.lightGray || self.descriptionTextView.text.trimmedText.isEmpty ? nil : self.descriptionTextView.text, pictures: self.selectedImagesURL.compactMap({$0}).map({$0.absoluteString}), colorHex: self.colorHex, location: location, category: CategorieManager.shared.getCategorieOfSubCategorie(subCategorie: self.souCategorieTextField.text), startingAt: startDate.iso8601withFractionalSeconds, endingAt: endDate.iso8601withFractionalSeconds, hashtags: allHastags, urlTitle: self.linkName.text, url: self.lienTextField.text?.isEmpty == true ? nil : self.lienTextField.text, price: price, sharedWith: sharingUsers)
        if let timenoteId = self.timenoteUpdateId {
            TimenoteManager.shared.updateTimenote(timenoteId: timenoteId, timenoteData: self.timenoteDto!) { (timenote) in
                guard let timenote = timenote else { return }
                self.dismiss(animated: true) {
                    TimenoteManager.shared.newTimenotePublisher.send(timenote)
                }
            }
        } else {
            TimenoteManager.shared.addTimenote(timenote: self.timenoteDto!) { (timenote) in
                guard let timenote = timenote else { return }
                self.refreshScreen()
                TimenoteManager.shared.newTimenotePublisher.send(timenote)
            }
        }
    }
    
    @IBAction func reinitIsTapped(_ sender: UIButton) {
        guard self.timenoteUpdateId == nil else { return self.dismiss(animated: true, completion: nil)}
        DispatchQueue.main.async {
            self.refreshScreen()
        }
    }
    
    @IBAction func confirmIsTapped(_ sender: UIButton) {
        guard !self.selectedImages.isEmpty || !self.colorHex.isEmpty else { return AlertManager.shared.showNeedPicture() }
        guard !self.titleTextField.text!.trimmedText.isEmpty else { return AlertManager.shared.showIncorrectTitle() }
        guard self.lienTextField.text!.isEmpty || self.lienTextField.text!.isValidURL else { return AlertManager.shared.showIncorrectLink() }
        guard !self.startDateTextField.text!.isEmpty && !self.startHourTextField.text!.isEmpty else { return AlertManager.shared.showIncorrectDate() }
        guard (self.endDateTextField.text!.isEmpty && self.endHourTextField.text!.isEmpty) || (!self.endDateTextField.text!.isEmpty && !self.endHourTextField.text!.isEmpty) else {
            return AlertManager.shared.showIncorrectEndDate()
        }
        if !self.endDateTextField.text!.isEmpty && !self.endHourTextField.text!.isEmpty {
            var startDateComponents = DateComponents()
            startDateComponents.day = Calendar.current.component(.day, from: self.startDateTextField.datePickerView.date)
            startDateComponents.month = Calendar.current.component(.month, from: self.startDateTextField.datePickerView.date)
            startDateComponents.year = Calendar.current.component(.year, from: self.startDateTextField.datePickerView.date)
            startDateComponents.hour = Calendar.current.component(.hour, from: self.startHourTextField.datePickerView.date)
            startDateComponents.day = Calendar.current.component(.day, from: self.startHourTextField.datePickerView.date)
            let startDate = Calendar.current.date(from: startDateComponents) ?? Date()
            var endDateComponents = DateComponents()
            endDateComponents.day = Calendar.current.component(.day, from: self.endDateTextField.datePickerView.date)
            endDateComponents.month = Calendar.current.component(.month, from: self.endDateTextField.datePickerView.date)
            endDateComponents.year = Calendar.current.component(.year, from: self.endDateTextField.datePickerView.date)
            endDateComponents.hour = Calendar.current.component(.hour, from: self.endHourTextField.datePickerView.date)
            endDateComponents.day = Calendar.current.component(.day, from: self.endHourTextField.datePickerView.date)
            let endDate = Calendar.current.date(from: endDateComponents) ?? Date()
            guard startDate <= endDate else { return AlertManager.shared.showIncorrectEndDate() }
        }
        
        guard self.priceStackView.isHidden == true || ((self.priceTextField.text!.isEmpty && self.currencyTextField.text!.isEmpty) || (!self.priceTextField.text!.isEmpty && !self.currencyTextField.text!.isEmpty)) else {
            return AlertManager.shared.showNeedPrice()
        }
        if !self.selectedImages.isEmpty {
            sender.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            self.selectedImagesURL.reserveCapacity(self.selectedImages.count)
            self.selectedImagesURL = [URL?](repeating: nil, count: self.selectedImages.count)
            for image in self.selectedImages {
                AWS3Manager.shared.uploadVideo(with: image, index: self.selectedImages.firstIndex(of: image))
            }
        } else {
            sender.isUserInteractionEnabled = true
            self.goToPreview()
        }
    }
    
    private func configureImagePicker() {
        var imagePickerConfiguration = YPImagePickerConfiguration()
        imagePickerConfiguration.showsPhotoFilters = true
        imagePickerConfiguration.library.maxNumberOfItems = 5
        imagePickerConfiguration.library.skipSelectionsGallery = false
        imagePickerConfiguration.screens = [.library, .photo]
        imagePickerConfiguration.library.defaultMultipleSelection = false
        self.YPimagePicker = YPImagePicker(configuration: imagePickerConfiguration)
        self.YPimagePicker?.didFinishPicking(completion: { (items, success) in
            for item in items {
                switch item {
                case .photo(p: let photo):
                    DispatchQueue.main.async {
                        self.selectedImages.append(photo.image)
                    }
                default:
                    break;
                }
            }
            self.YPimagePicker?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func configureImageCollectionViewDataSource() {
        self.addTimenoteDataSource = AddTimenoteDataSource(collectionView: self.pictureCollectionView, cellProvider: { (collectionView, indexPath, image) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as? PictureCell
            if image == UIImage(named: "add") {
                cell?.configure(image: image, delegate: nil)
            } else {
                cell?.configure(image: image, delegate: self)
            }
            return cell
        })
    }
    
    private func changeButtons(isEnabled: Bool) {
        for button in self.colorButtons {
            button.isUserInteractionEnabled = isEnabled
            button.alpha = isEnabled ? 1 : 0.5
            button.borderWidth = isEnabled ? button.borderWidth : 0
        }
        self.colorHex = isEnabled ? self.colorHex : ""
    }
    
    private func updateUI() {
        guard !self.selectedImages.isEmpty else {
            DispatchQueue.main.async {
                self.changeButtons(isEnabled: true)
                self.addImageView.isHidden = false
                self.pictureCollectionView.isHidden = true
                self.colorsStackView.subviews.forEach { $0.isHidden = false }
            }
            return
        }
        DispatchQueue.main.async {
            self.changeButtons(isEnabled: false)
            self.addImageView.isHidden = true
            self.pictureCollectionView.isHidden = false
            self.colorsStackView.subviews.forEach { $0.isHidden = true }
        }
        self.addTimenoteSnapShot = AddTimenoteSnapShot()
        self.addTimenoteSnapShot.appendSections([.main])
        var images = self.selectedImages
        images.append(UIImage(named: "add")!)
        self.addTimenoteSnapShot.appendItems(images)
        self.addTimenoteDataSource.apply(self.addTimenoteSnapShot, animatingDifferences: self.needAnimationUpdate)
        self.needAnimationUpdate = true
    }
    
    // ACTIONS
    
    @IBAction func whenIsTapped(_ sender: UITapGestureRecognizer) {
        self.startDateTextField.becomeFirstResponder()
    }
    
    @IBAction func colorIsTapped(_ sender : UIButton) {
        guard sender.backgroundColor!.htmlRGBColor != self.colorHex else {
            self.colorHex = ""
            sender.borderWidth = 0
            return
        }
        self.colorHex = sender.backgroundColor!.htmlRGBColor
        for button in colorButtons {
            button.borderWidth = button == sender ? 4.0 : 0
        }
    }
    
    @IBAction func imageIsTapped(_ sender: UITapGestureRecognizer?) {
        // NO OPTION TO CANCEL LAST SELECTED PHOTO
        self.configureImagePicker()
        let alertController = UIAlertController(title: Locale.current.isFrench ? "Selectionner les photos" : "Select pictures", message: nil, preferredStyle: .actionSheet)
        let onePicture = UIAlertAction(title: Locale.current.isFrench ? "Choisir les photos" : "Choose pictures", style: .default) { (action) in
            if let imagePicker = self.YPimagePicker {
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let multiplePicture = UIAlertAction(title: Locale.current.isFrench ? "Rechercher sur Internet" : "Search on internet", style: .default) { (action) in
            self.performSegue(withIdentifier: "goToGoogleSearch", sender: self)
        }
        
        let retourAction = UIAlertAction(title: "Retour", style: .cancel, handler: nil)
        retourAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(onePicture)
        alertController.addAction(multiplePicture)
        alertController.addAction(retourAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AddTimenoteViewController : DataPickerTextFieldDelegate {
    
    func didSelectRow(pickerView: UIPickerView, row: Int, component: Int, identifier: String, value: String) {
        DispatchQueue.main.async {
            guard identifier != "categorieTextField" else {
                self.souCategorieTextField.isHidden = value.isEmpty
                self.souCategorieTextField.text = ""
                self.souCategorieTextField.setPickerData(CategorieManager.shared.postCategories.first(where: {$0.category == value})?.subcategory ?? [], self.souCategorieTextField.debugDescription)
                return
            }
            if let shareValue = ShareType(rawValue: value) {
                self.shareType = shareValue
                switch value {
                case Locale.current.isFrench ? "Groupe" : "Group" :
                    self.performSegue(withIdentifier: "goToGroups", sender: self)
                case Locale.current.isFrench ? "Mes amis" : "Friends":
                    self.followingTypeResult = .SHARE
                    self.performSegue(withIdentifier: "goToFollowing", sender: self)
                default:
                    return
                }
            }
            switch value {
            case Locale.current.isFrench ? "Payant" : "Paying":
                self.priceStackView.isHidden = false
            case Locale.current.isFrench ? "Gratuit" : "Free" :
                self.priceStackView.isHidden = true
            case Locale.current.isFrench ? "Pas de réponse" : "Uknown":
                self.priceStackView.isHidden = true
            default:
                return
            }
        }
    }
}

extension AddTimenoteViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag && self.selectedImages.count != destinationIndexPath?.row {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(row: row - 1, section: 0)
        }
        if coordinator.proposal.operation == .move {
            if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
                var newImages = self.selectedImages
                newImages.remove(at: sourceIndexPath.item)
                newImages.insert(item.dragItem.localObject as! UIImage, at: destinationIndexPath.item)
                self.needAnimationUpdate = false
                self.selectedImages = newImages
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.row != self.selectedImages.count else { return [] }
        let item = self.selectedImages[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.selectedImages.count {
            self.imageIsTapped(nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.row == self.selectedImages.count ? CGSize(width: 60, height: 60) : CGSize(width: 100, height: 100)
    }
    
    
}

extension AddTimenoteViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.adresseTextField:
            GoogleLocationManager.shared.presentGoogleAutoComplete(self)
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case self.titleTextField:
            self.descriptionStackView.isHidden = self.titleTextField.text!.isEmpty
        case self.lienTextField:
            self.linkName.isHidden = self.lienTextField.text!.isEmpty
//        case self.startDateTextField:
//            self.view.endEditing(true)
//            self.startHourTextField.becomeFirstResponder()
//        case self.startHourTextField:
//            self.startHourTextField.resignFirstResponder()
        default:
            break
        }
        //let _ = self.handleKeybordReturn(textField)
    }
    
    @objc func handleKeybordReturn(_ textField: UITextField) -> Selector? {
        switch textField {
        case self.titleTextField:
            self.titleTextField.resignFirstResponder()
            if !self.titleTextField.text!.isEmpty {
                self.descriptionTextView.becomeFirstResponder()
            }
        case self.descriptionTextView:
            self.descriptionTextView.resignFirstResponder()
            self.startDateTextField.becomeFirstResponder()
        case self.startDateTextField:
            self.startDateTextField.resignFirstResponder()
            self.startHourTextField.becomeFirstResponder()
        case self.startHourTextField:
            self.startHourTextField.resignFirstResponder()
            self.endDateTextField.becomeFirstResponder()
        case self.endDateTextField:
            self.endDateTextField.resignFirstResponder()
            self.groupShareTextField.becomeFirstResponder()
        case self.groupShareTextField:
            self.groupShareTextField.resignFirstResponder()
            self.categorieTextField.becomeFirstResponder()
        case self.categorieTextField:
            self.categorieTextField.resignFirstResponder()
            if self.categorieTextField.text!.isEmpty {
                self.priceTextField.becomeFirstResponder()
            } else {
                self.souCategorieTextField.becomeFirstResponder()
            }
        case self.souCategorieTextField:
            self.souCategorieTextField.resignFirstResponder()
            self.priceTextField.becomeFirstResponder()
        case self.priceTextField:
            self.priceTextField.resignFirstResponder()
            if self.priceTextField.text!.isEmpty {
                self.lienTextField.becomeFirstResponder()
            } else {
                self.currencyTextField.becomeFirstResponder()
            }
        case self.currencyTextField:
            self.currencyTextField.resignFirstResponder()
            self.lienTextField.becomeFirstResponder()
        case self.lienTextField:
            self.lienTextField.resignFirstResponder()
            if self.lienTextField.text!.isEmpty {
                self.organisateurTextField.becomeFirstResponder()
            } else {
                self.linkName.becomeFirstResponder()
            }
        case self.linkName:
            self.linkName.resignFirstResponder()
            self.organisateurTextField.becomeFirstResponder()
        case self.organisateurTextField:
            self.organisateurTextField.resignFirstResponder()
        default:
            return nil
        }
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let _ = self.handleKeybordReturn(textField)
        return true
    }
    
}

extension AddTimenoteViewController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.adresseTextField.text = GoogleLocationManager.getFullAdresseOf(place)
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

extension AddTimenoteViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
             textView.text = ""
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = AddTimenoteViewController.DescriptionPlaceHolder
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension AddTimenoteViewController : GoogleImageSearchDelegate {
    
    func didSelectImages(images: [GoogleAPISearchItem]) {
        for image in images {
            guard let imageURL = URL(string: image.link) else { continue }
            if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                self.selectedImages.append(image)
            }
        }
    }
}

extension AddTimenoteViewController : DatePickerTextFieldDelegate {
    func didUpdateSelectedDate(_ date: Date, _ dateToString: String, textField: UITextField?) {
        DispatchQueue.main.async {
            self.startDateTextField.alpha = 1
            self.startHourTextField.alpha = 1
            self.endDateTextField.datePickerView.minimumDate = self.startDateTextField.datePickerView.date
            if self.endDateTextField.text?.isEmpty == false && self.endDateTextField.datePickerView.date < self.startDateTextField.datePickerView.date {
                self.endDateTextField.datePickerView.date = self.startDateTextField.datePickerView.date
            }
            if self.endDateTextField.text?.isEmpty == false {
                self.startDateTextField.datePickerView.maximumDate = self.endDateTextField.datePickerView.date
            }
            if self.startDateTextField == textField {
                self.endDateTextField.text = ""
                self.startHourTextField.text = ""
                self.endHourTextField.text = ""
                self.endDateTextField.datePickerView.date = self.startDateTextField.datePickerView.date
                self.endHourTextField.datePickerView.date = self.startDateTextField.datePickerView.date
                self.startHourTextField.datePickerView.date = self.startDateTextField.datePickerView.date
            }
            if self.startHourTextField == textField {
                self.endHourTextField.text = ""
                self.endDateTextField.text = ""
                self.endHourTextField.datePickerView.date = self.startDateTextField.datePickerView.date
                self.endDateTextField.datePickerView.date = self.startDateTextField.datePickerView.date
            }
            self.toDateStackView.isHidden = false
        }
    }
}

extension AddTimenoteViewController : UserGroupDelegate {
    func didSelectGroup(group: GroupSectionDto?) {
        self.groupe = group
        DispatchQueue.main.async {
            self.groupShareTextField.resignFirstResponder()
        }
    }
}

extension AddTimenoteViewController : PreviewDelegate {
    func didPost() {
        self.refreshScreen()
    }
}

extension AddTimenoteViewController : FollowingSelectedDelegate {
    func didSelect(users: [String]) {
        if self.followingTypeResult == .ORGANIZER {
            self.oragnizer = users
            DispatchQueue.main.async {
                self.organisateurTextField.resignFirstResponder()
                self.organisateurTextField.text = "\(self.oragnizer.count) \(Locale.current.isFrench ? "Organisateurs" : "Organizers" )".trimmedText
            }
        } else if self.followingTypeResult == .SHARE {
            self.friends = users
            DispatchQueue.main.async {
                self.groupShareTextField.resignFirstResponder()
            }
        }
    }
}

extension AddTimenoteViewController : PictureCellDelegate {
    func didDelete(image: UIImage) {
        self.selectedImages.removeAll(where: {$0 == image})
        self.updateUI()
    }
}
