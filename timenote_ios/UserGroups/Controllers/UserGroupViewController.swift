//
//  UserGroupViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 05/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol UserGroupDelegate {
    func didSelectGroup(group: GroupSectionDto?)
}

typealias UserGroupDataSource = UITableViewDiffableDataSource<String, UserGroup>
typealias UserGroupSnapShot   = NSDiffableDataSourceSnapshot<String, UserGroup>

class UserGroupViewController   : UIViewController {
    
    static let HeaderNameXib    : String    = "GroupHeaderSectionXibView"
    static let FollowerNameXib  : String    = "FollowerXibView"
    
    @IBOutlet weak var userGroupTableView: UITableView! { didSet {
        self.userGroupTableView.delegate = self
        self.userGroupTableView.register(UINib(nibName: UserGroupViewController.HeaderNameXib, bundle: nil), forHeaderFooterViewReuseIdentifier: UserGroupViewController.HeaderNameXib)
        self.userGroupTableView.register(UINib(nibName: UserGroupViewController.FollowerNameXib, bundle: nil), forCellReuseIdentifier: UserGroupViewController.FollowerNameXib)
    }}
    
    public  var delegate            : UserGroupDelegate?
    public  var currentGroup        : GroupSectionDto?
    private var userGroupDataSource : UserGroupDataSource!
    private var userGroupSnapShot   : UserGroupSnapShot!
    private var groups              : [GroupSectionDto] = [] { didSet {
        self.updateUI()
    }}
    private var cancellableBag      = Set<AnyCancellable>()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let followingListViewController = (segue.destination as? UINavigationController)?.viewControllers.first as? FollowingListViewController {
            followingListViewController.isSharing = false
            followingListViewController.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.shared.getUserGroup()
        self.configureDataSource()
        UserManager.shared.userGroupsPublisher.map({$0.map({let name = $0.name; let selected = name == self.currentGroup?.name; return GroupSectionDto(group: $0.users.map({UserGroup(user: $0, name: name)}), name: $0.name, selected: self.groups.first(where: {$0.name == name})?.selected ?? selected, collapsed: self.groups.first(where: {$0.name == name})?.collapsed ?? false)})}).assign(to: \.self.groups, on: self).store(in: &self.cancellableBag)
        self.currentGroup = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.didSelectGroup(group: self.groups.first(where: {$0.selected == true}))
    }
    
    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }
    
    private func configureDataSource() {
        self.userGroupDataSource = UserGroupDataSource(tableView: self.userGroupTableView, cellProvider: { (tableView, indexPath, user) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: UserGroupViewController.FollowerNameXib) as? FollowerXibView
            cell?.configure(follower: user.user)
            return cell
        })
        self.userGroupDataSource.defaultRowAnimation = .fade
    }
    
    private func updateUI() {
        self.userGroupSnapShot = UserGroupSnapShot()
        self.userGroupSnapShot.appendSections(self.groups.map({$0.name}))
        for group in self.groups {
            self.userGroupSnapShot.appendItems(group.collapsed ? group.group : [], toSection: group.name)
        }
        DispatchQueue.main.async {
            self.userGroupDataSource.apply(self.userGroupSnapShot, animatingDifferences: true)
        }
    }
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension UserGroupViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: UserGroupViewController.HeaderNameXib) as? GroupHeaderSectionXibView
        headerView?.configure(delegate: self, section: section, group: self.groups[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

extension UserGroupViewController : GroupSectionDelegate {
    
    func didCollapse(section: Int?) {
        guard let section = section else { return }
        self.groups[section].collapsed = !self.groups[section].collapsed
    }
    
    func didSelect(section: Int?) {
        guard let section = section else { return }
        self.groups[section].selected = !self.groups[section].selected
        if self.groups[section].selected {
            for i in 0..<self.groups.count {
                self.groups[i].selected = i == section
                if let header = self.userGroupTableView.headerView(forSection: i) as? GroupHeaderSectionXibView {
                    header.configure(delegate: self, section: i, group: self.groups[i])
                }
            }
        }
        
    }
    
}

extension UserGroupViewController : FollowingSelectedDelegate {
    
    func didSelect(users: [String]) {
        guard !users.isEmpty else { return }
        let alertViewController = UIAlertController(title: Locale.current.isFrench ? "Nom du groupe" : "Group name", message: Locale.current.isFrench ? "Donnez maintenant un nom à votre groupe d'amis" : "Enter your group's name", preferredStyle: .alert)
        alertViewController.addTextField { (textField) in
            
        }
        alertViewController.addAction(UIAlertAction(title: Locale.current.isFrench ? "Ajouter" : "Add", style: .default, handler: { (alert) in
            guard let name = alertViewController.textFields?.first?.text, !name.isEmpty else {
                alertViewController.message = Locale.current.isFrench ? "Votre nom est vide veuillez réessayer !" : "The group's name is empty try again"
                return self.present(alertViewController, animated: true, completion: nil)
            }
            UserManager.shared.createGroup(group: CreateGroupDto(name: name, users: users))
        }))
        let cancel = UIAlertAction(title: Locale.current.isFrench ? "Annulez" : "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alertViewController.addAction(cancel)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
}
