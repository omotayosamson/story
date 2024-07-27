//
//  StoryView.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI

struct StoryView: View {
    @EnvironmentObject var storyData: StoryViewModel
    var body: some View {
        if storyData.showStory{
            
            TabView(selection: $storyData.currentStory,
                    content:  {
                
                ForEach($storyData.stories){$bundle in
                    StoryCardView(bundle: $bundle)
                        .environmentObject(storyData)
                }
                
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            
            
            .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    ContentView()
}

//struct StoryView_Preview: PreviewProvider{
//    static let storyData = StoryViewModel()
//    static var previews: some View{
//        StoryView()
//            .environmentObject(storyData)
//    }
//}


struct StoryCardView: View {
    @Binding var bundle: StoryBundle
    @EnvironmentObject var storyData: StoryViewModel
    
    // Timer & changinging the stories based on timer..
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    //progress...
    @State var timerProgress: CGFloat = 0
    
    var body: some View {
         
//For 3D Rotation
        GeometryReader{proxy in
            ZStack{
                
                
                //Getting current index.....
                //and updating data....
                
                let index = min(Int(timerProgress), bundle.stories.count - 1)
                
                
                    Image(bundle.stories[index].videoURL)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            
            //tapping to next & prev
            
            .overlay(
                HStack{
                    Rectangle()
                        .fill(.black.opacity(0.01))
                        .onTapGesture {
                            if (timerProgress - 1) < 0{
                                //update to previous bundle
                                updateStory(forward: false)
                            }else{
                                //update to previous Story...
                                timerProgress = CGFloat(Int(timerProgress - 1))
                            }
                        }
                    Rectangle()
                        .fill(.black.opacity(0.01))
                        .onTapGesture {
                            //checking anf updating to the next
                            
                            if(timerProgress + 1) > CGFloat(bundle.stories.count){
                                //update to next bundle
                                updateStory()
                            }else{
                                //update to next Story...
                                timerProgress = CGFloat(Int(timerProgress + 1))
                            }
                        }
                }
            )
            .overlay(
                Button(action: {
                    withAnimation{
                        storyData.showStory = false
                    }
                    
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.white)
                })
                .padding()
                ,alignment: .topTrailing
            )
            
            //Top timer capsule
            
            .overlay(
                HStack(spacing: 5){
                    ForEach(bundle.stories.indices){index in
                        GeometryReader{proxy in
                            let width = proxy.size.width
                            
                            //getting progress by eliminating current index with progress so that the remaining will be 0 when the previous story is loading
                            
                            //setting max to 1
                            //min to 0...
                            //for perfect timer..
                            
                            
                            let progress = timerProgress - CGFloat(index)
                            
                            let perfectProgress = min(max(progress, 0), 1)
                            
                            
                            Capsule()
                            .fill(.gray.opacity(0.5))
                            .overlay(
                            Capsule()
                                .fill(.white)
                                .frame(width: width * perfectProgress)
                            
                            ,alignment: .leading
                            )
                        }
                    }
                }
                    .frame(height: 1.4)
                    .padding(.horizontal)
                ,alignment: .top
            )
            
            .rotation3DEffect(
                getAngle(proxy: proxy),
                axis: (x: 0, y: 1, z: 0),
                anchor: proxy.frame(in: .global).minX > 0 ?
                    .leading: .trailing,
                perspective: 2.5
            )
            
        }
        
        //Restting Timer...
        .onAppear(perform: {
            timerProgress = 0
        })
        .onReceive(timer, perform: { _ in
            //updating seen status in real time
            if storyData.currentStory == bundle.id{
                if !bundle.isSeen{
                    bundle.isSeen = true
                }
                
                //updating timer..
                
                if timerProgress < CGFloat(bundle.stories.count){
                    timerProgress += 0.03
                }else{
                    updateStory()
                }
            }
        })
        
        
    }
    
    //updating on End...
    
    func updateStory(forward: Bool = true){
        let index = min(Int(timerProgress), bundle.stories.count - 1)
        
        let story = bundle.stories[index]
        
        if !forward{
            
            //if its not first then moving backward...
            //else set timer to 0...
            if let first = storyData.stories.first, first.id != bundle.id{
                //getting Index...
                let bundleIndex = storyData.stories.firstIndex{
                    currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                withAnimation{
                    storyData.currentStory = storyData.stories[bundleIndex - 1].id
                }
            }else{
                timerProgress = 0
            }
                
            return
        }
        
        //checking in its last ....
        
        if let last = bundle.stories.last, last.id == story.id{
            //if there's another story then move to that...
            //else close the view....
            if let lastBundle = storyData.stories.last,lastBundle.id == bundle.id{
                
                //closing...
                withAnimation{
                    storyData.showStory = false
                }
                
            }
            else{
                //updating to next one..
                let bundleIndex = storyData.stories.firstIndex { currentBundle in
                    return bundle.id == currentBundle.id
                } ?? 0
                
                withAnimation{
                    storyData.currentStory = storyData.stories[bundleIndex + 1].id
                }
            }
        }
    }
    
    func getAngle(proxy: GeometryProxy)->Angle{
        
        //convering offset into 45 degrees rotation
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}
