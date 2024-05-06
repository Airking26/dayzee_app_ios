//
//  TimenoteCommentImageCell.swift
//  Timenote
//
//  Created by Dev on 9/1/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import UIKit

class TimenoteCommentImageCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userCommentLabel: ActivLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
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
        
        self.setupTextHighliting()
        
        if let urlString = timenoteComment.createdBy.picture, let url = URL(string: urlString) {
            self.userImageView.showAnimatedGradientSkeleton()
            self.userImageView.sd_setImage(with: url) { (image, error, cache, url) in
                self.userImageView.hideSkeleton()
            }
        } else {
            self.userImageView.image = UIImage(named: "profile_icon")
        }
        if let imageURL = timenoteComment.picture {
            DispatchQueue.main.async { [weak self] in
                self?.picture.sd_setImage(with: URL(string: imageURL)) { image, _, _, _ in
                    DispatchQueue.main.async {
                        if let image = image {
                            self?.delegate?.beginUpdates()
                            self?.picture.image = image
                            self?.picture.isHidden = false
                            self?.delegate?.endUpdates()
                        } else {
                            self?.picture.isHidden = true
                        }
                    }
                }
            }
        }
        //Gesture recognizers
        self.picture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPicture(_:))))
        self.picture.isUserInteractionEnabled = true
        self.certifiedImageView.isHidden = !(self.user?.certified ?? false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.seletedUser))
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.addGestureRecognizer(tapGesture)
        let time = timenoteComment.createdAtDate?.timeAgoDisplay() ?? (Locale.current.isFrench ? "Maintenant" : "Now")
        self.timeLabel.text = time
    }
    
    private func setupTextHighliting() {
        guard let timenoteComment = timenoteComment else { return }
        //Setup labels text
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
    
    @objc func seletedUser() {
        self.delegate?.didTapUser(user: self.user)
    }
    
    @objc func selectPicture(_ sender: UITapGestureRecognizer) {
        delegate?.didTapPicture(sender)
    }
    
    override func prepareForReuse() {
        self.picture.image = nil
        self.certifiedImageView.isHidden = true
    }
    
}

extension TimenoteCommentImageCell: ActivLabelDelegate {
    
    func didSelect(_ text: String, with type: ActiveTyp) {
        self.delegate?.didTapUserTag(userTag: text)
    }
    
}
