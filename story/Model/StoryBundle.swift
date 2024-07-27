//
//  StoryBundle.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI

struct StoryBundle: Identifiable, Hashable{
    var id = UUID().uuidString
    var name: String
    var isSeen: Bool = false
    var stories: [Story]
}

struct Story: Identifiable, Hashable{
    var id = UUID().uuidString
    var videoURL: String
}
