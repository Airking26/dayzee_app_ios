//
//  SearchTitleXibView.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class SearchTitleXibView : UITableViewHeaderFooterView {
    
    @IBOutlet weak var searchTitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    func initUI(topDto: TopDto?) {
        searchTitleLabel.text = topDto?.category.subcategory.localized.uppercased()
        guard let imageName = topDto?.category.category.lowercased(),
              let image = UIImage(named: imageName)
        else {
            searchTitleLabel.textColor = .black
            return
        }
        backgroundImageView.image = image
        self.backgroundImageView.layer.cornerRadius =  20
        self.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.backgroundImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        DispatchQueue.main.async { [weak self] in
            self?.backgroundImageView.addCustomBorder(color: .white, width: 1, corderRadius: 20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], isShowTopBorder: true)
        }
    }
    
    override func prepareForReuse() {
        self.searchTitleLabel.text = ""
        self.searchTitleLabel.textColor = .white
        self.backgroundImageView.image = nil
    }
    
}
