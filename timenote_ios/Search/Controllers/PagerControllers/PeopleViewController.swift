//
//  PeopleViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 8/3/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias PeapleDataSource  = UITableViewDiffableDataSource<Section, UserResponseDto>
typealias PeapleSnapShot    = NSDiffableDataSourceSnapshot<Section, UserResponseDto>

class PeopleViewController : UITableViewController {
    
    static let ListCellName         : String    = "FollowerXibView"
    
    private var users               : [UserResponseDto]     = [] { didSet {
        self.updatePeapleUI()
    }}
    private var selectedIndexPath   : IndexPath?            = nil
    private var searchBarText       : String                = "" { didSet {
        self.loadUsers(by: 0)
    }}
    
    private var peapleDataSource    : PeapleDataSource!
    private var peapleSnapShot      : PeapleSnapShot!

    private var cancellableBag      : Set<AnyCancellable>   = Set<AnyCancellable>()

    // MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableView.automaticDimension
        self.configurePeapleData()
        SearchViewController.searchBarPublisher.assign(to: \.self.searchBarText, on: self).store(in: &self.cancellableBag)
        self.tableView.register(UINib(nibName: PeopleViewController.ListCellName, bundle: nil), forCellReuseIdentifier: PeopleViewController.ListCellName)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            guard let indexPath = self.selectedIndexPath else { return }
            profilViewController.user = self.users[indexPath.row]
        }
    }

    private func configurePeapleData() {
        self.peapleDataSource = PeapleDataSource(tableView: self.tableView, cellProvider: { (tableView, indexPath, userData) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PeopleViewController.ListCellName) as? FollowerXibView else { return UITableViewCell() }
            cell.configure(follower: userData)
            if indexPath.row == self.users.count - 12 {
                self.didLoadMoreUser()
            }
            return cell
        })
        self.peapleDataSource.defaultRowAnimation = .fade
    }

    private func updatePeapleUI(animated: Bool = true) {
        self.peapleSnapShot = PeapleSnapShot()
        self.peapleSnapShot.appendSections([.main])
        self.peapleSnapShot.appendItems(self.users, toSection: .main)
        self.peapleDataSource.apply(self.peapleSnapShot, animatingDifferences: animated)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }

    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }

    // MARK: Actions

    @objc func didLoadMoreUser() {
        self.loadUsers(by: self.users.count)
    }

    // MARK: Functions

    private func loadUsers(by offset: Int) {
        let usedOffset = offset == 0 ? 0 : offset / 12
        UserManager.shared.searchUserByName(name: self.searchBarText, offset: offset) { (users) in
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SearchViewController.searchResignResponder.send(true)
    }

}
