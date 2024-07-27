//
//  StoryViewModel.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI

class StoryViewModel: ObservableObject{
    @Published var stories: [StoryBundle] = [
        StoryBundle(name: "Dribbles", stories: [
            Story(videoURL: "01"),
            Story(videoURL: "02"),
            Story(videoURL: "03"),
        ]),
        
        StoryBundle(name: "Tackles", stories: [
            Story(videoURL: "04"),
            Story(videoURL: "02"),
            Story(videoURL: "03"),
            Story(videoURL: "01"),
        ]),
    ]
    
    @Published var showStory: Bool =  false
    
    @Published var currentStory: String = ""
    
    
}
