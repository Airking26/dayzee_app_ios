//
//  PreferenceRatingCell.swift
//  Timenote
//
//  Created by Aziz Essid on 23/03/2021.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

protocol PreferenceRatingCellDelegate {
    func updatePreference(ratingSubcategorie: UserRatingCategorieDto,
                          with rating: Double)
}

class PreferenceRatingCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var rateStack: UIStackView!
    private var slider: MDCSlider?

    var delegate: PreferenceRatingCellDelegate?
    
    private var rating : UserRatingCategorieDto?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSlider()
    }
    
    func configure(rating: UserRatingCategorieDto) {
        self.rating = rating
        self.title.text = rating.subCategorie.capitalizingFirstLetter()
        self.slider?.value = CGFloat(rating.rating)
    }
    
    private func setupSlider() {
        let slider = MDCSlider()
        slider.addTarget(self, action: #selector(didSwitchValue(_:)), for: .valueChanged)
        slider.trackHeight = 5
        slider.minimumValue = 0
        slider.maximumValue = 5
        slider.thumbRadius = 8
        slider.isDiscrete = true
        slider.numberOfDiscreteValues = 6
        slider.value = 0
        slider.color = .systemYellow
        slider.trackEndsAreRounded = true
        slider.shouldDisplayDiscreteValueLabel = false
        slider.shouldEnableHapticsForAllDiscreteValues = true
        slider.valueLabelTextColor = .black
        slider.trackTickVisibility = .never
                
        self.slider = slider
        self.rateStack.addArrangedSubview(slider)
    }
    
    @objc func didSwitchValue(_ sender: MDCSlider) {
        if let index =
            PreferencePagerController.passthrougtDataPublisher.value.firstIndex(where: {$0.subCategorie.first(where: {$0.subCategorie == self.rating?.subCategorie}) != nil}), let indexPref = PreferencePagerController.passthrougtDataPublisher.value[index].subCategorie.firstIndex(where: {$0.subCategorie == self.rating?.subCategorie}) {
            PreferencePagerController.passthrougtDataPublisher.value[index].subCategorie[indexPref].rating = Double(sender.value)
            guard let ratingSubcategorie = rating else { return }
            self.delegate?.updatePreference(ratingSubcategorie: ratingSubcategorie, with: Double(sender.value))
        }
    }
    
    override func prepareForReuse() {
        self.slider?.value = 0
    }
    
}
