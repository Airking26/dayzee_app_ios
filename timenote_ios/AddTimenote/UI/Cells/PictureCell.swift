//
//  PictureCell.swift
//  Timenote
//
//  Created by Aziz Essid on 05/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

protocol PictureCellDelegate {
    func didDelete(image: UIImage)
}

class PictureCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var pictureCellDelegate : PictureCellDelegate?
    
    public func configure(image: UIImage, delegate: PictureCellDelegate?) {
        self.imageView.image = image
        if let pictureCellDelegate = delegate {
            self.pictureCellDelegate = pictureCellDelegate
            self.deleteButton.isHidden = false
        } else {
            self.deleteButton.isHidden = true
        }
    }
    
    @IBAction func deleteIsTapped(_ sender: Any) {
        self.pictureCellDelegate?.didDelete(image: self.imageView.image!)
    }
    
}
