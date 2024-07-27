//
//  Home.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI

struct Home: View {
    @StateObject var storyData = StoryViewModel()
    var size: CGSize
    var safeArea: EdgeInsets
    var body: some View {
        NavigationStack{
            ScrollView(.vertical, showsIndicators: false){
                ScrollView(.horizontal, showsIndicators: false){
                    
                    HStack(spacing: 12, content: {
                        
                        ForEach($storyData.stories){ $bundle in
                            
                            ProfileView(bundle: $bundle)
                                .environmentObject(storyData)
                            
                        }
                        
                    })
                    .padding()
                    .padding(.top, 10)
                    
                }
            }
            //
            .overlay(
                StoryView(size: size, safeArea: safeArea)
                    .environmentObject(storyData)
            )
        }
    }
}

struct ProfileView: View {
    @Binding var bundle: StoryBundle
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var storyData: StoryViewModel
    var body: some View {

        Text(bundle.name)
                    .font(.system(size: 12))
                    .fontWeight(.heavy)
                
                    .frame(minWidth: 62, maxWidth: 62, minHeight: 62, maxHeight: 62)
                    .clipShape(Circle())
                    .padding(2)
                    .background(scheme == .dark ? .black: .gray, in: Circle())
                    .padding(3)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.red, .orange, .red, .orange]), startPoint: .top, endPoint: .bottom)
                            .clipShape(Circle())
                            .opacity(bundle.isSeen ? 0 : 1)
                            
                    )
                    .onTapGesture {
                        withAnimation{
                            bundle.isSeen = true
                            storyData.currentStory = bundle.id
                            storyData.showStory = true
                        }
                    }

    }
}




