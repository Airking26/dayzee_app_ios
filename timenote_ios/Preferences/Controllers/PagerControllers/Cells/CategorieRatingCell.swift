//
//  CategorieRatingCell.swift
//  Timenote
//
//  Created by Aziz Essid on 23/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol CategorieRatingCellDelegate {
    func preferenceDidDeleted()
}

class CategorieRatingCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var gradientBottom: UIView! { didSet {
        let gradient = CAGradientLayer()
        gradient.frame = self.gradientBottom.bounds
        gradient.colors = [UIColor.clear, UIColor.black.withAlphaComponent(0.37), UIColor.black.withAlphaComponent(0.55)].compactMap({$0}).map{$0.cgColor}
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint (x: 0, y: 1)
        self.gradientBottom.roundCorners([.bottomLeft, .bottomRight], radius: 5)
        self.gradientBottom.layer.insertSublayer(gradient, at: .zero)
    }}
    
    var delegate: CategorieRatingCellDelegate?
    private var preference : UserPreferenceDto?
    
    func configure(preference: UserPreferenceDto) {
        self.preference = preference
        if let image = UIImage(named: CategoryImageName(rawValue: preference.name.lowercased())?.rawValue ?? "") {
            self.imageView.image = image
        } else {
            self.imageView.image = UIImage(named: "timemachine_gradient")
        }
        if ExploreHeaderXibView.ExploreTitles.contains(where: {$0.key.lowercased() == preference.name.lowercased()}), let title = ExploreHeaderXibView.ExploreTitles[preference.name.lowercased()] {
            self.label.text = title.localized
        } else {
            self.label.text = preference.name.localized
        }
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let preference = self.preference else { return }
        PreferencePagerController.passthrougtDataPublisher.value = PreferencePagerController.passthrougtDataPublisher.value.filter({$0 != preference})
        delegate?.preferenceDidDeleted()
    }
}
