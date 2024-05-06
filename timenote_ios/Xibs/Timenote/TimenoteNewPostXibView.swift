//
//  TimenoteNewPostXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/5/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import SkeletonView
import UIKit

class TimenoteNewPostXibView : UICollectionViewCell {
    
    @IBOutlet weak var timenoteUserImageView: UIImageView!
    @IBOutlet weak var timenoteImageView: UIImageView!
    @IBOutlet weak var timenoteNameLabel: OutlinedLabel!
    @IBOutlet weak var timenoteDateLabel: OutlinedLabel!
    @IBOutlet weak var timenoteStackView: UIStackView!
    @IBOutlet weak var bottonGradientView: UIView! { didSet {
        let gradientBotton = CAGradientLayer()
        gradientBotton.frame = self.bottonGradientView.bounds
        gradientBotton.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.37), UIColor.black.withAlphaComponent(0.55)].compactMap({$0}).map{$0.cgColor}
        gradientBotton.startPoint = CGPoint(x: 0, y: 0)
        gradientBotton.endPoint = CGPoint (x: 0, y: 1)
        self.bottonGradientView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        self.bottonGradientView.layer.insertSublayer(gradientBotton, at: .zero)
    }}
    @IBOutlet weak var topGradientView: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.topGradientView.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0.55), UIColor.black.withAlphaComponent(0.37), UIColor.clear].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.topGradientView.roundCorners([.topLeft, .topRight], radius: 10)
        self.topGradientView.layer.insertSublayer(gradient, at: .zero)
        self.contentView.layoutIfNeeded()
    }}
    
    private var timer               : Timer?
    
    func configure(timenote: TimenoteDataDto) {
        DispatchQueue.main.async {
            self.timenoteNameLabel.text = timenote.title.uppercased()
            if let urlString = timenote.pictures.first, let url = URL(string: urlString) {
                if self.timenoteImageView.sd_imageURL == nil {
                    DispatchQueue.main.async {
                        //self.timenoteImageView.showAnimatedGradientSkeleton()
                    }
                }
                self.timenoteImageView.sd_setImage(with: url) { (image, error, cache, url) in
                    DispatchQueue.main.async {
                        self.timenoteImageView.hideSkeleton()
                    }
                }
            } else if let hex = timenote.colorHex {
                self.timenoteImageView.image = UIImage(color: UIColor(hex: hex) ?? .white)
            }
            if let urlString = timenote.createdBy.picture, let url = URL(string: urlString) {
                if self.timenoteUserImageView.sd_imageURL == nil {
                    self.timenoteUserImageView.showAnimatedGradientSkeleton()
                }
                self.timenoteUserImageView.sd_setImage(with: url) { (image, error, cache, url) in
                    DispatchQueue.main.async {
                        self.timenoteUserImageView.hideSkeleton()
                    }
                }
            } else {
                self.timenoteUserImageView.image = UIImage(named: "profile_icon")
            }
            self.timer?.invalidate()
            guard let startDate = timenote.startingDate, !((startDate < Date()) && (Date() < timenote.endingDate ?? Date())) else {
                self.timenoteDateLabel.text = "LIVE 🔴"
                return
            }
            self.timenoteDateLabel.text = "\(timenote.startingDate?.timeAgoDisplay() ?? (Locale.current.isFrench ? "1 jour" : "1 day"))"
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                DispatchQueue.main.async {
                    self.timenoteDateLabel.text = "\(timenote.startingDate?.timeAgoDisplay() ?? (Locale.current.isFrench ? "1 jour" : "1 day"))"
                }
            }
        }
    }
    
}
