//
//  Data.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

extension Data {

    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
