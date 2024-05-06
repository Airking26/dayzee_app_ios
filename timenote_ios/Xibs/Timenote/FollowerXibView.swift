//
//  FollowerXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class FollowerXibView : UITableViewCell {
    
    @IBOutlet weak var followerGivenName: UILabel!
    @IBOutlet weak var followerImageView: UIImageView!
    @IBOutlet weak var followerName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var certifiedView: UIView!
    
    private var follower   : UserResponseDto?   = nil
    
    public func configure(follower: UserResponseDto,
                          hideSubscribeBtn: Bool = false) {
        self.followerImageView.borderWidth = 0.5
        self.followerImageView.borderColor = .label
        self.selectionStyle = .none
        guard self.follower?.id != follower.id else { return }
        self.follower = follower
        if let urlString = follower.picture, let url = URL(string: urlString) {
            self.followerImageView.showAnimatedGradientSkeleton()
            self.followerImageView.sd_setImage(with: url) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    self.followerImageView.hideSkeleton()
                }
            }
        } else {
            self.followerImageView.image = UIImage(named: "profile_icon")
        }
        if let givenName = follower.givenName, !givenName.isEmpty {
            self.followerGivenName.isHidden = false
            self.followerGivenName.text = givenName
        } else {
            self.followerGivenName.isHidden = true
        }
        self.certifiedView.isHidden = !(follower.certified ?? false)
        self.followerName.text = follower.fullName
        self.followButton.isSelected = follower.isInFollowers ?? false
        self.followButton.isHidden = hideSubscribeBtn
        self.contentView.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        self.followButton.isSelected = false
        self.certifiedView.isHidden = true
    }
    
    @IBAction func suscribeIsTapped(_ sender: UIButton) {
        guard self.follower?.id != UserManager.shared.userInformation?.id else { return }
        sender.isUserInteractionEnabled = false
        if self.follower?.isInFollowers == false {
            if self.follower?.status == .PRIVATE {
                UserManager.shared.askFollowUser(userId: self.follower?.id) { (success) in
                    AlertManager.shared.showErrorWithTilteAndDesciption(title: success ? Locale.current.isFrench ? "Votre demande à été envoyé" : "You'r request has been sent" : Locale.current.isFrench ? "Vous avez déjà envoyé une demande à cette utilisateur" : "You already have requested this user" , desciption: "", isBlue: true)
                    sender.isUserInteractionEnabled = true
                }
            } else {
                UserManager.shared.followUser(userId: self.follower?.id) { (user) in
                    sender.isUserInteractionEnabled = true
                    self.follower = user
                    DispatchQueue.main.async {
                        self.followButton.isSelected = self.follower?.isInFollowers ?? false
                    }
                }
            }
        } else {
            UserManager.shared.unfollowUser(userId: self.follower?.id) { (success) in
                sender.isUserInteractionEnabled = true
                self.follower?.isInFollowers = !success
                DispatchQueue.main.async {
                    self.followButton.isSelected = self.follower?.isInFollowers ?? false
                }
            }
        }
    }
    
}
