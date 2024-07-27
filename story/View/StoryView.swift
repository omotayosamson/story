//
//  StoryView.swift
//  story
//
//  Created by omotayo ayomide on 26/07/2024.
//

import SwiftUI
import AVKit
struct StoryView: View {
    @EnvironmentObject var storyData: StoryViewModel
    var size: CGSize
    var safeArea: EdgeInsets
    var body: some View {
        if storyData.showStory{
            
            TabView(selection: $storyData.currentStory,
                    content:  {
                
                ForEach($storyData.stories){$bundle in
                    StoryCardView(
                        bundle: $bundle,
                        size: size,
                        safeArea: safeArea
                    )
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


struct StoryCardView: View {
    @Binding var bundle: StoryBundle
    @EnvironmentObject var storyData: StoryViewModel
    
    // Timer & changinging the stories based on timer..
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    //progress...
    @State var timerProgress: CGFloat = 0
    var size: CGSize
    var safeArea: EdgeInsets
    @State private var player: AVPlayer?
    @State private var looper: AVPlayerLooper?
    
    
    var body: some View {
         
//For 3D Rotation
        GeometryReader{proxy in
            
                
            let rect = proxy.frame(in: .scrollView(axis: .horizontal))
                
                CustomVideoPlayer(player: $player)
                
                    .preference(key: OffsetKey.self, value: rect)
                    .onPreferenceChange(OffsetKey.self, perform: { value in
                        playPause(value)
                    })
                    .overlay(alignment: .bottom, content: {
                        StoryDetailsView()
                    })
                
                    
                
                   
                
                    .onAppear{
                        guard player == nil else {return}
                        let index = min(Int(timerProgress), bundle.stories.count - 1)
                        guard let bundleID = Bundle.main.path(forResource: bundle.stories[index].videoURL, ofType: "mp4") else {return}
                        let videoURL = URL(filePath: bundleID)
                        
                        let playerItem = AVPlayerItem(url: videoURL)
                        let queue = AVQueuePlayer(playerItem: playerItem)
                        looper = AVPlayerLooper(player: queue, templateItem: playerItem)
                        
                        player = queue
                        
                    }
                    .onDisappear{
                        player = nil
                    }
                
                
            //}

            
            
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
                    .onLongPressGesture(minimumDuration: .infinity){ isPressing in
                        if isPressing {
                            player?.pause()
                          
                        }else{
                            player?.play()
                        }
                        
                    } perform: {
                        player?.pause()
                        
                        
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
            
            //rotatin
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
    
    
    func playPause(_ rect: CGRect){
        if -rect.minX < (rect.width * 0.5) && rect.minX < (rect.width * 0.5) {
            player?.play()
        }else{
            player?.pause()
        }
        
        if rect.minX >= size.width || -rect.minX >= size.width {
            player?.seek(to: .zero)
        }
    }
    
    //details viewbuilder
    
    @ViewBuilder
    func StoryDetailsView() -> some View {
        
        HStack(alignment: .bottom, spacing: 10){
            VStack(alignment: .leading, spacing: 8, content: {
               
                    
                    Text("player")
                        .font(.callout)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                
                Text("Lorem Ipsum is a dummy text of the printig and typesetting Industry")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .clipped()
            })
            
            Spacer(minLength: 0)
            
            
            
            
        }
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .padding(.bottom, safeArea.bottom + 15)
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
