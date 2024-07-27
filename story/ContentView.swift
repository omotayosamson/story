//
//  ContentView.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  

    var body: some View {
        GeometryReader{
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            Home(size: size, safeArea: safeArea)
                .ignoresSafeArea(.container, edges: .all)
        }
    }

 
}

#Preview {
    ContentView()

}
