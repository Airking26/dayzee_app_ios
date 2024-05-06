//
//  Image.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImage {
    
      convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
    
    public enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }
    
    func getSizeIn(_ type: DataUnits) -> Double {
        guard let data = self.pngData() else {
            return -1
        }
        
        var size: Double = 0.0
        
        switch type {
        case .byte:
            size = Double(data.count)
        case .kilobyte:
            size = Double(data.count) / 1024
        case .megabyte:
            size = Double(data.count) / 1024 / 1024
        case .gigabyte:
            size = Double(data.count) / 1024 / 1024 / 1024
        }
        
        return size
    }
    
    func resizeCI(size:CGSize) -> UIImage? {
        let scale = (Double)(size.width) / (Double)(self.size.width)
        let image = UIKit.CIImage(cgImage:self.cgImage!)
                
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value:scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey:kCIInputAspectRatioKey)
        let outputImage = filter.value(forKey: kCIOutputImageKey) as! UIKit.CIImage
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        let resizedImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)
        return resizedImage
    }
    
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

// Gestion du cache

extension UIImageView {
    func retrieveImg(urlStr: String, placeholder: UIImage? = nil) {
        self.sd_imageIndicator = SDWebImageActivityIndicator.large
        if let url = URL(string: urlStr) {
            self.sd_setImage(with: url, placeholderImage: placeholder)
        }
    }
}
