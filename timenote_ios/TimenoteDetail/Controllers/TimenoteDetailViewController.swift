//
//  TimenoteDetailViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/25/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import NextGrowingTextView
import Combine
import ImageSlideshow
import YPImagePicker
import ActiveLabel

class TimenoteCommentDataSource     : UITableViewDiffableDataSource<Section, TimenoteCommentDto> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
typealias TimenoteCommentSnapShot   = NSDiffableDataSourceSnapshot<Section, TimenoteCommentDto>

class TimenoteDetailViewController : UIViewController {
    
    static let SavedByDesciptionString      : String = Locale.current.isFrench ? "Enregistré par" : "Saved by"
    static let NoSavingByDesciptionString   : String = Locale.current.isFrench ? "Ce dayzee n'a pas encore été enregistré" : "This dayzee has not been saved"
    
    static  let searchTextPublisher = CurrentValueSubject<String?, Never>("")

    @IBOutlet weak var topGradient: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.topGradient.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.55), UIColor.black.withAlphaComponent(0.37), UIColor.clear].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.topGradient.layer.insertSublayer(gradient, at: .zero)
    }}
    @IBOutlet weak var bottonGradient: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.bottonGradient.bounds
        gradient.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.37), UIColor.black.withAlphaComponent(0.55)].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.bottonGradient.layer.insertSublayer(gradient, at: .zero)
    }}
    @IBOutlet weak var linkPrice: UILabel!
    @IBOutlet weak var linkName: OutlinedLabel!
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkViewHeight: NSLayoutConstraint!
    @IBOutlet weak var linkArrow: UIImageView!
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var timenoteHourEndingDate: OutlinedLabel!
    @IBOutlet var separatorDateView: [UIView]!
    @IBOutlet weak var imageUserJoinedThree: UIImageView!
    @IBOutlet weak var imageUserJoinedTwo: UIImageView!
    @IBOutlet weak var imageUserJoinedOne: UIImageView!
    @IBOutlet weak var celendarButton: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var timenoteUserNameLabel: UILabel!
    @IBOutlet weak var timenoteUserImageView: UIImageView!
    @IBOutlet weak var timenoteLocationLabel: UILabel!
    @IBOutlet weak var underLocationSpacerLabel: UILabel!
    @IBOutlet weak var timenoteNameLabel: UILabel!
    @IBOutlet weak var timenoteYearLabel: UILabel!
    @IBOutlet weak var timenoteDayLabel: UILabel!
    @IBOutlet weak var timenoteMonthLabel: UILabel!
    @IBOutlet weak var timenoteTimeLabel: UILabel!
    @IBOutlet weak var timenoteDesciptionLabel: UILabel!
    @IBOutlet weak var certifiedView: UIView!
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        self.scrollView.delegate = self
    }}
    @IBOutlet weak var timenoteLikedDescription: UILabel!
    @IBOutlet weak var pagerControll: UIPageControl!
    @IBOutlet weak var timenoteImageView: ImageSlideshow! { didSet {
        self.timenoteImageView.slideshowInterval = 0
        self.timenoteImageView.delegate = self
        self.timenoteImageView.pageIndicator = nil
        self.timenoteImageView.circular = false
        self.timenoteImageView.contentScaleMode = .scaleAspectFit
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scaleImage(view: self.timenoteImageView)
        }
    }}
    
    @IBOutlet weak var timenoteImageHeight: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!  { didSet {
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: Locale.current.isFrench ? "Ajouter votre commentaire" : "Add a comment", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .light), NSAttributedString.Key.foregroundColor : UIColor.label ])
        self.growingTextView.layer.cornerRadius = 5
        self.growingTextView.textView.delegate = self
    }}
    @IBOutlet weak var UserJoinedImagesStackView: UIStackView!
    @IBOutlet weak var commentTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTableView: UITableView! { didSet {
        self.commentTableView.delegate = self
        self.commentTableView.rowHeight = UITableView.automaticDimension
    }}

    private var timenoteImages      : [URL]                         =  []
    private var YPimagePicker       : YPImagePicker?
    private var commentImage        : UIImage?
    private var commentImagePath    : String?
    public  var forceEditing        : Bool                          = false
    public  var timenote            : TimenoteDataDto?              = nil
    public  var timenoteDelegate    : TimeNoteWithHeaderDelegate?   = nil
    private var dateFormat          : UserDateFormatDto             = UserManager.shared.userInformation?.dateFormat ?? .FIRST
    private var selectedUser        : UserResponseDto?              = nil
    private var timer               : Timer?
    private var selectedTimenote    : TimenoteDataDto?              = nil
    
    private lazy var peopleTagViewController = PeopleTagTableViewController()
    
    private var timenoteComments    : [TimenoteCommentDto]          = [] { didSet {
        self.updateUI()
    }}
    private var commentsDataSource  : TimenoteCommentDataSource!
    private var commentsSnapShot    : TimenoteCommentSnapShot!
    private var tagedUserAtComment  : [String] = []

    private var cancellableBag      = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        TimenoteManager.shared.timenoteCommentsPublisher.value = []
        TimenoteManager.shared.timenoteCommentsPublisher.assign(to: \.self.timenoteComments, on: self).store(in: &self.cancellableBag)
        TimenoteManager.shared.getComments(timenoteId: self.timenote?.id, offset: 0)
        self.setLikedDescription()
        self.setUserInfo()
        self.setTimenoteInfo()
        self.setTimenoteImages()
        self.setFullViewHeight()
        self.addDateTimenoteTapGesutre()
        self.handleKeyboardForComments()
        self.addTimenoteLinkTapGesture()
        self.setImagePicker()
        self.initUI()
        guard self.forceEditing else { return }
        let _ = self.growingTextView.becomeFirstResponder()
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scaleImage(view: self.timenoteImageView)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setFullViewHeight()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.scaleImage(view: self.timenoteImageView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? UserListViewController {
            userListViewController.timenoteId = self.timenote?.id
        }
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.selectedUser
            self.selectedUser = nil
        }
        if let followingListViewController =  (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.timenoteId = self.timenote?.id
        }
        if let addTimenoteViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? AddTimenoteViewController {
            addTimenoteViewController.timenoteSelectedDto = self.selectedTimenote
            addTimenoteViewController.timenoteUpdateId = self.selectedTimenote?.id
            self.selectedTimenote = nil
        }
    }
    
    private func initUI() {
        commentImage != nil ? cameraBtn.setImage(commentImage, for: .normal) : cameraBtn.setImage(UIImage(systemName: "camera"), for: .normal)
    }
    
    private func configureDataSource() {
        self.peopleTagViewController.delegate = self
        
        self.commentsDataSource = TimenoteCommentDataSource(tableView: self.commentTableView, cellProvider: { (tableView, indexPath, commentDto) -> UITableViewCell? in
            
            if commentDto.picture?.isEmpty ?? true {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimenoteCommentCell") as? TimenoteCommentCell else { return UITableViewCell() }
                cell.configure(timenoteComment: commentDto, delegate: self)
                if indexPath.row == self.timenoteComments.count - 12 {
                    TimenoteManager.shared.getComments(timenoteId: self.timenote?.id, offset: self.timenoteComments.count)
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimenoteCommentImageCell") as? TimenoteCommentImageCell else { return UITableViewCell() }
                cell.configure(timenoteComment: commentDto, delegate: self)
                if indexPath.row == self.timenoteComments.count - 12 {
                    TimenoteManager.shared.getComments(timenoteId: self.timenote?.id, offset: self.timenoteComments.count)
                }
                return cell
            }
        })
        self.commentsDataSource.defaultRowAnimation = .fade
    }
    
    private func setImagePicker() {
        var imagePickerConfiguration = YPImagePickerConfiguration()
//        imagePickerConfiguration.showsCrop = .rectangle(ratio: 1)
        imagePickerConfiguration.onlySquareImagesFromCamera = false
        imagePickerConfiguration.showsPhotoFilters = true
        imagePickerConfiguration.shouldSaveNewPicturesToAlbum = false
        imagePickerConfiguration.startOnScreen = YPPickerScreen.photo
        imagePickerConfiguration.screens = [.library, .photo]
        imagePickerConfiguration.library.onlySquare = false
        imagePickerConfiguration.library.isSquareByDefault = false
        imagePickerConfiguration.library.defaultMultipleSelection = false
        imagePickerConfiguration.library.maxNumberOfItems = 1
        imagePickerConfiguration.library.minNumberOfItems = 1
        self.YPimagePicker = YPImagePicker(configuration: imagePickerConfiguration)
        self.YPimagePicker?.didFinishPicking(completion: { [weak self] (items, success) in
            if let image = items.singlePhoto?.image {
                self?.commentImage = image
                DispatchQueue.main.async {
                    self?.initUI()
                    AWS3Manager.shared.uploadVideo(with: image, isProfil: true) { imagePath in
                        self?.commentImagePath = imagePath
                    }
                }
            }
            self?.YPimagePicker?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func userProfilIsTapped(_ sender: UITapGestureRecognizer) {
        guard let user = self.timenote?.createdBy, user.id != UserManager.shared.userInformation?.id  else { return }
        self.selectedUser = user
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    
    @IBAction func linkIsTapped(_ sender: UIButton) {
        if var urlString = self.timenote?.url {
            if !urlString.starts(with: "http") {
                if urlString.starts(with: "www") {
                    urlString = "https://\(urlString)"
                } else {
                    urlString = "https://www.\(urlString)"
                }
            }
            if let url = URL(string: urlString)  {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func updateUI() {
        self.commentsSnapShot = TimenoteCommentSnapShot()
        self.commentsSnapShot.appendSections([.main])
        self.commentsSnapShot.appendItems(self.timenoteComments)
        DispatchQueue.main.async {
            self.commentsDataSource.apply(self.commentsSnapShot, animatingDifferences: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.commentTableView.reloadData()
            self.commentTableViewHeight.constant = self.commentTableView.contentSize.height
        }
    }
    
    private func addTimenoteLinkTapGesture() {
        self.linkViewHeight.constant = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateLink))
        self.timenoteImageView.isUserInteractionEnabled = true
        self.timenoteImageView.addGestureRecognizer(tapGesture)
        
        let tapGestureLink = UITapGestureRecognizer(target: self, action: #selector(self.linkIsTapped))
        tapGestureLink.numberOfTapsRequired = 1
        self.linkView.isUserInteractionEnabled = true
        self.linkView.addGestureRecognizer(tapGestureLink)
        
        let doubletapGesture = UITapGestureRecognizer(target: self, action: #selector(self.callSave))
        doubletapGesture.numberOfTapsRequired = 2
        self.timenoteImageView.isUserInteractionEnabled = true
        self.timenoteImageView.addGestureRecognizer(doubletapGesture)
        tapGesture.require(toFail: doubletapGesture)
    }
    
    @objc public func callSave() {
        self.addIsTapped(sender: self.celendarButton)
    }
    
    @objc public func updateLink() {
        let link = self.timenote?.url
        let price = self.timenote?.price
        if link != nil || price?.value != 0.0 {
            self.linkViewHeight.constant = self.linkViewHeight.constant == 0 ? 40 : 0
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func handleKeyboardForComments() {
        NotificationCenter.default.addObserver(self, selector: #selector(TimenoteDetailViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TimenoteDetailViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc public func hideKeyboardOnSwipe() {
        DispatchQueue.main.async {
            self.growingTextView.textView.endEditing(true)
        }
    }

    @objc func keyboardWillHide(_ sender: Notification) {
      if let userInfo = (sender as NSNotification).userInfo {
        if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
          self.inputContainerViewBottom.constant =  0
          UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
        }
      }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
      if let userInfo = (sender as NSNotification).userInfo {
        if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
          self.inputContainerViewBottom.constant = keyboardHeight
          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
          })
        }
      }
    }
    
    private func scaleImage(view: ImageSlideshow) {
        guard let image = view.slideshowItems.first?.imageView.image else { return }
        let ratio = image.size.width / image.size.height
        let newHeight = view.frame.width / ratio
        if newHeight < 700 && newHeight > 230 {
            self.timenoteImageHeight.constant = newHeight
            self.timenoteImageView.contentScaleMode = .scaleAspectFill
        } else {
            self.timenoteImageHeight.constant = 230
            self.timenoteImageView.contentScaleMode = .scaleAspectFill
        }
    }
    
    private func setFullViewHeight() {
        self.commentTableView.reloadData()
        self.commentTableViewHeight.constant = self.commentTableView.contentSize.height
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    
    private func addPanGestureToLikedDescription() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSavedUserList(_:)))
        self.timenoteLikedDescription.isUserInteractionEnabled = true
        self.timenoteLikedDescription.addGestureRecognizer(tapGesture)
    }

    @objc func showSavedUserList(_ sender: UITapGestureRecognizer) {
        guard let joinedBy = self.timenote?.joinedBy, joinedBy.total != 0 else { return }
        self.timenoteDelegate?.didTapUserListTimenote(timenote: self.timenote)
        self.performSegue(withIdentifier: "goToUserList", sender: self)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
        }, completion: nil)
    }
    
    @IBAction func timenoteShareIsTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }
    
    @IBAction func timenoteCommentIsTapped(_ sender: UIButton) {
        self.timenoteDelegate?.didCommentTimenote(timenote: self.timenote)
        let _ = self.growingTextView.becomeFirstResponder()
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timenoteAddIsTapped(_ sender: UIButton) {
        self.addIsTapped(sender: sender)
    }
    
    @objc func addIsTapped(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        if self.timenote?.participating == true {
            TimenoteManager.shared.leaveTimenote(timenoteId: self.timenote?.id) { (success) in
                sender.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self.celendarButton.isSelected = !success
                }
                self.timenote?.participating = !success
            }
        } else {
            TimenoteManager.shared.joinTimenote(timenoteId: self.timenote?.id) { (success) in
                sender.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self.celendarButton.isSelected = success
                }
                self.timenote?.participating = success
            }
        }
    }
    
    @IBAction func publishIsTapped(_ sender: UIButton) {
        guard self.growingTextView.textView.text.trimmedText.isEmpty == false ||  self.commentImagePath?.isEmpty == false else { return }
        TimenoteManager.shared.commentTimenote(timenoteId: self.timenote?.id, description: self.growingTextView.textView.text, hastags: "", image: commentImagePath, taggedUserNames: self.tagedUserAtComment)
        self.commentImage = nil
        self.commentImagePath = nil
        self.initUI()
        DispatchQueue.main.async { [weak self] in
            self?.growingTextView.textView.text = ""
            self?.growingTextView.resignFirstResponder()
            self?.tagedUserAtComment = []
        }
    }
    
    @IBAction func pictureIsTapped(_ sender: UIButton) {
        if let imagePicker = self.YPimagePicker {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func setUserInfo() {
        self.timenoteUserNameLabel.text = self.timenote?.createdBy.userName
        self.timenoteLocationLabel.isHidden = self.timenote?.location == nil
        self.underLocationSpacerLabel.isHidden = self.timenote?.location == nil
        self.timenoteLocationLabel.text = self.timenote?.location?.address.address
        self.certifiedView.isHidden = !(self.timenote?.createdBy.certified ?? false)
        if let urlString = self.timenote?.createdBy.picture, let url = URL(string: urlString) {
            self.timenoteUserImageView.sd_setImage(with: url)
        } else {
            self.timenoteUserImageView.image = UIImage(named: "profile_icon")
        }
    }
    
    private func addDateTimenoteTapGesutre() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.changeDateFormat))
        self.dateStackView.isUserInteractionEnabled = true
        self.dateStackView.addGestureRecognizer(tapGesture)
    }
    
    @objc public func changeDateFormat() {
        self.dateFormat = self.dateFormat == .FIRST ? .SECOND : .FIRST
        DispatchQueue.main.async {
            self.setTimenoteInfo()
        }
    }
    
    @objc func updateDateTimer() {
        DispatchQueue.main.async {
            self.separatorDateView.forEach({$0.isHidden = true})
            self.timenoteYearLabel.isHidden = true
            self.timenoteHourEndingDate.isHidden = true
            self.timenoteDayLabel.isHidden = true
            self.timenoteMonthLabel.isHidden = false
            self.timenoteTimeLabel.isHidden = true
            self.timenoteMonthLabel.text = self.timenote?.startingDate?.timeAgoDisplay()
        }
    }
    
    private func setTimenoteInfo() {
        self.timenoteNameLabel.text = self.timenote?.title.uppercased()
        self.celendarButton.isSelected = self.timenote?.participating ?? false || UserManager.shared.userInformation?.id == self.timenote?.createdBy.id
        self.timer?.invalidate()
        self.linkName.text = self.timenote?.urlTitle == nil || self.timenote?.urlTitle?.isEmpty == true ? (Locale.current.isFrench ? "En savoir plus" : "Find out more") : self.timenote?.urlTitle
        self.linkName.alpha = self.timenote?.url == nil ? 0.0 : 1.0
        self.linkArrow.isHidden = self.timenote?.url == nil
        let timenoteStringValue = self.timenote?.price?.value == nil ? "" : "\(self.timenote!.price!.value)"
        self.linkPrice.isHidden = (self.timenote?.price == nil || self.timenote?.price?.value == 0)
        self.linkPrice.text = "\(timenoteStringValue)\(self.timenote?.price?.currency ?? "")"
        guard self.dateFormat == .FIRST else {
            guard let startDate = self.timenote?.startingDate, !((startDate < Date()) && (Date() < self.timenote?.endingDate ?? Date())) else {
                self.separatorDateView.forEach({$0.isHidden = true})
                self.timenoteYearLabel.isHidden = true
                self.timenoteHourEndingDate.isHidden = true
                self.timenoteDayLabel.isHidden = true
                self.timenoteMonthLabel.isHidden = false
                self.timenoteTimeLabel.isHidden = true
                self.timenoteMonthLabel.text = "LIVE 🔴"
                self.setTimenoteDescription()
                return
            }
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDateTimer), userInfo: nil, repeats: true)
            self.separatorDateView.forEach({$0.isHidden = true})
            self.timenoteYearLabel.isHidden = true
            self.timenoteDayLabel.isHidden = true
            self.timenoteHourEndingDate.isHidden = true
            self.timenoteMonthLabel.isHidden = false
            self.timenoteTimeLabel.isHidden = true
            self.timenoteMonthLabel.text = startDate.timeAgoDisplay()
            self.setTimenoteDescription()
            return
        }
        self.separatorDateView.forEach({$0.isHidden = false})
        self.timenoteYearLabel.isHidden = false
        self.timenoteDayLabel.isHidden = false
        self.timenoteMonthLabel.isHidden = false
        self.timenoteTimeLabel.isHidden = false
        let hasEndingDate = self.timenote?.endingAt.isEmpty == false && self.timenote?.endingDate != nil && self.timenote?.endingAt != self.timenote?.startingAt
        self.timenoteYearLabel.text = self.timenote?.startingDate?.getYear()
        self.timenoteDayLabel.text = !hasEndingDate ? self.timenote?.startingDate?.getDay() : "\(self.timenote?.startingDate?.getDay() ?? "") \(self.timenote?.startingDate?.getMonthNameString() ?? "")"
        self.timenoteMonthLabel.text = !hasEndingDate ? self.timenote?.startingDate?.getMonthNameString() : self.timenote?.startingDate?.getHour()
        self.timenoteTimeLabel.text = !hasEndingDate ? self.timenote?.startingDate?.getHour() :"\(self.timenote?.endingDate?.getDay() ?? "") \(self.timenote?.endingDate?.getMonthNameString() ?? "")"
        self.timenoteHourEndingDate.isHidden = !hasEndingDate
        self.timenoteHourEndingDate.text = self.timenote?.endingDate?.getHour()
        self.setTimenoteDescription()
    }
    
    private func setTimenoteImages() {
        if let pictures = self.timenote?.pictures, !pictures.isEmpty {
            var timenoteImages : [SDWebImageSource] = []
            self.timenote?.pictures.forEach({if let sdImage = SDWebImageSource(urlString: $0) { timenoteImages.append(sdImage) } })
            self.timenoteImageView.setImageInputs(timenoteImages)
            self.setPagerNumberItems(numberItems: timenoteImages.count)
        } else if let hex = self.timenote?.colorHex {
            self.timenoteImageView.setImageInputs([ImageSource(image: UIImage(color: UIColor(hex: hex) ?? .white)!)])
            self.setPagerNumberItems(numberItems: 0)
        }
    }
    
    private func setPagerNumberItems(numberItems: Int) {
        self.pagerControll.isHidden = numberItems <= 1
        self.pagerControll.currentPage = 0
        self.pagerControll.numberOfPages = numberItems
    }
    
    private func setLikedDescription() {
        self.timenoteLikedDescription.text = ""
        self.UserJoinedImagesStackView.isHidden = true
        guard let joinedBy = self.timenote?.joinedBy, joinedBy.total != 0 else {
            self.UserJoinedImagesStackView.isHidden = true
            let mutableAttributedString = NSMutableAttributedString(string: TimenoteDetailViewController.NoSavingByDesciptionString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular)])
            self.timenoteLikedDescription.attributedText = mutableAttributedString
            return
        }
        if let firstFriend = self.timenote?.joinedBy?.friends.first {
            self.UserJoinedImagesStackView.isHidden = false
            let mutableAttributedString = NSMutableAttributedString(string: TimenoteWithHeaderXibView.SavedByDesciptionString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .light)])
            let addedAttributedString = NSAttributedString(string: " " + "\(firstFriend.userName.trimmedText) \((joinedBy.total - (!joinedBy.friends.isEmpty ? 1 : 0)) != 0 ? Locale.current.isFrench ? "et" : "and" : "") \(joinedBy.totalString)".condenseWhitespace(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular)])
            mutableAttributedString.append(addedAttributedString)
            self.timenoteLikedDescription.attributedText = mutableAttributedString
            if let urlString = firstFriend.picture, let url = URL(string: urlString) {
                self.imageUserJoinedOne.isHidden = false
                self.imageUserJoinedOne.sd_setImage(with: url)
            } else { self.imageUserJoinedOne.isHidden = true }
            if self.timenote?.joinedBy?.friends.count ?? 0 >= 2, let secondFriend = self.timenote?.joinedBy?.friends[1] ,let urlString = secondFriend.picture, let url = URL(string: urlString) {
                self.imageUserJoinedTwo.isHidden = false
                self.imageUserJoinedTwo.sd_setImage(with: url)
            } else { self.imageUserJoinedTwo.isHidden = true }
            if self.timenote?.joinedBy?.friends.count ?? 0 >= 3, let secondFriend = self.timenote?.joinedBy?.friends[2] ,let urlString = secondFriend.picture, let url = URL(string: urlString) {
                self.imageUserJoinedThree.isHidden = false
                self.imageUserJoinedThree.sd_setImage(with: url)
            } else { self.imageUserJoinedThree.isHidden = true }
        } else {
            let mutableAttributedString = NSMutableAttributedString(string: "\(TimenoteWithHeaderXibView.SavedByDesciptionString)\(joinedBy.totalString)".condenseWhitespace(), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .light)])
            self.timenoteLikedDescription.attributedText = mutableAttributedString
        }
        self.addPanGestureToLikedDescription()
    }
    
    private func setTimenoteDescription() {
        self.timenoteDesciptionLabel.isHidden = false
        guard let descriptionFull = self.timenote?.descript, !descriptionFull.isEmpty else {
            self.timenoteDesciptionLabel.isHidden = true
            return
        }
        let descript = descriptionFull.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
        let addedAttributedString = NSAttributedString(string: "\(self.timenote?.createdBy.userName.trimmedText ?? "") \(descript)", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 14)!])
        self.timenoteDesciptionLabel.attributedText = addedAttributedString
        let mutableAttributedString = NSMutableAttributedString(attributedString: self.timenoteDesciptionLabel.attributedText!)
        let userNameAttributedString = NSAttributedString(string: "\(self.timenote?.createdBy.userName.trimmedText ?? "") ", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 14)!])
        mutableAttributedString.replaceCharacters(in: NSRange(location: 0, length: userNameAttributedString.length), with: userNameAttributedString)
        let allHastags = mutableAttributedString.string.split(separator: "#").map({$0.components(separatedBy: CharacterSet.alphanumerics.inverted)[0]}).map({String($0)})
        for hastag in allHastags {
            if let range = mutableAttributedString.string.distance(of: "#\(hastag)") {
                mutableAttributedString.replaceCharacters(in: NSRange(location: range, length: hastag.count + 1), with: NSAttributedString(string: "#\(hastag)", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 14)!]))
            }
        }
        self.timenoteDesciptionLabel.attributedText = mutableAttributedString
    }
    
    
    @IBAction func timenoteMoreIsTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: Locale.current.isFrench ? "Posté \(self.timenote?.createdDate?.timeAgoDisplay() ?? "1 jour")" : "Posted  \(self.timenote?.createdDate?.timeAgoDisplay() ?? "1 day ago")", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Dupliquer le Dayzee" : "Duplicate this Dayzee", style: .default, handler: { (alertAction) in
            TimenoteManager.shared.timenoteLastDuplicate.send(self.timenote)
            self.timenoteDelegate?.didDuplicateTimenote(timenote: self.timenote)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }))
        if self.timenote?.createdBy.id == UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Supprimer le Dayzee" : "Delete this Dayzee", style: .default, handler: { (alertAction) in
                TimenoteManager.shared.deleteTimenote(timenoteId: self.timenote?.id, completion: { success in
                    guard success else { return }
                    self.dismiss(animated: true, completion: nil)
                })
                self.timenoteDelegate?.didDeleteTimenote(timenote: self.timenote)
            }))
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Modifier" : "Edit", style: .default, handler: { (alertAction) in
                self.selectedTimenote = self.timenote
                self.performSegue(withIdentifier: "editTimenote", sender: self)
            }))
        }
        if self.timenote?.createdBy.id != UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Signaler le Dayzee" : "Report this Dayzee", style: .default, handler: { (alertAction) in
                AlertManager.shared.showRepoAlert { alert in
                    self.present(alert, animated: true, completion: nil)
                } alertAction: { signalDescription in
                    TimenoteManager.shared.signalTimenote(timenodId: self.timenote?.id, userId: self.timenote?.createdBy.id, description: signalDescription)
                    self.timenoteDelegate?.didReportTimenote(timenote: self.timenote)
                }
            }))
            let hidePostTitle = Locale.current.isFrench ? "Masquer cet évènement" : "Hide this event"
            alert.addAction(UIAlertAction(title: hidePostTitle, style: .default, handler: { [weak self] action in
                TimenoteManager.shared.hideTimenote(timenoteId: self?.timenote?.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.timenoteDelegate?.reloadAllData()
                }
            }))
            let hideAllEventsTitle = Locale.current.isFrench ? "Masquer tous les évènements de cet utilisateur" : "Hide all events from this user"
            alert.addAction(UIAlertAction(title: hideAllEventsTitle, style: .default, handler: { [weak self] action in
                TimenoteManager.shared.hideAllTimenotesFromUser(userId: self?.timenote?.createdBy.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.timenoteDelegate?.reloadAllData()
                }
            }))
        }
        
        let userName = UserManager.shared.userInformation?.userName ?? "User"
        let eventName = self.timenote?.title ?? ""
        let dateOfEvent = self.timenote?.startingDate?.getShortDare() ?? "-"
        let hourOfEvent = self.timenote?.startingDate?.getHour() ?? "-"
        var url = ""
        guard let timenote = self.timenote else { return }
        WebService.shared.setupBranchLink(timenote: timenote) { link in
            url = link
        }
        
        alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Partager" : "Share", style: .default, handler: { (alertAction) in
            self.present(UIActivityViewController(activityItems: ["\(userName) invite you to: \(eventName) the \(dateOfEvent) at \(hourOfEvent) \n\(url)"], applicationActivities: nil), animated: true)
        }))
        let cancelAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension TimenoteDetailViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.growingTextView.textView.endEditing(true)
    }
        
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let comment = self.timenoteComments[indexPath.row]
        guard comment.createdBy.id == UserManager.shared.userInformation?.id || self.timenote?.createdBy.id == UserManager.shared.userInformation?.id else { return UISwipeActionsConfiguration() }
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            let alert = UIAlertController(title: Locale.current.isFrench ? "Êtes vous sûr de vouloir supprimer votre commentaire ?" : "Are you sure you want to delete your comment ?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Supprimer" : "Delete", style: .default, handler: { (alertAction) in
                TimenoteManager.shared.deleteComment(commentId: comment.id)
            }))
            let cancelAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        })
        deleteAction.backgroundColor = .systemBackground
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        return  UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

extension TimenoteDetailViewController : ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        self.pagerControll.currentPage = page
    }
}

extension TimenoteDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isModalInPresentation = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.isModalInPresentation = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let vc = self.peopleTagViewController
        // Get text after `@` to search.
        if let _ = textView.text.range(of: "@") {
            let printedWords = textView.text.components(separatedBy: " ")
            guard let userName = printedWords.last else { return }
            if userName[0].contains("@") {
                // Show list of searched peoples.
                vc.view.frame = scrollView.frame
                self.view.addSubview(vc.view)
                let username = userName.replacingOccurrences(of: "@", with: "")
                TimenoteDetailViewController.searchTextPublisher.send(username)
            } else {
                // Hide search list.
                TimenoteDetailViewController.searchTextPublisher.send(nil)
                self.peopleTagViewController.view.removeFromSuperview()
            }
        } else {
            self.peopleTagViewController.view.removeFromSuperview()
        }
    }
    
}

extension TimenoteDetailViewController : CommentSelectedUserDelegate {
    func didTapUser(user: UserResponseDto?) {
        self.selectedUser = user
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func didTapPicture(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = view.bounds
        newImageView.backgroundColor = .lightGray
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(newImageView)
        }, completion: nil)
    }
    
    func didTapUserTag(userTag: String) {
        UserManager.shared.searchUserByName(name: userTag, offset: 0) { [weak self] users in
            users?.forEach {
                if $0.userName == userTag {
                    self?.selectedUser = $0
                    self?.performSegue(withIdentifier: "goToProfil", sender: self)
                }
            }
        }
    }
    
    func beginUpdates() {
        commentTableView.beginUpdates()
    }
    
    func endUpdates() {
        commentTableView.endUpdates()
    }
    
}

extension TimenoteDetailViewController: PeopleTagDelegate {
    
    func didSelectUser(user: UserResponseDto) {
        var printedWords = self.growingTextView.textView.text.components(separatedBy: " ")
        printedWords.removeLast()
        printedWords.append("@\(user.userName)")
        var textToShow = ""
        printedWords.forEach {
            textToShow.append("\($0) ")
        }
        self.growingTextView.textView.text = textToShow
        self.tagedUserAtComment.append(user.id)
    }
    
}
