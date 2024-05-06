//
//  ProfileVC.swift
//  timenote_ios
//
//  Created by Moshe Assaban on 5/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import UIKit
import Combine

enum ProfilFilter : Int {
    case MINE   = 1
    case JOINED = 2
    case ALARM  = 3
    case SHARED = 4
}

class ProfilDataSource: UITableViewDiffableDataSource<Section, TimenoteDataDto> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

struct ProfilTimenote : Hashable {
    let userId      : String
    let timenotes   : [TimenoteDataDto]
}

typealias ProfilSnapShot = NSDiffableDataSourceSnapshot<Section, TimenoteDataDto>

class ProfileViewController: UIViewController {

    //MARK: IBOUTLET

    @IBOutlet var optionButtons: [UIButton]!
    @IBOutlet weak var followersStaticLabel: UILabel!
    @IBOutlet weak var followingsStaticLabel: UILabel!
    @IBOutlet weak var stackViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var followerStackView: UIStackView!
    @IBOutlet weak var bottomTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var futurView: UIView!
    @IBOutlet weak var pastView: UIView! { didSet {
        self.pastView.alpha = 0
    }}
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelUserLocation: UILabel!
    @IBOutlet weak var labelNumberFollowers: UILabel!
    @IBOutlet weak var labelNumberFollowings: UILabel!
    @IBOutlet weak var labelStatusUser: UILabel!
    @IBOutlet weak var timenoteTableView: UITableView! { didSet {
        self.timenoteTableView.delegate = self
    }}
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var calnderDayLabel: UILabel!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var calendarDayNameLabel: UILabel!
    @IBOutlet weak var scrollViewHeightConstant: NSLayoutConstraint! { didSet {
        self.scrollViewHeight = self.scrollViewHeightConstant.constant
        }
    }
    @IBOutlet weak var sharedOrLinkButton: UIButton!

    @IBOutlet weak var logoIconRSHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoIconRSWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var futurButton: UIButton! { didSet {
        self.futurButton.isSelected = true
    }}
    @IBOutlet weak var pastButton: UIButton!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var certifiedView: UIView!
    @IBOutlet weak var nothingPlanedLabel: UILabel!

    //MARK: VARIABLES

    static let ListMinCellName  : String    = "TimenoteMinXibView"
    static let ListCellName     : String    = "TimenoteXibView"

    public  var forceShow       : Bool              = false
    public  var user            : UserResponseDto?  = nil { didSet {
        guard self.isViewLoaded else { return }
        self.configureView()
    }}
    private var isMinListForm   : Bool              = false
    private var today           : Date              = Date()
    private var scrollViewHeight: CGFloat           = 0
    private var feedSection     : FeedSection       = .FUTURE
    private var isFollwing      : Bool              = true
    private var userId          : String            = ""

    private var cancellableBag  = Set<AnyCancellable>()
    private var dataSource      : ProfilDataSource!
    private var snapShot        : ProfilSnapShot!
    private var selectedTimenote: TimenoteDataDto?
    private var timenoteFutur   : [TimenoteDataDto] = [] { didSet {
        self.updateUI()
    }}
    private var timenotePast    : [TimenoteDataDto] = [] { didSet {
        self.updateUI()
    }}
    private var timenotePreviewValueFutur : [TimenoteDataDto] = [] { didSet {
        guard self.userId == TimenoteManager.shared.futurUserId else { return }
        self.timenoteFutur = self.timenotePreviewValueFutur
    }}
    private var timenotePreviewValuePast  : [TimenoteDataDto] = [] { didSet {
        guard self.userId == TimenoteManager.shared.pastUserId else { return }
        self.timenotePast = self.timenotePreviewValuePast
    }}
    private var timenoteProfilFilter        : FilterProfileDto          = FilterProfileDto(upcoming: true, alarm: false, created: false, joined: false, sharedWith: false)
    private var timenoteDetailSelected      : TimenoteDataDto?          = nil

    //MARK: OVERRIDE

    override func viewDidLoad() {
        super.viewDidLoad()
        TimenoteManager.shared.getAlarm()
        self.userId = self.user?.id ?? UserManager.shared.userInformation?.id ?? ""
        self.timenoteTableView.register(UINib(nibName: ProfileViewController.ListMinCellName, bundle: nil), forCellReuseIdentifier: ProfileViewController.ListMinCellName)
        self.timenoteTableView.register(UINib(nibName: ProfileViewController.ListCellName, bundle: nil), forCellReuseIdentifier: ProfileViewController.ListCellName)
        self.configureDataSource()
        TimenoteManager.shared.getUserPastTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id)
        TimenoteManager.shared.getUserFuturTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id)
        TimenoteManager.shared.timenotePastUserPublisher.assign(to: \.self.timenotePreviewValuePast, on: self).store(in: &self.cancellableBag)
        TimenoteManager.shared.timenoteFutureUserPublisher.assign(to: \.self.timenotePreviewValueFutur, on: self).store(in: &self.cancellableBag)
        if self.user == nil {
            UserManager.shared.userInformationPublisher.assign(to: \.self.user, on: self).store(in: &self.cancellableBag)
            let _ = TimenoteManager.shared.newTimenotePublisher.sink { [weak self] (timenote) in
                guard let timenote = timenote else { return }
                self?.timenoteDetailSelected = timenote
                self?.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
            }.store(in: &self.cancellableBag)
            UserManager.shared.getUserInfo()
        } else {
            self.bottomTableViewHeight.constant = 10
            self.configureView()
            UserManager.shared.getUser(userId: self.user?.id) { [weak self] (user) in
                DispatchQueue.main.async {
                    self?.user = user
                    self?.userId = self?.user?.id ?? UserManager.shared.userInformation?.id ?? ""
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        
        if isShowingUserProfil {
            WebService.shared.isUnreadNotifications { [weak self] isUnread in
                isUnread ?
                    (self?.notificationButton.setImage(#imageLiteral(resourceName: "Notification Jaune"), for: .normal)) : (self?.notificationButton.setImage(#imageLiteral(resourceName: "Notification"), for: .normal))
            }
            DispatchQueue.main.async {
                WebService.shared.getNotifications(offset: 0) { notifications in
                    APNsManager.shared.handleReceivedNotifications(notifications: notifications)
                }
            }
        }
        
        if !(self.user?.isInFollowers ?? false) && !isShowingUserProfil {
           UserManager.shared.isWaitApproval(userId: self.user?.id) { [weak self] result in
            if !result { return }
            self?.setupFollowButton(title: Locale.current.isFrench ? "En attente" : "Pending", isTapped: true)
           }
       }
    }

    @IBAction func followersIsTapped(_ sender: Any) {
        self.isFollwing = false
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }

    @IBAction func follwingIsTapped(_ sender: Any) {
        self.isFollwing = true
        self.performSegue(withIdentifier: "goFollowingList", sender: self)
    }

    @objc func refreshDate() {
        self.reloadData()
    }
    
    private func reloadData() {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        if isShowingUserProfil  {
            TimenoteManager.shared.getFilteredTimenote(filterData: self.timenoteProfilFilter, refresh: true)
        } else {
            self.feedSection == .FUTURE ? TimenoteManager.shared.getUserFuturTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id) : TimenoteManager.shared.getUserPastTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id)
        }
        updateUI()
    }
    
    private func reloadAllData() {
        self.reloadData()
        TimenoteManager.shared.getUpcoming(refresh: true)
        TimenoteManager.shared.getRecent(refresh: true)
        TimenoteManager.shared.getPast(refresh: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviguationController = segue.destination as? UINavigationController, let timenoteDetailViewController = naviguationController.viewControllers.first as? TimenoteDetailViewController {
            timenoteDetailViewController.timenote = self.timenoteDetailSelected
            self.timenoteDetailSelected = nil
        }
        if let calendarViewController = segue.destination as? CalendarViewController {
            if let userId = self.user?.id {
                calendarViewController.userId = userId
            }
        }
        if let followingListViewController =  (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.noActions = true
            followingListViewController.isFollwing = self.isFollwing
            if let userId = self.user?.id {
                followingListViewController.userId = userId
            }
        }
        if let addTimenoteViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? AddTimenoteViewController {
            addTimenoteViewController.timenoteSelectedDto = self.timenoteDetailSelected
            addTimenoteViewController.timenoteUpdateId = self.timenoteDetailSelected?.id
            self.timenoteDetailSelected = nil
        }
        if let editProfilViewController = segue.destination as? EditProfileViewController {
            editProfilViewController.user = self.user
        }
        if let addTimenoteViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? AddTimenoteViewController {
            addTimenoteViewController.timenoteSelectedDto = self.selectedTimenote
            addTimenoteViewController.timenoteUpdateId = self.selectedTimenote?.id
            self.selectedTimenote = nil
        }
        if let profileManagerViewController = segue.destination as? ProfileManagementViewController {
            profileManagerViewController.configurationViewDelegate = self
        }
    }


    private func configureView() {
        DispatchQueue.main.async { [weak self] in
            self?.configureDate()
            self?.closeScrollView()
            self?.fillUserInfo()
        }
    }

    //MARK: IBACTIONS

    private func updateFilters(filterOption: ProfilFilter?) {
        guard let filterOption = filterOption else { return }
        switch filterOption {
        case .ALARM:
            self.timenoteProfilFilter.alarm = !self.timenoteProfilFilter.alarm
            break;
        case .JOINED:
            self.timenoteProfilFilter.joined = !self.timenoteProfilFilter.joined
            break;
        case .MINE:
            self.timenoteProfilFilter.created = !self.timenoteProfilFilter.created
            break;
        case .SHARED:
            self.timenoteProfilFilter.sharedWith = !self.timenoteProfilFilter.sharedWith
            break;
        }
        TimenoteManager.shared.getFilteredTimenote(filterData: self.timenoteProfilFilter)
    }

    @IBAction func filterOptionIsTapped(_ sender: UIButton) {
        let filterOption = ProfilFilter(rawValue: sender.tag)
        DispatchQueue.main.async {
            self.optionButtons.forEach({$0.borderColor = .black; $0.setTitleColor(.black, for: .normal)})
            sender.borderColor = sender.borderColor == UIColor.black ? .lightGray : .black
            sender.setTitleColor(sender.titleLabel?.textColor == UIColor.label ? .lightGray : .label, for: .normal)
        }
        self.updateFilters(filterOption: filterOption)
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToProfileManager", sender: self)
    }

    private func configureDataSource() {
        self.dataSource = ProfilDataSource(tableView: self.timenoteTableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewController.ListMinCellName) as? TimenoteMinXibView
            cell?.delegate = self
            cell?.configure(timenote: timenote)
            if indexPath.row == (self.feedSection == .FUTURE ? self.timenoteFutur : self.timenotePast).count - 12 {
                if self.feedSection == .PAST {
                    TimenoteManager.shared.getUserPastTimenote(userId: self.userId)
                } else {
                    TimenoteManager.shared.getUserFuturTimenote(userId: self.userId)
                }
            }
            return cell
        })
        self.dataSource.defaultRowAnimation = .fade
    }

    private func updateUI() {
        self.snapShot = ProfilSnapShot()
        self.snapShot.appendSections([.main])
        self.snapShot.appendItems(self.feedSection == .FUTURE ? self.timenoteFutur : self.timenotePast)
        self.dataSource.apply(self.snapShot, animatingDifferences: true)
        self.nothingPlanedLabel.isHidden = self.feedSection == .FUTURE ? (!self.timenoteFutur.isEmpty) : (!self.timenotePast.isEmpty)
    }

    @IBAction func followIsTapped(_ sender: UIButton) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id
        guard !isShowingUserProfil else { return }
        sender.isUserInteractionEnabled = false
        if self.user?.isInFollowers == false {
            if self.user?.status == .PRIVATE {
                UserManager.shared.askFollowUser(userId: self.user?.id) { (success) in
                    if success {
                        AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Votre demande à été envoyé" : "You'r request has been sent", desciption: "", isBlue: true)
                        let followBtnTitle = Locale.current.isFrench ? "En attente" : "Pending"
                        self.setupFollowButton(title: followBtnTitle, isTapped: true)
                    } else {
                        AlertManager.shared.showErrorWithTilteAndDesciption(title: Locale.current.isFrench ? "Vous avez déjà envoyé une demande à cet utilisateur" : "You already have requested this user", desciption: "", isBlue: true)
                    }
                    sender.isUserInteractionEnabled = true
                }
            } else {
                UserManager.shared.followUser(userId: self.user?.id) { (user) in
                    sender.isUserInteractionEnabled = true
                    self.user = user
                    DispatchQueue.main.async {
                        self.followButton.isHidden = UserManager.shared.userInformation?.id == self.user?.id
                        self.followButton.setTitle(self.user?.isInFollowers == true ? Locale.current.isFrench ? "Se désabonner" : "Unfollow" : Locale.current.isFrench ? "S'abonner" : "Follow", for: .normal)
                        self.followButton.setTitleColor(self.user?.isInFollowers == true ? .gray : .white, for: .normal)
                        self.followButton.backgroundColor = self.user?.isInFollowers == true ? .clear : .systemYellow
                        self.followButton.borderColor =  self.user?.isInFollowers == true ? .gray : .systemYellow
                    }
                }
            }
        } else {
            UserManager.shared.unfollowUser(userId: self.user?.id) { (success) in
                sender.isUserInteractionEnabled = true
                self.user?.isInFollowers = !success
                DispatchQueue.main.async {
                    self.followButton.setTitle(success == false ? Locale.current.isFrench ? "Se désabonner" : "Unfollow" : Locale.current.isFrench ? "S'abonner" : "Follow", for: .normal)
                    self.followButton.setTitleColor(success == false ? .gray : .white, for: .normal)
                    self.followButton.backgroundColor = success == false ? .clear : .systemYellow
                    self.followButton.borderColor = success == false ? .gray : .systemYellow
                }

            }
        }
    }

    @IBAction func locationIsTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Localisation", message: nil, preferredStyle: .actionSheet)
               alert.addAction(UIAlertAction(title: "Pas de localisation", style: .default, handler: { (alertAction) in
               }))
               alert.addAction(UIAlertAction(title: "Ville", style: .default, handler: { (alertAction) in
               }))
               alert.addAction(UIAlertAction(title: "Adresse", style: .default, handler: { (alertAction) in
               }))
               alert.addAction(UIAlertAction(title: "Retour", style: .cancel, handler: nil))
               self.present(alert, animated: true, completion: nil)
    }

    @IBAction func futurIsTapped(_ sender: UIButton) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        guard !sender.isSelected else {
            guard isShowingUserProfil else { return }
            self.scrollViewHeightConstant.constant = self.scrollViewHeightConstant.constant == 0.0 ? self.scrollViewHeight : 0.0
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
            }
            return
        }
        self.scrollViewHeightConstant.constant = 0
        self.feedSection = .FUTURE
        self.pastView.alpha = 0
        self.futurView.alpha = 1
        self.timenoteProfilFilter.upcoming = true
        self.updateUI()
        if isShowingUserProfil {
            TimenoteManager.shared.getFilteredTimenote(filterData: self.timenoteProfilFilter, refresh: true)
        }
        self.futurButton.isSelected = true
        self.pastButton.isSelected = false
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func pastIsTapped(_ sender: UIButton) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        guard !sender.isSelected else {
            guard isShowingUserProfil else { return }
            self.scrollViewHeightConstant.constant = self.scrollViewHeightConstant.constant == 0.0 ? self.scrollViewHeight : 0.0
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
            }
            return
        }
        self.scrollViewHeightConstant.constant = 0
        self.feedSection = .PAST
        self.timenoteProfilFilter.upcoming = false
        self.pastView.alpha = 1
        self.futurView.alpha = 0
        self.updateUI()
        if isShowingUserProfil {
            TimenoteManager.shared.getFilteredTimenote(filterData: self.timenoteProfilFilter, refresh: true)
        }
        self.futurButton.isSelected = false
        self.pastButton.isSelected = true
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }

    //MARK: Private Func

    private func fillUserInfo() {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        self.labelUserName.text = self.user?.fullName
        self.certifiedView.isHidden = !(self.user?.certified ?? false)
        if let location = self.user?.location {
            self.labelUserLocation.text = location.address.address
        } else {
            self.locationStackView.isHidden = true
        }
        self.labelNumberFollowers.text = "\(self.user?.followers ?? 0)"
        self.followersStaticLabel.text = "\(Locale.current.isFrench ? "Abonné" : "Follower")\(self.user?.followers ?? 0 > 1 ? "s" : "")"
        self.labelNumberFollowings.text = "\(self.user?.following ?? 0)"
        self.followingsStaticLabel.text = "\(Locale.current.isFrench ? "Abonnement" : "Following")\(self.user?.following ?? 0 > 1 ? "s" : "")"
        let givenName = self.user?.givenName != nil ? "\(self.user!.givenName!)\n" : ""
        self.labelStatusUser.text = "\(givenName)\(self.user?.descript ?? "")"
        self.modifyButton.isHidden = !isShowingUserProfil
        self.followButton.isHidden = isShowingUserProfil
        if let urlString = self.user?.picture, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                self.userImage.sd_setImage(with: url)
            }
        }
        self.followButton.setTitle(self.user?.isInFollowers == true ? Locale.current.isFrench ? "Se désabonner" : "Unfollow" : Locale.current.isFrench ? "S'abonner" : "Follow", for: .normal)
        self.followButton.setTitleColor(self.user?.isInFollowers == true ? .gray : .white, for: .normal)
        self.followButton.backgroundColor = self.user?.isInFollowers == true ? .clear : .systemYellow
        self.followButton.borderColor = self.user?.isInFollowers == true ? .gray : .systemYellow
        self.settingButton.isHidden = !isShowingUserProfil
        self.notificationButton.setImage(isShowingUserProfil ? UIImage(named: "Notification") : UIImage(systemName: "chevron.left"), for: .normal)
        self.headerViewHeight.constant = isShowingUserProfil ? 100 : 70
        self.stackViewYConstraint.constant = isShowingUserProfil ? 15 : 0
        self.calendarButton.isUserInteractionEnabled = self.user?.status != .PRIVATE || isShowingUserProfil
        self.followingStackView.isUserInteractionEnabled = self.user?.status != .PRIVATE || isShowingUserProfil
        self.followerStackView.isUserInteractionEnabled = self.user?.status != .PRIVATE || isShowingUserProfil
        self.sharedOrLinkButton.isUserInteractionEnabled = self.user?.status != .PRIVATE || isShowingUserProfil
        self.privateView.isHidden = self.user?.status != .PRIVATE || isShowingUserProfil
        self.user?.isInFollowers ?? false ? (self.privateView.isHidden = true) : ()
        self.logoIconRSHeightConstraint.constant = 35
        self.logoIconRSWidthConstraint.constant = 35
        if !isShowingUserProfil {
            if let _ = self.user?.socialMedias.firstEnable {
                self.sharedOrLinkButton.setImage(UIImage(named: self.user?.socialMedias.firstEnableImage ?? ""), for: .normal)
                self.logoIconRSHeightConstraint.constant = 30
                self.logoIconRSWidthConstraint.constant = 30
            } else {
                self.sharedOrLinkButton.setImage(UIImage(systemName: "person"), for: .normal)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    private func setupFollowButton(title: String, isTapped: Bool) {
        self.followButton.setTitle(title, for: .normal)
        self.followButton.setTitleColor(isTapped ? .gray : .white, for: .normal)
        self.followButton.backgroundColor = isTapped ? .clear : .systemYellow
        self.followButton.borderColor = isTapped ? .gray : .systemYellow
    }

    @IBAction func sharedOrLinkIsTapped(_ sender: Any) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        if !isShowingUserProfil {
            if var link = self.user?.socialMedias.firstEnable?.url {
                if !link.starts(with: "http") {
                    if link.starts(with: "www") {
                        link = "https://\(link)"
                    } else {
                        link = "https://www.\(link)"
                    }
                }
                if let url = URL(string: link)  {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                self.performSegue(withIdentifier: "goToEdit", sender: self)
            }
        } else {
            self.present(UIActivityViewController(activityItems: ["com.Dayzee://user?userId=\(UserManager.shared.userInformation?.id ?? "")"], applicationActivities: nil), animated: true)
        }
    }

    private func configureDate() {
        self.calnderDayLabel.text = self.today.getDay()
        self.calendarDayNameLabel.text = self.today.getDayString().substring(toIndex: 3)
    }

    private func closeScrollView() {
        self.scrollViewHeightConstant.constant = 0
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func notificationOrBackIsTapped(_ sender: UIButton) {
        let isShowingUserProfil = UserManager.shared.userInformation?.id == self.user?.id && !self.forceShow
        guard isShowingUserProfil else {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        self.performSegue(withIdentifier: "goToNotification", sender: self)
    }

}

// MARK: TableView

extension ProfileViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timenote = (self.feedSection == .FUTURE ? self.timenoteFutur : self.timenotePast)[indexPath.row]
        self.timenoteDetailSelected = timenote
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let timenote = self.feedSection == .FUTURE ? self.timenoteFutur[indexPath.row] : self.timenotePast[indexPath.row]
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            if timenote.createdBy.id == UserManager.shared.userInformation?.id {
                TimenoteManager.shared.deleteTimenote(timenoteId: timenote.id, completion: { success in })
            } else {
                TimenoteManager.shared.leaveTimenote(timenoteId: timenote.id, completion: { success in
                    if let indexFutur = self.timenoteFutur.firstIndex(where: {$0.id == timenote.id}) {
                        self.timenoteFutur.remove(at: indexFutur)
                    }
                    if let indexPast = self.timenotePast.firstIndex(where: {$0.id == timenote.id}) {
                        self.timenotePast.remove(at: indexPast)
                    }
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                })
            }
            completion(true)
        })
        deleteAction.backgroundColor = .systemBackground
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)

        let editAction = UIContextualAction(style: .normal, title: "", handler: { (action, view, completion) in
            self.timenoteDetailSelected = timenote
            self.performSegue(withIdentifier: "modifiyTimenote", sender: self)
        })
        editAction.backgroundColor = .systemBackground
        editAction.image = UIImage(systemName: "pencil")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: timenote.createdBy.id == UserManager.shared.userInformation?.id ? [deleteAction, editAction] : [deleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let timenote = self.feedSection == .FUTURE ? self.timenoteFutur[indexPath.row] : self.timenotePast[indexPath.row]
        let duplicateAction = UIContextualAction(style: .normal, title: "", handler: { (action, view, completion) in
            TimenoteManager.shared.timenoteLastDuplicate.send(timenote)
            completion(true)
        })
        duplicateAction.backgroundColor = .systemBackground
        duplicateAction.image = UIImage(systemName: "doc.on.doc")?.withTintColor(.label, renderingMode: .alwaysOriginal)

        let remindAction = UIContextualAction(style: .normal, title: "", handler: { (action, view, completion) in
            if TimenoteManager.shared.hasAlarm(timenoteId: timenote.id) {
                TimenoteManager.shared.deleteAlarm(timenoteId: timenote.id)
                DispatchQueue.main.async {
                    action.image = UIImage(systemName: "bell")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                    completion(true)
                }
            } else {
                TimenoteManager.shared.createAlarm(timenodId: timenote.id, userId: timenote.createdBy.id, date: timenote.startingDate) { (success) in
                    guard success else { return }
                    DispatchQueue.main.async {
                        action.image = UIImage(systemName:"bell.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                        completion(true)
                    }
                }
            }
        })
        remindAction.backgroundColor = .systemBackground
        remindAction.image = UIImage(systemName: TimenoteManager.shared.hasAlarm(timenoteId: timenote.id) ? "bell.fill" : "bell")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        guard let date = timenote.startingDate else { return UISwipeActionsConfiguration(actions: [duplicateAction]) }
        guard date > Date() else { return UISwipeActionsConfiguration(actions: [duplicateAction]) }
        return  UISwipeActionsConfiguration(actions: [duplicateAction, remindAction])
    }

}

extension ProfileViewController: ConfigurationViewDelegate, TimenoteMinXibViewDelegate {
    
    func reloadTimenotes() {
        cancellableBag.removeAll()
        TimenoteManager.shared.reset()
        
        TimenoteManager.shared.getUserPastTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id, showAlert: true)
        TimenoteManager.shared.getUserFuturTimenote(userId: self.user?.id ?? UserManager.shared.userInformation?.id, showAlert: true)
        TimenoteManager.shared.timenotePastUserPublisher.assign(to: \.self.timenotePreviewValuePast, on: self).store(in: &self.cancellableBag)
        TimenoteManager.shared.timenoteFutureUserPublisher.assign(to: \.self.timenotePreviewValueFutur, on: self).store(in: &self.cancellableBag)
    }
    
    func timenoteMoreIsTapped(_ sender: UIButton, timenote: TimenoteDataDto) {
        let alert = UIAlertController(title: Locale.current.isFrench ? "Posté \(timenote.createdDate?.timeAgoDisplay() ?? "1 jour")" : "Posted  \(timenote.createdDate?.timeAgoDisplay() ?? "1 day ago")", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Dupliquer le Dayzee" : "Duplicate this Dayzee", style: .default, handler: { (alertAction) in
            TimenoteManager.shared.timenoteLastDuplicate.send(timenote)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }))
        if timenote.createdBy.id == UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Supprimer le Dayzee" : "Delete this Dayzee", style: .default, handler: { (alertAction) in
                TimenoteManager.shared.deleteTimenote(timenoteId: timenote.id, completion: { success in
                    guard success else { return }
                    self.dismiss(animated: true, completion: nil)
                })
            }))
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Modifier" : "Edit", style: .default, handler: { (alertAction) in
                self.selectedTimenote = timenote
                self.performSegue(withIdentifier: "modifiyTimenote", sender: self)
            }))
        }
        if timenote.createdBy.id != UserManager.shared.userInformation?.id {
            alert.addAction(UIAlertAction(title: Locale.current.isFrench ? "Signaler le Dayzee" : "Report this Dayzee", style: .default, handler: { (alertAction) in
                AlertManager.shared.showRepoAlert { alert in
                    self.present(alert, animated: true, completion: nil)
                } alertAction: { signalDescription in
                    TimenoteManager.shared.signalTimenote(timenodId: timenote.id, userId: timenote.createdBy.id, description: signalDescription)
                }

            }))
            let hidePostTitle = Locale.current.isFrench ? "Masquer cet évènement" : "Hide this event"
            alert.addAction(UIAlertAction(title: hidePostTitle, style: .default, handler: { [weak self] action in
                TimenoteManager.shared.hideTimenote(timenoteId: timenote.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.reloadAllData()
                }
            }))
            let hideAllEventsTitle = Locale.current.isFrench ? "Masquer tous les évènements de cet utilisateur" : "Hide all events from this user"
            alert.addAction(UIAlertAction(title: hideAllEventsTitle, style: .default, handler: { [weak self] action in
                TimenoteManager.shared.hideAllTimenotesFromUser(userId: timenote.createdBy.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.reloadAllData()
                }
            }))
        }
        let userName = UserManager.shared.userInformation?.userName ?? "User"
        let eventName = timenote.title
        let dateOfEvent = timenote.startingDate?.getShortDare() ?? "-"
        let hourOfEvent = timenote.startingDate?.getHour() ?? "-"
        var url = ""
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
