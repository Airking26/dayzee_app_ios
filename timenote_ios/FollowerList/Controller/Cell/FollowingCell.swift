//
//  FollowingCell.swift
//  Timenote
//
//  Created by Aziz Essid on 02/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class FollowingCell : UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var certifiedView: UIView!
    
    private var delegate    : FollowingSelectedDelegate?
    private var userId      : String?
    
    public func configure(following: FollowingListDto, delegate: FollowingSelectedDelegate?, noAction : Bool = false) {
        self.userId = following.user.id
        self.delegate = delegate
        if let urlString = following.user.picture, let url = URL(string: urlString) {
            guard urlString != self.userImageView.sd_imageURL?.absoluteString else { return }
            self.userImageView.showAnimatedGradientSkeleton()
            self.userImageView.sd_setImage(with: url) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    self.userImageView.hideSkeleton()
                }
            }
        } else {
            self.userImageView.image = UIImage(named: "profile_icon")
        }
        self.userName.text = following.user.fullName
        self.certifiedView.isHidden = !(following.user.certified ?? false)
        if noAction {
            self.selectedButton.isHidden = true
        }
        self.selectedButton.isSelected = following.selected
    }
    
    override func prepareForReuse() {
        self.certifiedView.isHidden = true
    }
    
    @IBAction func selectionIsTapped(_ sender: UIButton) {
        guard let userId = self.userId else { return }
        self.delegate?.didSelect(users: [userId])
    }
}
