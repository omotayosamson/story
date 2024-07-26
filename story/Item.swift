//
//  Item.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
