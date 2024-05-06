//
//  TimenoteCalendarXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 29/10/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class TimenoteCalendarXibView : UITableViewCell {
    
    @IBOutlet weak var timenoteImageView: UIImageView!
    @IBOutlet weak var timenoteNameLabel: UILabel!
    @IBOutlet weak var timenoteAdresseLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    public func configure(timenote: TimenoteDataDto) {
        DispatchQueue.main.async {
            self.selectionStyle = .none
            if let urlString = timenote.pictures.first, let url = URL(string: urlString) {
                if self.timenoteImageView.sd_imageURL == nil {
                    self.timenoteImageView.showAnimatedGradientSkeleton()
                }
                self.timenoteImageView.sd_setImage(with: url) { (image, error, cache, url) in
                    DispatchQueue.main.async {
                        self.timenoteImageView.hideSkeleton()
                    }
                }
            } else if let hex = timenote.colorHex {
                self.timenoteImageView.image = UIImage(color: UIColor(hex: hex) ?? .white)
            }
            self.timenoteNameLabel.text = timenote.title.uppercased()
            self.timenoteAdresseLabel.text = timenote.location?.address.address
            if let urlString = timenote.createdBy.picture, let url = URL(string: urlString) {
                self.userImageView.showAnimatedGradientSkeleton()
                self.userImageView.sd_setImage(with: url) { (image, error, cache, url) in
                    DispatchQueue.main.async {
                        self.userImageView.hideSkeleton()
                    }
                }
            } else {
                self.userImageView.image = UIImage(named: "profile_icon")
            }
        }
    }

    
}
