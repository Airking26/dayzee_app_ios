//
//  ExploreTilteCellController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/26/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

class ExploreTilteCellController : UITableViewCell {
    
    @IBOutlet weak var titleExploreLabel: UILabel!
    @IBOutlet weak var spacer: UIView!
    
    func configure(categorie: ExploreCategorie,
                   subcategorie: Int,
                   showSpacer: Bool = false) {
        self.titleExploreLabel.text = categorie.subcategory[subcategorie]
        self.spacer.isHidden = !showSpacer
    }
    
    override func prepareForReuse() {
        self.spacer.isHidden = true
    }
}
