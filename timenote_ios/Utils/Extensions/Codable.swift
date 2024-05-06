//
//  Struct.swift
//  Timenote
//
//  Created by Aziz Essid on 8/16/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

extension Encodable {
    
    func toQueryItems() -> [URLQueryItem] {
        let conditionMirror = Mirror(reflecting: self)
        var queryItems :    [URLQueryItem]  = []

        for (label, value) in conditionMirror.children {
            guard let label = label else { continue }
            queryItems.append(URLQueryItem(name: label, value: "\(value)"))
        }
        return queryItems
    }
    
}
