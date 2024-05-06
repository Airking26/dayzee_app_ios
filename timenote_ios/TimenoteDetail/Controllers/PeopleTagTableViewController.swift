//
//  PeopleTagTableViewController.swift
//  Timenote
//
//  Created by Dev on 9/6/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import UIKit
import Combine

typealias PeopleDataSource = UITableViewDiffableDataSource<Section, UserResponseDto>
typealias PeopleSnapShot = NSDiffableDataSourceSnapshot<Section, UserResponseDto>

protocol PeopleTagDelegate {
    func didSelectUser(user: UserResponseDto)
}

class PeopleTagTableViewController: UITableViewController {
    
    var delegate: PeopleTagDelegate?
    
    private var peopleDataSource: PeopleDataSource!
    private var peopleSnapShot: PeopleSnapShot!
    private var users: [UserResponseDto] = [] { didSet {
        self.updateUI()
    }}
    private var searchText: String? = "" { didSet {
        self.loadUsers(by: 0)
    }}
    
    private var cancellableBag: Set<AnyCancellable>   = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    // MARK: - Private methods
    
    private func initUI() {
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension
        self.configureDataSource()
        self.tableView.register(UINib(nibName: PeopleViewController.ListCellName, bundle: nil), forCellReuseIdentifier: PeopleViewController.ListCellName)
        TimenoteDetailViewController.searchTextPublisher.assign(to: \.self.searchText, on: self).store(in: &self.cancellableBag)
    }
    
    private func updateUI(animated: Bool = true) {
        self.peopleSnapShot = PeopleSnapShot()
        self.peopleSnapShot.appendSections([.main])
        self.peopleSnapShot.appendItems(self.users, toSection: .main)
        self.peopleDataSource.apply(self.peopleSnapShot, animatingDifferences: animated)
    }
    
    private func loadUsers(by offset: Int) {
        let usedOffset = offset == 0 ? 0 : offset / 12
        guard let searchText = self.searchText else { return }
        UserManager.shared.searchUserByName(name: searchText, offset: offset) { (users) in
            guard usedOffset == 0 else {
                var usersMutating = users
                usersMutating?.removeAll(where: {self.users.contains($0)})
                guard let users = usersMutating, !users.isEmpty else { return }
                self.users.append(contentsOf: users)
                return
            }
            var removeUserList = users
            removeUserList?.removeAll(where: {$0.id == UserManager.shared.userInformation?.id})
            self.users = removeUserList ?? []
        }
    }
    
    private func loadMoreUsers() {
        self.loadUsers(by: self.users.count)
    }
    
    // MARK: Table view data source
    
    private func configureDataSource() {
        self.peopleDataSource = PeopleDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, userData) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PeopleViewController.ListCellName) as? FollowerXibView else { return UITableViewCell() }
            cell.configure(follower: userData, hideSubscribeBtn: true)
            if indexPath.row == self.users.count - 12 {
                self.loadMoreUsers()
            }
            return cell
        })
        self.peopleDataSource.defaultRowAnimation = .fade
    }
    
    // MARK: Actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectUser(user: users[indexPath.row])
        self.view.removeFromSuperview()
    }

}
