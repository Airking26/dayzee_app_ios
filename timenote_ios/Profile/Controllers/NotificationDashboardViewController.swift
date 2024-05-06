//
//  NotificationDashboardViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/13/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine

class NotificationDashboardViewController : UIViewController {
    
// MARK: Outlets
    
    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var titleButton: UIButton!
    
// MARK: Public variables
    
    var viewType: NotificationViewType = .notification
    
// MARK: Private variables
    
    private var notifications: [NotificationDto] = []
    private var hiddenUsers: [UserResponseDto] = [] { didSet {
        self.notificationTableView.reloadData()
    }}
    private var hiddenEvents: [TimenoteDataDto] = [] { didSet {
        self.notificationTableView.reloadData()
    }}
    private var cancellableBag  = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateUI()
    }
    
// MARK: Private methods
    
    private func commonInit() {
        UserManager.shared.hiddenUsersListPublisher.assign(to: \.self.hiddenUsers, on: self).store(in: &self.cancellableBag)
        UserManager.shared.hiddenEventsListPublisher.assign(to: \.self.hiddenEvents, on: self).store(in: &self.cancellableBag)
        
        switch self.viewType {
        case .notification:
            titleButton.setTitle("Notification".localized, for: .normal)
        case .hiddenUsersList:
            titleButton.setTitle("HiddenUsers".localized, for: .normal)
            UserManager.shared.getHiddenUsers()
        case .hiddenEventsList:
            titleButton.setTitle("HiddenEvents".localized, for: .normal)
            UserManager.shared.getHiddenEvents()
        }
        self.updateUI()
    }
    
    private func updateUI() {
        self.notificationView.backgroundColor = .clear
    }
    
    private func getNumberOfRows() -> Int {
        switch self.viewType {
        case .notification:
            return APNsManager.shared.notificationsRegistered.count
        case .hiddenUsersList:
            return hiddenUsers.count
        case .hiddenEventsList:
            return hiddenEvents.count
        }
    }
    
    private func configure(cell: NotificationDashboardCell,
                           with indexPath: IndexPath) {
        cell.delegate = self
        switch self.viewType {
        case .notification:
            cell.configure(notification: APNsManager.shared.notificationsRegistered.reversed()[indexPath.row])
        case .hiddenUsersList:
            cell.configure(user: self.hiddenUsers[indexPath.row])
        case .hiddenEventsList:
            cell.configure(event: self.hiddenEvents[indexPath.row])
        }
    }
    
// MARK: Actions
    
    @IBAction func certificationIsTapped(_ sender: UIButton) {
        self.notificationView.backgroundColor = .clear
    }
    
    @IBAction func notificationIsTapped(_ sender: UIButton) {}
    
    @IBAction func backIsTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Table view extension

extension NotificationDashboardViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationCell = self.notificationTableView.dequeueReusableCell(withIdentifier: "NotificationDashboardCell") as! NotificationDashboardCell
        self.configure(cell: notificationCell, with: indexPath)
        return notificationCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewType == .notification {
            APNsManager.shared.handleNotificationInteraction(notification: APNsManager.shared.notificationsRegistered.reversed()[indexPath.row])
        }
    }
    
}

extension NotificationDashboardViewController: NotificationDashboardCellDelegate {
    
    func reloadView() {
        notificationTableView.reloadData()
        switch self.viewType {
        case .notification:
            break
        case .hiddenUsersList:
            UserManager.shared.getHiddenUsers()
        case .hiddenEventsList:
            UserManager.shared.getHiddenEvents()
        }
    }
    
}
