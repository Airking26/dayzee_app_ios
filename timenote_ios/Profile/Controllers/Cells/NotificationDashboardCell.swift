//
//  NotificationDashboardCell.swift
//  Timenote
//
//  Created by Aziz Essid on 7/13/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol NotificationDashboardCellDelegate {
    func reloadView()
}

class NotificationDashboardCell : UITableViewCell {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var notifcationComment: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var followerHandleStack: UIStackView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    
    var delegate: NotificationDashboardCellDelegate?
    
    private var notification: NotificationTimenote? = nil
    private var user: UserResponseDto?
    private var event: TimenoteDataDto?
    
// MARK: Override
    
    override func prepareForReuse() {
        self.handleViewState(false)
        self.notificationTimeLabel.isHidden = false
        self.backgroundColor = .clear
    }
    
// MARK: Public methods
    
    func configure(notification: NotificationTimenote) {
        self.notification = notification
        
        self.handleViewState(false)
        self.initUI()
    }
    
    func configure(user: UserResponseDto) {
        self.user = user
        self.handleViewState(true)
        self.notificationTimeLabel.isHidden = true
        self.initUI()
        
        self.notifcationComment.text = user.userName
        guard let imageUrl = user.picture,
              let url = URL(string: imageUrl)
        else { return }
        self.userAvatar.sd_setImage(with: url)
    }
    
    func configure(event: TimenoteDataDto) {
        self.event = event
        self.handleViewState(true)
        self.notificationTimeLabel.isHidden = false
        self.initUI()
        
        self.notifcationComment.text = event.title
        self.notificationTimeLabel.text = event.createdDate?.getDetails()
        guard let imageUrl = event.pictures.first,
              let url = URL(string: imageUrl)
        else { return }
        self.userAvatar.sd_setImage(with: url)
    }
    
// MARK: Private methods
    
    private func initUI() {
        guard let notification = notification else { return }
        
        switch notification.type {
        case 3:
            followerHandleStack.isHidden = false
        default:
            followerHandleStack.isHidden = true
        }
        if let imageURL = notification.picture, let url = URL(string: imageURL) {
            self.userAvatar.sd_setImage(with: url)
        } else {
            userAvatar.image = UIImage(color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        }
        self.notifcationComment.text = notification.description
        self.notificationTimeLabel.text = "\(notification.createdDate?.timeAgoDisplay() ?? "1 \(Locale.current.isFrench ? "jour" : "day")")"
        self.backgroundColor = !(notification.hasBeenRead ?? true) ? UIColor.systemGray5 : UIColor.clear
    }
    
    private func handleViewState(_ shouldHideConfirmationButtons: Bool) {
        self.hideButton.isHidden = !shouldHideConfirmationButtons
        self.submitButton.isHidden = shouldHideConfirmationButtons
        self.discardButton.isHidden = shouldHideConfirmationButtons
    }
    
// MARK: Actions
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        guard let userId = notification?.idData,
              let notificationID = notification?.id
        else { return }
        APNsManager.shared.acceptFollowRequested(userId: userId, notificationId: notificationID)
        delegate?.reloadView()
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let userId = notification?.idData,
              let notificationID = notification?.id
        else { return }
        APNsManager.shared.declineFollowRequested(userID: userId, notificationId: notificationID)
        delegate?.reloadView()
    }
    
    @IBAction func showButtonTapped(_ sender: UIButton) {
        if let user = self.user {
            UserManager.shared.deleteHiddenUser(id: user.id) { [weak self] _ in
                self?.delegate?.reloadView()
            }
        } else if let event = self.event {
            UserManager.shared.deleteHiddenEvent(id: event.id) { [weak self] _ in
                self?.delegate?.reloadView()
            }
        }
    }
    
}

