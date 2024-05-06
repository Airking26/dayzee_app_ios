//
//  UserPreferenceCell.swift
//  Timenote
//
//  Created by Aziz Essid on 22/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit

class UserPreferenceCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var enabledButton: UIButton!
    @IBOutlet weak var gradientView: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.gradientView.bounds
        gradient.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.37), UIColor.black.withAlphaComponent(0.55)].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.gradientView.layer.insertSublayer(gradient, at: .zero)
    }}
    
    func configure(preference: UserPreferenceDto) {
        if let image = UIImage(named: CategoryImageName(rawValue: preference.name.lowercased())?.rawValue ?? "") {
            self.imageView.image = image
        } else {
            self.imageView.image = UIImage(named: "timemachine_gradient")
        }
        if ExploreHeaderXibView.ExploreTitles.contains(where: {$0.key.lowercased() == preference.name.lowercased()}), let title = ExploreHeaderXibView.ExploreTitles[preference.name.uppercased()] {
            self.title.text = title.localized
        } else {
            self.title.text = preference.name.localized.uppercased()
        }
        self.enabledButton.isSelected = preference.enabled
    }
    
}
