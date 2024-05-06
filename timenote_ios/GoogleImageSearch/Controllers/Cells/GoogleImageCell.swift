//
//  GoogleImageCell.swift
//  Timenote
//
//  Created by Aziz Essid on 8/16/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class GoogleImageCell   : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var googleImage : GoogleAPISearchItem? { didSet {
        guard let googleImage = googleImage else { return }
        self.imageView.sd_setImage(with: URL(string: googleImage.image.thumbnailLink!))
    }}
    
    func configure(googleImage: GoogleAPISearchItem?, isSelected: Bool) {
        guard let googleImage = googleImage else { return }
        self.googleImage = googleImage
        self.conifugreCellSelection(isSelected: isSelected)
    }
    
    func getImageData() -> UIImage? {
        return self.imageView.image
    }
    
    func conifugreCellSelection(isSelected : Bool) {
        DispatchQueue.main.async {
            self.isSelected = isSelected
            self.imageView.borderWidth = isSelected ? 3 : 0
        }
    }
        
}
