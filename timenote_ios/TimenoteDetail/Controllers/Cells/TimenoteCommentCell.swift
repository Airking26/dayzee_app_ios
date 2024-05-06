//
//  TimenoteCommentCell.swift
//  Timenote
//
//  Created by Aziz Essid on 8/25/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol CommentSelectedUserDelegate {
    func didTapUser(user: UserResponseDto?)
    func didTapPicture(_ sender: UITapGestureRecognizer)
    func didTapUserTag(userTag: String)
    func beginUpdates()
    func endUpdates()
}

class TimenoteCommentCell : UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userCommentLabel: ActivLabel!
    @IBOutlet weak var certifiedImageView: UIImageView!
        
    private var delegate : CommentSelectedUserDelegate? = nil
    private var user     : UserResponseDto?
    private var timenoteComment: TimenoteCommentDto?
    
    override func didMoveToWindow() {
        self.setupTextHighliting()
    }
    
    func configure(timenoteComment: TimenoteCommentDto, delegate: CommentSelectedUserDelegate?) {
        self.delegate = delegate
        self.user = timenoteComment.createdBy
        self.timenoteComment = timenoteComment
        setupTextHighliting()
        
        if let urlString = timenoteComment.createdBy.picture, let url = URL(string: urlString) {
            self.userImageView.showAnimatedGradientSkeleton()
            self.userImageView.sd_setImage(with: url) { (image, error, cache, url) in
                self.userImageView.hideSkeleton()
            }
        } else {
            self.userImageView.image = UIImage(named: "profile_icon")
        }
        self.certifiedImageView.isHidden = !(self.user?.certified ?? false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.seletedUser))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextHighliting() {
        guard let timenoteComment = timenoteComment else { return }
        let mutableAttributedString = NSMutableAttributedString(string: "\(timenoteComment.createdBy.fullName) ")
        let addedAttributedString = NSAttributedString(string: timenoteComment.description)
        mutableAttributedString.append(addedAttributedString)
        let time = timenoteComment.createdAtDate?.timeAgoDisplay() ?? (Locale.current.isFrench ? "Maintenant" : "Now")
        let addedAttributedTimeString = NSAttributedString(string: "\n\(time)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)])
        mutableAttributedString.append(addedAttributedTimeString)
        
        let usernameType = ActiveTyp.username(pattern: timenoteComment.createdBy.fullName)
        self.userCommentLabel.enabledTypes = [.mention, usernameType, .hashtag]
        self.userCommentLabel.typeAttributes = [
            .mention : [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 14)!],
            usernameType : [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 14)!],
            .hashtag : [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 14)!]
        ]
        self.userCommentLabel.attributedText = mutableAttributedString
        self.userCommentLabel.isUserInteractionEnabled = true
        self.userCommentLabel.delegate = self
        self.userCommentLabel.highlight()
    }
    
    override func prepareForReuse() {
        self.certifiedImageView.isHidden = true
        self.setupTextHighliting()
    }
    
    @objc func seletedUser() {
        self.delegate?.didTapUser(user: self.user)
    }
    
}

extension TimenoteCommentCell: ActivLabelDelegate {
    
    func didSelect(_ text: String, with type: ActiveTyp) {
        self.delegate?.didTapUserTag(userTag: text)
    }
    
}
