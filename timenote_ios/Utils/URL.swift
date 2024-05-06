//
//  Data.swift
//  Timenote
//
//  Created by Aziz Essid on 8/30/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    
    func downloadImage(completion: @escaping(_ image : UIImage?) -> Void) {
        URLSession.shared.dataTask(with: self) { (data, response, error) in
            guard let data = data, error == nil else { return completion(nil) }
            completion(UIImage(data: data))
            
        }
    }
}
