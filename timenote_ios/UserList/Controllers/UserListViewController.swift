//
//  UserListViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 8/24/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias UserListDataSource    = UITableViewDiffableDataSource<Section, UserResponseDto>
typealias UserListSnapShot      = NSDiffableDataSourceSnapshot<Section, UserResponseDto>

class UserListViewController : UIViewController {
    
    static let ListCellName     : String    = "FollowerXibView"
    
    private var userListDataSource  : UserListDataSource!
    private var userListSnapShot    : UserListSnapShot!
    public  var users               : [UserResponseDto] = [] { didSet {
        self.updateUI()
    }}
    public  var categorie           : CategorieDto?
    public  var timenoteId          : String?
    private var selectedUser        : UserResponseDto?  = nil
    private var cancellableBag      = Set<AnyCancellable>()
    
    @IBOutlet weak var titleListLabel: UILabel!
    @IBOutlet weak var userListTableView: UITableView! { didSet {
        self.userListTableView.delegate = self
        self.userListTableView.rowHeight = UITableView.automaticDimension
        self.userListTableView.estimatedRowHeight = 90
        self.userListTableView.register(UINib(nibName: UserListViewController.ListCellName, bundle: nil), forCellReuseIdentifier: UserListViewController.ListCellName)

    }}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.selectedUser
        }
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTitle()
        self.configureDataSource()
        if self.timenoteId != nil {
            TimenoteManager.shared.timenoteParticipantPublisher.value = []
        }
        self.loadMore()
    }
    
    private func configureTitle() {
        if let categorie = self.categorie {
            self.titleListLabel.text = categorie.subcategory
        }
    }
    
    @objc public func loadMore() {
        let offset = self.users.count
        if let categorie = self.categorie {
            CategorieManager.shared.getUsersCategorie(categorie: categorie, offset: offset) { (users) in
                guard let users = users, !users.isEmpty else { return }
                var newUsers = self.users
                newUsers.append(contentsOf: users)
                newUsers.removeDuplicates()
                self.users = newUsers
            }
        } else if let timenoteId = self.timenoteId {
            TimenoteManager.shared.timenoteParticipantPublisher.assign(to: \.self.users, on: self).store(in: &self.cancellableBag)
            TimenoteManager.shared.getPaticipant(timenoteId: timenoteId, offset: offset)
            
        }
    }
    
    private func configureDataSource() {
        self.userListDataSource = UserListDataSource(tableView: self.userListTableView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserListViewController.ListCellName) as? FollowerXibView
            cell?.configure(follower: user)
            if indexPath.row == self.users.count - 3 {
                self.loadMore()
            }
            return cell
            
        })
        self.userListDataSource.defaultRowAnimation = .fade
    }
    
    private func updateUI() {
        self.userListSnapShot = UserListSnapShot()
        self.userListSnapShot.appendSections([.main])
        self.userListSnapShot.appendItems(self.users)
        DispatchQueue.main.async {
            self.userListDataSource.apply(self.userListSnapShot, animatingDifferences: true)
        }
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension UserListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = self.users[indexPath.row]
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
