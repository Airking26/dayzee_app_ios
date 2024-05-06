//
//  FollowAskedViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 20/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

typealias FollowAskedDataSource    = UITableViewDiffableDataSource<Section, UserResponseDto>
typealias FollowAskedSnapShot      = NSDiffableDataSourceSnapshot<Section, UserResponseDto>

class FollowAskedViewController : UIViewController {
    
    private var userListDataSource  : FollowAskedDataSource!
    private var userListSnapShot    : FollowAskedSnapShot!
    public  var users               : [UserResponseDto] = [] { didSet {
        self.updateUI()
    }}
    private var selectedUser        : UserResponseDto?  = nil
    private var cancellableBag      = Set<AnyCancellable>()
    public  var isPending           : Bool              = false
    
    @IBOutlet weak var followAskedTableView: UITableView! { didSet {
        self.followAskedTableView.delegate = self
        self.followAskedTableView.rowHeight = UITableView.automaticDimension
        self.followAskedTableView.estimatedRowHeight = 90
    }}
    
    private func configureDataSource() {
        self.userListDataSource = FollowAskedDataSource(tableView: self.followAskedTableView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowAskedCell") as? FollowAskedCell
            cell?.configure(follower: user, delegate: self, canInteract: self.isPending)
            if indexPath.row == self.users.count - 3 {
                if self.isPending {
                    UserManager.shared.getPending(refresh: false)
                } else {
                    UserManager.shared.getRequested(refresh: false)
                }
            }
            return cell
            
        })
        self.userListDataSource.defaultRowAnimation = .fade
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profilViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? ProfileViewController {
            profilViewController.user = self.selectedUser
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        if self.isPending {
            UserManager.shared.userPendingListPublisher.assign(to: \.self.users, on: self).store(in: &self.cancellableBag)
            UserManager.shared.getPending(refresh: true)
        } else {
            UserManager.shared.userRequestedListPublisher.assign(to: \.self.users, on: self).store(in: &self.cancellableBag)
            UserManager.shared.getRequested(refresh: true)
        }
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() {
        self.userListSnapShot = UserListSnapShot()
        self.userListSnapShot.appendSections([.main])
        self.userListSnapShot.appendItems(self.users)
        DispatchQueue.main.async {
            self.userListDataSource.apply(self.userListSnapShot, animatingDifferences: true)
        }
    }
}

extension FollowAskedViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = self.users[indexPath.row]
        self.performSegue(withIdentifier: "goToProfil", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension FollowAskedViewController : FollowAskedDelegate {
    func didAccept(user: UserResponseDto?) {
        guard let user = user else { return }
        UserManager.shared.acceptFollow(userId: user.id)
        
    }
    
    func didDecline(user: UserResponseDto?) {
        guard let user = user else { return }
        UserManager.shared.declineFollow(userId: user.id)
    }
    
}
