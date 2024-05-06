//
//  TimenoteXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 6/22/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol TimenoteMinXibViewDelegate {
    func timenoteMoreIsTapped(_ sender: UIButton, timenote: TimenoteDataDto)
}

class TimenoteMinXibView : UITableViewCell {
    
    @IBOutlet weak var timenoteImageView: UIImageView!
    @IBOutlet weak var timenoteLabel: UILabel!
    @IBOutlet weak var timenoteLocation: UILabel!
    @IBOutlet weak var timenotUserImageView: UIImageView!
    @IBOutlet weak var timenoteUserNameLabel: UILabel!
    @IBOutlet weak var timenoteDateLabel: UILabel!
    
    var delegate: TimenoteMinXibViewDelegate?
    
    private var timer : Timer?
    private var timenote: TimenoteDataDto?
    
    public func configure(timenote: TimenoteDataDto) {
        self.timenote = timenote
        if let urlString = timenote.pictures.first, let url = URL(string: urlString) {
            self.timenoteImageView.showAnimatedGradientSkeleton()
            self.timenoteImageView.sd_setImage(with: url) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    self.timenoteImageView.hideSkeleton()
                }
            }
        } else if let hex = timenote.colorHex {
            self.timenoteImageView.image = UIImage(color: UIColor(hex: hex) ?? .white)
        }
        self.timenoteLabel.text = timenote.title.uppercased()
        if !(timenote.location?.address.address.isEmpty ?? true) {
            self.timenoteLocation.text = timenote.location?.address.address
        } else {
            self.timenoteLocation.text = timenote.visibleLocation
        }
        self.timenoteUserNameLabel.text = timenote.createdBy.userName
        if let urlString = timenote.createdBy.picture, let url = URL(string: urlString) {
            self.timenotUserImageView.showAnimatedGradientSkeleton()
            self.timenotUserImageView.sd_setImage(with: url) { (image, error, cache, url) in
                DispatchQueue.main.async {
                    self.timenotUserImageView.hideSkeleton()
                }
            }
        } else {
            self.timenotUserImageView.image = UIImage(named: "profile_icon")
        }
        self.timer?.invalidate()
        guard let startDate = timenote.startingDate, !((startDate < Date()) && (Date() < timenote.endingDate ?? Date())) else {
            self.timenoteDateLabel.text = "LIVE 🔴"
            return
        }
        self.timenoteDateLabel.text = "\(timenote.startingDate?.timeAgoDisplay() ?? "1 \(Locale.current.isFrench ? "jour" : "day")")"
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                self.timenoteDateLabel.text = "\(timenote.startingDate?.timeAgoDisplay() ?? "1 \(Locale.current.isFrench ? "jour" : "Day")")"
            }
        }
    }
    
    @IBAction func timenoteMoreIsTapped(_ sender: UIButton) {
        guard let timenote = timenote else { return }
        delegate?.timenoteMoreIsTapped(sender, timenote: timenote)
    }
    
}
