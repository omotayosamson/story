//
//  StoryViewModel.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI

class StoryViewModel: ObservableObject{
    @Published var stories: [StoryBundle] = [
        StoryBundle(name: "A", stories: [
            Story(videoURL: "trimmy"),
            Story(videoURL: "Reel 1"),
            Story(videoURL: "Reel 3"),
        ]),
        
        StoryBundle(name: "B", stories: [
            Story(videoURL: "Reel 2"),
            Story(videoURL: "Reel 3"),
            Story(videoURL: "Reel 1"),
            Story(videoURL: "Reel 3"),
        ]),
    ]
    
    @Published var showStory: Bool =  false
    
    @Published var currentStory: String = ""
    
    
}
