//
//  SDWebImageInput.swift
//  Timenote
//
//  Created by Aziz Essid on 04/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import SDWebImage
import ImageSlideshow


/// Input Source to image using SDWebImage
@objcMembers
public class SDWebImageSource: NSObject, InputSource {
    typealias SDWebImageCallback = ((Bool) -> Void)
    /// url to load
    public var url: URL

    /// placeholder used before image is loaded
    public var placeholder: UIImage?
    private var callback : SDWebImageCallback?
    
    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(url: URL, placeholder: UIImage? = nil, completion: ((Bool) -> Void)? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.callback = completion
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init?(urlString: String, placeholder: UIImage? = nil, completion: ((Bool) -> Void)? = nil) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            self.callback = completion
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.sd_setImage(with: self.url, placeholderImage: self.placeholder, options: [], completed: { (image, _, _, _) in
            self.callback?(true)
            callback(image)
        })
    }

    public func cancelLoad(on imageView: UIImageView) {
        imageView.sd_cancelCurrentImageLoad()
    }
}
