//
//  ExploreHeaderXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol CollapseSectionDelegate {
    func didCollapse(section: Int?)
}

class ExploreHeaderXibView : UITableViewHeaderFooterView {
    static let ExploreImages    : [String:UIImage?] = [
        "sport"                     :   UIImage(named: "sport"),
        "esport"                    :   UIImage(named: "esport"),
        "culture"                   :   UIImage(named: "culture"),
        "events & fair trade show"  :   UIImage(named: "fair_trade"),
        "musique"                   :   UIImage(named: "musique"),
        "movies & series"           :   UIImage(named: "film"),
        "holidays"                  :   UIImage(named: "holidays"),
        "shopping"                  :   UIImage(named: "shopping"),
        "interesting calendars"     :   UIImage(named: "calendar"),
        "youtubers"                 :   UIImage(named: "youtubers"),
        "religion"                  :   UIImage(named: "religion")
    ]
    
    static let ExploreTitles    : [String:String] = [
        "sport"                     :   "Sport",
        "esport"                    :   "E-Sport",
        "culture"                   :   "Culture",
        "events & fair trade show"  :   Locale.current.isFrench ? "Évènement" : "Events & Fair Trade Show",
        "musique"                   :   Locale.current.isFrench ? "Musique" : "Music",
        "movies & series"           :   Locale.current.isFrench ? "Films & Séries" : "Movies & Series",
        "holidays"                  :   Locale.current.isFrench ? "Vacance" : "Holidays",
        "shopping"                  :   "Shopping",
        "interesting calendars"     :   Locale.current.isFrench ? "Calendriers intéressants" : "Interesting Calendars",
        "youtubers"                 :   "Youtubers",
        "religion"                  :   "Religion"
    ]
    
    @IBOutlet weak var titleSection: UILabel!
    @IBOutlet weak var contentXibView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var leadingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewColor: UIView!
    @IBOutlet weak var visualEffect: UIView!
    
    private var isSelected  : Bool                      = false
    private var delegate    : CollapseSectionDelegate?  = nil
    private var section     : Int?                      = nil
    
    public func configure(delegate: CollapseSectionDelegate?, section: Int?, categorie: ExploreCategorie, hasBackgroundImage : Bool = false, canCollapse : Bool = true) {
        self.delegate = delegate
        self.section = section
        self.collapseButton.isHighlighted = categorie.collapsed
        self.titleSection.text = categorie.category.uppercased()
        if hasBackgroundImage {
            let image = UIImage(named: CategoryImageName(rawValue: categorie.category.lowercased())?.rawValue ?? "") 
            self.titleSection.textColor = .white
            self.collapseButton.tintColor = .white
            self.backgroundImageView.image = image
        } else {
            self.titleSection.textColor = .label
            self.collapseButton.tintColor = .label
            self.backgroundImageView.image = nil
        }
        self.backgroundViewColor.backgroundColor = .systemBackground
        self.collapseButton.isHidden = !canCollapse
    }

    public func configure(categorie: UserPreferenceDto) {
        self.titleSection.text = categorie.name.uppercased()
        if let image = UIImage(named: CategoryImageName(rawValue: categorie.name.lowercased())?.rawValue ?? "") {
            self.titleSection.textColor = .white
            self.collapseButton.tintColor = .white
            self.backgroundImageView.image = image
        } else {
            self.titleSection.textColor = .label
            self.collapseButton.tintColor = .label
            self.backgroundImageView.image = nil
        }
        self.collapseButton.isHidden = true
        self.leadingImageConstraint.constant = 0
        self.trailingImageConstraint.constant = 0
        self.backgroundViewColor.backgroundColor = .clear
        self.backgroundImageView.layer.cornerRadius =  20
        self.backgroundImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.visualEffect.layer.cornerRadius =  20
        self.visualEffect.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        DispatchQueue.main.async { [weak self] in
            self?.backgroundImageView.addCustomBorder(color: .white, width: 1, corderRadius: 20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], isShowTopBorder: true)
        }
    }
    
    @IBAction func collapseIsTapped(_ sender: UIButton) {
        self.delegate?.didCollapse(section: self.section)
    }
}
