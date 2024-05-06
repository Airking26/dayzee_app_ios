//
//  FollowerListViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 02/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

class FollowingListDataSource: UITableViewDiffableDataSource<Section, FollowingListDto>  {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
typealias FollowingListSnapShot = NSDiffableDataSourceSnapshot<Section, FollowingListDto>

struct FollowingListDto : Hashable {
    let user: UserResponseDto
    var selected: Bool
}

protocol FollowingSelectedDelegate {
    func didSelect(users: [String])
}

class FollowingListViewController : UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar! { didSet {
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.delegate = self
    }}
    @IBOutlet weak var followerListTableView: UITableView! { didSet {
        self.followerListTableView.estimatedRowHeight = 90
        self.followerListTableView.rowHeight = UITableView.automaticDimension
        self.followerListTableView.delegate = self
    }}
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    private var followingListDataSource: FollowingListDataSource!
    private var followingListSnapShot: FollowingListSnapShot!
    private var users: [FollowingListDto] = [] { didSet {
        self.updateUI()
    }}
    private var cancellableBag = Set<AnyCancellable>()
    private var selectedUser: UserResponseDto? = nil
    
    public  var selectedUsers: [String]  = []
    public  var delegate: FollowingSelectedDelegate?
    public  var timenoteId: String?
    public  var userId: String? = UserManager.shared.userInformation?.id
    public  var isSharing: Bool = true
    public  var noActions: Bool = false
    public  var isFollwing: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shareButton.setTitle(self.isSharing ? Locale.current.isFrench ? "Partager" : "Share" : Locale.current.isFrench ? "Valider" : "Validate", for: .normal)
        if self.noActions {
            self.shareButton.isHidden = true
            self.titleLabel.text = Locale.current.isFrench ? "Liste des amis" : "Friends list"
        }
        if self.userId != UserManager.shared.userInformation?.id {
            self.searchBarHeight.constant = 0
        }
        self.addSwipeDismissGesture()
        self.configureDataSource()
        getFollowingList()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.selectedUser
            self.selectedUser = nil
        }
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareIsTapped(_ sender: UIButton) {
               guard let timenoteId = self.timenoteId, !self.selectedUsers.isEmpty, self.isSharing else { return self.dismiss(animated: true) { self.delegate?.didSelect(users: self.selectedUsers) }}
        UserManager.shared.shareTimenoteWithUsers(timenoteId: timenoteId, users: self.selectedUsers)
        self.dismiss(animated: true) { self.delegate?.didSelect(users: self.selectedUsers) }
    }
    
    private func addSwipeDismissGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.resignKeyboard))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.followerListTableView.addGestureRecognizer(swipeDown)
    }
    
    @objc public func resignKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    private func getFollowingList() {
        if self.isFollwing {
            UserManager.shared.userFollowingListPublisher.value = []
            UserManager.shared.userFollowingListPublisher.map({$0.map({FollowingListDto(user: $0, selected: self.selectedUsers.firstIndex(of: $0.id) != nil)})}).assign(to: \.self.users, on: self).store(in: &self.cancellableBag)
            UserManager.shared.getFollowingByName(name: nil, userId: self.userId)
        } else {
            UserManager.shared.userFollowersListPublisher.value = []
            UserManager.shared.userFollowersListPublisher.map({$0.map({FollowingListDto(user: $0, selected: self.selectedUsers.firstIndex(of: $0.id) != nil)})}).assign(to: \.self.users, on: self).store(in: &self.cancellableBag)
            UserManager.shared.getFollowersByName(name: nil, userId: self.userId)
        }
    }
    
    private func configureDataSource() {
        self.followingListDataSource = FollowingListDataSource(tableView: self.followerListTableView, cellProvider: { (tableView, indexPath, following) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell") as? FollowingCell
            cell?.configure(following: following, delegate: self, noAction: self.noActions)
            if indexPath.row == self.users.count - 12 {
                if self.isFollwing {
                    UserManager.shared.getFollowingByName(name: self.searchBar.text ?? "", userId: self.userId)
                } else {
                    UserManager.shared.getFollowersByName(name: self.searchBar.text ?? "", userId: self.userId)
                }
            }
            return cell
        })
        self.followingListDataSource.defaultRowAnimation = .fade
    }
    
    private func updateUI() {
        self.followingListSnapShot = FollowingListSnapShot()
        self.followingListSnapShot.appendSections([.main])
        self.followingListSnapShot.appendItems(self.users)
        DispatchQueue.main.async {
            self.followingListDataSource.apply(self.followingListSnapShot, animatingDifferences: true)
        }
    }
    
}

extension FollowingListViewController : FollowingSelectedDelegate {
    
    func didSelect(users: [String]) {
        users.forEach { (userSelected) in
            if let index = self.users.firstIndex(where: {$0.user.id == userSelected}) {
                self.users[index].selected = !self.users[index].selected
                if self.users[index].selected {
                    self.selectedUsers.append(userSelected)
                } else {
                    self.selectedUsers.removeAll(where: {$0 == userSelected})
                }
            }
        }
    }
    
}

extension FollowingListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = self.users[indexPath.row].user
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
}


extension FollowingListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            UserManager.shared.searchUserByName(name: searchText,
                                                offset: users.count) { [weak self] users in
                guard let users = users else { return }
                self?.cancellableBag.removeAll(keepingCapacity: false)
                self?.users = []
                self?.users = users.map{FollowingListDto(user: $0, selected: false)}
            }
        } else {
            getFollowingList()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = self.users[indexPath.row].user
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            if self.isFollwing {
                UserManager.shared.unfollowUser(userId: user.id) { (success) in
                    completion(true)
                }
            } else {
                UserManager.shared.removeFollower(userId: user.id) { (success) in
                    completion(true)
                }
            }
        })
        deleteAction.backgroundColor = .systemBackground
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: self.userId == UserManager.shared.userInformation?.id ? [deleteAction] : [])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isModalInPresentation = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.isModalInPresentation = false
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
        
}
