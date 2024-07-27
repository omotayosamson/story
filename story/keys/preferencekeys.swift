//
//  preferencekeys.swift
//  story
//
//  Created by omotayo ayomide on 27/07/2024.
//

import SwiftUI

struct OffsetKey: PreferenceKey {
    static  var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
