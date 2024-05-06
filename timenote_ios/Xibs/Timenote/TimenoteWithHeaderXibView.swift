//
//  TimenoteWithHeaderXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/5/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import ImageSlideshow
import SkeletonView
import UIKit
import ActiveLabel
import Branch

protocol TimeNoteWithHeaderDelegate {
    func showTimenoteModalViewController(viewController: UIViewController)
    func didDuplicateTimenote(timenote: TimenoteDataDto?)
    func didDeleteTimenote(timenote: TimenoteDataDto?)
    func didTapUserListTimenote(timenote: TimenoteDataDto?)
    func didRemindTimenote(timenote: TimenoteDataDto?)
    func didReportTimenote(timenote: TimenoteDataDto?)
    func didCommentTimenote(timenote: TimenoteDataDto?)
    func didShowMoreTimenote(timenote: TimenoteDataDto?)
    func didShareTimenote(timenote: TimenoteDataDto?)
    func didShowTaggedPeaple(timenote: TimenoteDataDto?)
    func didTapUserIcon(timenote: UserResponseDto?)
    /**
     Reloads all timenotes data in the app.
     
     Used to refresh all saved events, when user hide one of them.
     */
    func reloadAllData()
}

extension TimeNoteWithHeaderDelegate {
    func reloadAllData() {}
}

class TimenoteWithHeaderXibView : UITableViewCell {

    static let SavedByDesciptionString      : String = Locale.current.isFrench ? "Enregistré par" : "Saved by"
    static let NoSavingByDesciptionString   : String = Locale.current.isFrench ? "Ce dayzee n'a pas encore été enregistré" : "This dayzee has not been saved"

    @IBOutlet weak var viewGradientBotton: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.viewGradientBotton.bounds
        gradient.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.37), UIColor.black.withAlphaComponent(0.55)].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.viewGradientBotton.layer.insertSublayer(gradient, at: .zero)
    }}
    @IBOutlet weak var viewGradient: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.viewGradient.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.55), UIColor.black.withAlphaComponent(0.37), UIColor.clear].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.viewGradient.layer.insertSublayer(gradient, at: .zero)
    }}
    @IBOutlet weak var linkView: UIView!
    @IBOutlet weak var linkPrice: OutlinedLabel!
    @IBOutlet weak var linkName: OutlinedLabel!
    @IBOutlet weak var linkViewHeight: NSLayoutConstraint!
    @IBOutlet weak var linkArrow: UIImageView!
    @IBOutlet var separatorDateView: [UIView]!
    @IBOutlet weak var timenoteHourEndingDate: OutlinedLabel!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var timenoteUserAdresseLabel: UILabel!
    @IBOutlet weak var timenoteUserNameLabel: UILabel!
    @IBOutlet weak var timenoteUserImageView: UIImageView!
    @IBOutlet weak var timenoteNameLabel: PaddingLabel!
    @IBOutlet weak var timenoteYearLabel: UILabel!
    @IBOutlet weak var timenoteDayLabel: UILabel!
    @IBOutlet weak var timenoteMonthLabel: UILabel!
    @IBOutlet weak var timenoteTimeLabel: UILabel!
    @IBOutlet weak var timenoteDesciptionLabel: ActiveLabel!
    @IBOutlet weak var pagerControll: UIPageControl!
    @IBOutlet weak var timenoteLikedDescription: UILabel!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var timenoteDetailView: UIView!
    @IBOutlet weak var timenoteDateStackView: UIStackView!
    @IBOutlet weak var imageUserJoinedOne: UIImageView!
    @IBOutlet weak var imageUserJoinedTwo: UIImageView!
    @IBOutlet weak var imageUserJoinedThree: UIImageView!
    @IBOutlet weak var UserJoinedImagesStackView: UIStackView!
    @IBOutlet weak var certifiedView: UIView!
    @IBOutlet weak var timenoteImageHeight: NSLayoutConstraint!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var timenoteImageView: ImageSlideshow! { didSet {
        self.timenoteImageView.slideshowInterval = 0
        self.timenoteImageView.delegate = self
        self.timenoteImageView.pageIndicator = nil
        self.timenoteImageView.circular = false
        self.timenoteImageView.contentScaleMode = .scaleAspectFit
    }}

    private var timer               : Timer?
    public  var timenoteDelegate    : TimeNoteWithHeaderDelegate?   = nil
    private var timenoteImages      : [URL]                         =  []
    public  var timenote            : TimenoteDataDto?              = nil
    private var dateFormat          : UserDateFormatDto             = UserManager.shared.userInformation?.dateFormat ?? .FIRST

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setPastFuturDesign()
        self.addPanGestureToDescription()
    }

    func configure(timenote: TimenoteDataDto) {
        self.timenote = timenote
        self.dateFormat = UserManager.shared.userInformation?.dateFormat ?? .FIRST
        self.selectionStyle = .none
        self.setUserInfo()
        self.setTimenoteInfo()
        self.setLikedDescription()
        self.setTimenoteImages()
        self.addDateTimenoteTapGesutre()
        self.addTimenoteLinkTapGesture()
        self.addTapAdresseGesture()
        self.addPanGestureToLikedDescription()
        self.addTapUserIconGesture()
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    
    override func prepareForReuse() {
        self.timenoteUserAdresseLabel.isHidden = true
        self.certifiedView.isHidden = true
    }

    private func addTapUserIconGesture() {
        self.timenoteUserImageView.isUserInteractionEnabled = true
        self.timenoteUserNameLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.userIconIsTapped))
        self.timenoteUserImageView.addGestureRecognizer(tapGesture)
        let tapGestureName = UITapGestureRecognizer(target: self, action: #selector(self.userIconIsTapped))
        self.timenoteUserNameLabel.addGestureRecognizer(tapGestureName)
    }

    @objc func userIconIsTapped() {
        self.timenoteDelegate?.didTapUserIcon(timenote: self.timenote?.createdBy)
    }

    private func addTapAdresseGesture() {
        self.timenoteUserAdresseLabel.isUserInteractionEnabled = false
        guard let location = self.timenote?.location, !location.address.address.isEmpty else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addresseIsTapped))
        self.timenoteUserAdresseLabel.isUserInteractionEnabled = true
        self.timenoteUserAdresseLabel.addGestureRecognizer(tapGesture)
    }

    @objc func addresseIsTapped() {
        guard let location = self.timenote?.location else { return }
        var filterOption = TimenoteManager.shared.timenoteNearbyOptionPublisher.value
        filterOption?.location = location
        filterOption?.date = self.timenote?.startingDate?.iso8601withFractionalSeconds ?? Date().iso8601withFractionalSeconds
        filterOption?.maxDistance = 5
        TimenoteManager.shared.timenoteNearbyOptionPublisher.send(filterOption)
    }

    private func setUserInfo() {
        DispatchQueue.main.async {
            self.timenoteUserNameLabel.text = self.timenote?.createdBy.userName
            self.timenoteUserAdresseLabel.text = self.timenote?.location?.address.address
            self.timenoteUserAdresseLabel.isHidden = self.timenote?.location?.address.address.isEmpty ?? true
            self.certifiedView.isHidden = !(self.timenote?.createdBy.certified ?? false)
            if let urlString = self.timenote?.createdBy.picture, let url = URL(string: urlString) {
                self.timenoteUserImageView.sd_setImage(with: url) { (image, error, cache, url) in
                    //self.timenoteUserImageView.hideSkeleton()
                }
            } else {
                self.timenoteUserImageView.image = UIImage(named: "profile_icon")
            }
        }
    }

    private func addTimenoteLinkTapGesture() {
        self.linkViewHeight.constant = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateLink))
        tapGesture.numberOfTapsRequired = 1
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
        self.addIsTapped(sender: self.calendarButton)
    }

    @objc public func updateLink() {
        let link = self.timenote?.url
        let price = self.timenote?.price
        if link != nil || price?.value != 0.0 {
            let tableView = self.superview as? UITableView
            tableView?.beginUpdates()
            self.linkViewHeight.constant = self.linkViewHeight.constant == 0 ? 40 : 0
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
                tableView?.endUpdates()
            }
        }
    }

    @objc public func linkIsTapped() {
        if var urlString = self.timenote?.url {
            urlString = WebService.shared.normalizeUrl(urlString: urlString)
            if let url = URL(string: urlString)  {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    private func addDateTimenoteTapGesutre() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.changeDateFormat))
        let commentLabelTap = UITapGestureRecognizer(target: self, action: #selector(self.commentLabelTapped(_:)))
        self.timenoteDateStackView.isUserInteractionEnabled = true
        self.timenoteDateStackView.addGestureRecognizer(tapGesture)
        self.commentsLabel.addGestureRecognizer(commentLabelTap)
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
        self.calendarButton.isSelected = self.timenote?.participating == true || UserManager.shared.userInformation?.id == self.timenote?.createdBy.id
        self.timer?.invalidate()
        self.linkName.text = self.timenote?.urlTitle == nil || self.timenote?.urlTitle?.isEmpty == true ? (Locale.current.isFrench ? "En savoir plus" : "Find out more") : self.timenote?.urlTitle
        self.linkName.alpha = self.timenote?.url == nil ? 0.0 : 1.0
        self.linkArrow.isHidden = self.timenote?.url == nil
        let timenoteStringValue = self.timenote?.price?.value == nil ? "" : "\(self.timenote!.price!.value)"
        self.linkPrice.isHidden = (self.timenote?.price == nil || self.timenote?.price?.value == 0)
        self.linkPrice.text = "\(timenoteStringValue)\(self.timenote?.price?.currency ?? "")"
        self.commentsLabel.isHidden = !(self.timenote?.comments ?? 0 > 0)
        let commentDescriptionFirst = "See the".localized + " \(self.timenote?.comments ?? 0) " + "comments".localized
        let commentDescriptionSecond = "See the comment".localized
        self.commentsLabel.text = (self.timenote?.comments ?? 1 > 1) ? commentDescriptionFirst : commentDescriptionSecond
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
            self.timenoteHourEndingDate.isHidden = true
            self.timenoteDayLabel.isHidden = true
            self.timenoteMonthLabel.isHidden = false
            self.timenoteTimeLabel.isHidden = true
            self.timenoteMonthLabel.text = self.timenote?.startingDate?.timeAgoDisplay()
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
            guard pictures != self.timenoteImageView.images.map({$0 as? SDWebImageSource}).map({$0?.url.absoluteString}) else { return }
            var timenoteImages : [SDWebImageSource] = []
            self.timenoteImageView.showAnimatedGradientSkeleton()
            pictures.forEach({if let sdImage = SDWebImageSource(urlString: $0, completion: { (success) in
                DispatchQueue.main.async {
                    self.timenoteImageView.hideSkeleton()
                    self.scaleImage(view: self.timenoteImageView)
                }
            }) { timenoteImages.append(sdImage) } })
            self.timenoteImageView.setImageInputs(timenoteImages)
            self.setPagerNumberItems(numberItems: timenoteImages.count)
            self.scaleImage(view: self.timenoteImageView)
        } else if let hex = self.timenote?.colorHex {
            self.timenoteImageView.setImageInputs([ImageSource(image: UIImage(color: UIColor(hex: hex) ?? .white)!)])
            self.setPagerNumberItems(numberItems: 0)
            self.scaleImage(view: self.timenoteImageView)
        } else {
            self.timenoteImageView.setImageInputs([ImageSource(image: UIImage(color: .white)!)])
            self.scaleImage(view: self.timenoteImageView)
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

    private func setPastFuturDesign() {
        self.calendarButton.setImage(UIImage(named: "Ajout cal"), for: .normal)
    }

    private func addPanGestureToLikedDescription() {
        self.timenoteLikedDescription.gestureRecognizers = []
        self.timenoteLikedDescription.isUserInteractionEnabled = false
        guard self.timenote?.joinedBy?.total != 0 else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSavedUserList(_:)))
        self.timenoteLikedDescription.isUserInteractionEnabled = true
        self.timenoteLikedDescription.addGestureRecognizer(tapGesture)
    }

    @objc func showSavedUserList(_ sender: UITapGestureRecognizer) {
        self.timenoteDelegate?.didTapUserListTimenote(timenote: self.timenote)
    }

    private func addPanGestureToDescription() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapDescription(_:)))
        self.timenoteDesciptionLabel.isUserInteractionEnabled = true
        self.timenoteDesciptionLabel.addGestureRecognizer(tapGesture)
    }

    @objc func didTapDescription(_ sender: UITapGestureRecognizer) {
        self.timenoteDelegate?.didShowMoreTimenote(timenote: self.timenote)
    }

    public func setPagerNumberItems(numberItems: Int) {
        self.pagerControll.isHidden = numberItems <= 1
        self.pagerControll.currentPage = 0
        self.pagerControll.numberOfPages = numberItems
    }

    private func setLikedDescription() {
        self.UserJoinedImagesStackView.isHidden = true
        guard let joinedBy = self.timenote?.joinedBy, joinedBy.total > 0 else {
            let mutableAttributedString = NSMutableAttributedString(string: TimenoteWithHeaderXibView.NoSavingByDesciptionString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .light)])
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
    }

    private func setTimenoteDescription() {
        self.timenoteDesciptionLabel.text = ""
        self.timenoteDesciptionLabel.isHidden = false
        guard let descriptionFull = self.timenote?.descript, !descriptionFull.isEmpty else {
            let addedAttributedString = NSAttributedString(string: Locale.current.isFrench ? "Voir plus..." : "See more...", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 14)!])
            self.timenoteDesciptionLabel.attributedText = addedAttributedString
            return
        }
        let description = descriptionFull.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
        let addedAttributedString = NSAttributedString(string: "\(self.timenote?.createdBy.userName.trimmedText ?? "") \(description)", attributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Light", size: 14)!])
        self.timenoteDesciptionLabel.font = UIFont(name: "HelveticaNeue", size: 14)!
        self.timenoteDesciptionLabel.attributedText = addedAttributedString
        self.timenoteDesciptionLabel.addNextIfTruncated()
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
    
// MARK: - Actions
    @IBAction func timenoteShareIsTapped(_ sender: UIButton) {
        self.timenoteDelegate?.didShareTimenote(timenote: self.timenote)
    }

    @IBAction func timenoteCommentIsTapped(_ sender: UIButton) {
        self.timenoteDelegate?.didCommentTimenote(timenote: self.timenote)
    }

    // MARK: TODO PRIVATE CHECK
    @IBAction func timenoteAddIsTapped(_ sender: UIButton) {
        self.addIsTapped(sender: sender)
    }
    
    @objc func commentLabelTapped(_ sender: UILabel) {
        self.timenoteDelegate?.didShowMoreTimenote(timenote: self.timenote)
    }

    @objc func addIsTapped(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        if self.timenote?.participating == true {
            TimenoteManager.shared.leaveTimenote(timenoteId: self.timenote?.id) { (success) in
                sender.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self.calendarButton.isSelected = !success
                }
                self.timenote?.participating = !success
            }
        } else {
            TimenoteManager.shared.joinTimenote(timenoteId: self.timenote?.id) { (success) in
                sender.isUserInteractionEnabled = true
                DispatchQueue.main.async {
                    self.calendarButton.isSelected = success
                }
                self.timenote?.participating = success
            }
        }
    }

    @IBAction func timenoteMoreIsTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: Locale.current.isFrench ? "Posté \(self.timenote?.createdDate?.timeAgoDisplay() ?? "1 jour")" : "Posted  \(self.timenote?.createdDate?.timeAgoDisplay() ?? "1 day ago")", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Dupliquer ce Dayzee" : "Duplicate this Dayzee", style: .default, handler: { (alertAction) in
            TimenoteManager.shared.timenoteLastDuplicate.send(self.timenote)
            self.timenoteDelegate?.didDuplicateTimenote(timenote: self.timenote)
        }))
        if self.timenote?.createdBy.id == UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Supprimer le Dayzee" : "Delete this Dayzee", style: .default, handler: { (alertAction) in
                TimenoteManager.shared.deleteTimenote(timenoteId: self.timenote?.id, completion: { success in })
                self.timenoteDelegate?.didDeleteTimenote(timenote: self.timenote)
            }))
        }
        if self.timenote?.createdBy.id != UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Signaler le Dayzee" : "Report this Dayzee", style: .default, handler: { (alertAction) in
                AlertManager.shared.showRepoAlert { alert in
                    self.timenoteDelegate?.showTimenoteModalViewController(viewController: alert)
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
            self.timenoteDelegate?.showTimenoteModalViewController(viewController: UIActivityViewController(activityItems: ["\(userName) invite you to: \(eventName) the \(dateOfEvent) at \(hourOfEvent) \n\(url)"], applicationActivities: nil))
        }))
        let cancelAction = UIAlertAction(title: Locale.current.isFrench ? "Retour" : "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        self.timenoteDelegate?.showTimenoteModalViewController(viewController: alert)
    }
}

extension TimenoteWithHeaderXibView : ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        self.pagerControll.currentPage = page
    }
}
