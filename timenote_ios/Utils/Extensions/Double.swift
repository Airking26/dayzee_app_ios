//
//  Double.swift
//  Timenote
//
//  Created by Aziz Essid on 6/8/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
