//
//  NullEncodable.swift
//  Timenote
//
//  Created by Aziz Essid on 23/12/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
    
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case .some(let value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}
