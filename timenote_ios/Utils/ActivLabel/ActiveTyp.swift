//
//  ActiveTyp.swift
//  Timenote
//
//  Created by Dev on 12/28/21.
//  Copyright © 2021 timenote. All rights reserved.
//

import Foundation

enum ActiveTyp: Hashable {
    case mention
    case hashtag
    case username(pattern: String)
    
    var pattern: String {
        switch self {
        case .mention: return "@"
        case .hashtag: return "#"
        case .username(let regex): return regex
        }
    }
}
