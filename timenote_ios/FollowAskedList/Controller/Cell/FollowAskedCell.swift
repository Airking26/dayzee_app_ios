//
//  FollowAskedCell.swift
//  Timenote
//
//  Created by Aziz Essid on 23/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol FollowAskedDelegate {
    func didAccept(user: UserResponseDto?)
    func didDecline(user: UserResponseDto?)
}

class FollowAskedCell : UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var certifiedView: UIView!
    
    private var follower        : UserResponseDto?
    private var delegate    : FollowAskedDelegate?
    
    public func configure(follower : UserResponseDto, delegate: FollowAskedDelegate, canInteract: Bool = true) {
        self.follower = follower
        self.delegate = delegate
        if let urlString = follower.picture, let url = URL(string: urlString) {
            self.userImageView.showAnimatedGradientSkeleton()
            self.userImageView.sd_setImage(with: url) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    self.userImageView.hideSkeleton()
                }
            }
        } else {
            self.userImageView.image = UIImage(named: "profile_icon")
        }
        self.validateButton.isHidden = !canInteract
        self.declineButton.isHidden = !canInteract
        self.userNameLabel.text = follower.fullName
        self.certifiedView.isHidden = !(follower.certified ?? false)
    }
    
    override func prepareForReuse() {
        self.certifiedView.isHidden = true
    }
    
    @IBAction func userAcceptIsTapped(_ sender: UIButton) {
        self.delegate?.didAccept(user: self.follower)
    }
    
    @IBAction func userDeclineIsTapped(_ sender: UIButton) {
        self.delegate?.didDecline(user: self.follower)
    }
    
}
