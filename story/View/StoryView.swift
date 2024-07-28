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
                    .containerRelativeFrame(.horizontal)
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

    @State private var player: AVPlayer?
    @State private var playerObserver: Any?
    @State private var currentVideoDuration: CGFloat = 1.0
    @State private var timerProgress: [CGFloat] = []
    @State private var currentStoryIndex: Int = 0
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var size: CGSize
    var safeArea: EdgeInsets

    var body: some View {
        GeometryReader { proxy in
            let rect = proxy.frame(in: .scrollView(axis: .horizontal))

            CustomVideoPlayer(player: $player)
                .preference(key: OffsetKey.self, value: rect)
                .onPreferenceChange(OffsetKey.self) { value in
                    playPause(value)
                }
                .overlay(alignment: .bottom) {
                    StoryDetailsView()
                }
                .onAppear {
                    setupPlayer()
                }
                .onDisappear {
                    cleanUpPlayer()
                }
                .overlay(tapOverlay, alignment: .center)
                .overlay(closeButton, alignment: .topTrailing)
                .overlay(progressBar, alignment: .top)
                .rotation3DEffect(
                    getAngle(proxy: proxy),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                    perspective: 2.5
                )
        }
        .onReceive(timer) {_ in
                //update seen status in real time
            
            if storyData.currentStory == bundle.id{
                if !bundle.isSeen{
                    bundle.isSeen = true
                }
            }
            
            
        }
        .onAppear {
            resetProgress()
            currentStoryIndex = 0
        }
    }

    private var tapOverlay: some View {
        HStack {
            Rectangle()
                .fill(Color.black.opacity(0.01))
                .onTapGesture {
                    handleTap(forward: false)
                }
            Rectangle()
                .fill(Color.black.opacity(0.01))
                .onTapGesture {
                    handleTap(forward: true)
                }
        }
        .onLongPressGesture(minimumDuration: .infinity) { isPressing in
            if isPressing {
                player?.pause()
            } else {
                player?.play()
            }
        } perform: {
            player?.pause()
        }
    }

    private var closeButton: some View {
        Button(action: {
            withAnimation {
                storyData.showStory = false
            }
        }, label: {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.white)
        })
        .padding()
    }

    private var progressBar: some View {
        HStack(spacing: 5) {
            ForEach(bundle.stories.indices, id: \.self) { index in
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let progress = index < timerProgress.count ? timerProgress[index] : 0.0
                    let perfectProgress = min(max(progress, 0), 1)

                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .overlay(
                            Capsule()
                                .fill(Color.white)
                                .frame(width: width * perfectProgress),
                            alignment: .leading
                        )
                }
            }
        }
        .frame(height: 1.4)
        .padding(.horizontal)
    }

    private func playPause(_ rect: CGRect) {
        if -rect.minX < (rect.width * 0.5) && rect.minX < (rect.width * 0.5) {
            player?.play()
        } else {
            player?.pause()
        }
        if rect.minX >= size.width || -rect.minX >= size.width {
            player?.seek(to: .zero)
        }
    }

    private func setupPlayer() {
        guard currentStoryIndex < bundle.stories.count else {
            withAnimation {
                storyData.showStory = false
            }
            return
        }

        guard let bundleID = Bundle.main.path(forResource: bundle.stories[currentStoryIndex].videoURL, ofType: "mp4") else { return }
        let videoURL = URL(fileURLWithPath: bundleID)

        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        player?.play()

        currentVideoDuration = CGFloat(CMTimeGetSeconds(playerItem.asset.duration))

        playerObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
            let currentTime = CMTimeGetSeconds(time)
            if currentTime > 0 {
                self.timerProgress[self.currentStoryIndex] = CGFloat(currentTime / Double(self.currentVideoDuration))
            }
            if self.timerProgress[self.currentStoryIndex] >= 1.0 {
                self.updateStory()
            }
        }
    }

    private func cleanUpPlayer() {
        if let observer = playerObserver {
            player?.removeTimeObserver(observer)
            playerObserver = nil
        }
        player?.pause()
        player = nil
    }

    private func handleTap(forward: Bool) {
        if forward {
            if currentStoryIndex + 1 < bundle.stories.count {
                currentStoryIndex += 1
                setupPlayer()
            } else {
                updateStory()
            }
        } else {
            if currentStoryIndex - 1 >= 0 {
                currentStoryIndex -= 1
                setupPlayer()
            } else {
                updateStory(forward: false)
            }
        }
    }

    private func updateStory(forward: Bool = true) {
        if forward {
            if currentStoryIndex + 1 < bundle.stories.count {
                currentStoryIndex += 1
                setupPlayer()
            } else {
                if let lastBundle = storyData.stories.last, lastBundle.id == bundle.id {
                    withAnimation {
                        storyData.showStory = false
                    }
                } else {
                    let bundleIndex = storyData.stories.firstIndex { $0.id == bundle.id } ?? 0
                    withAnimation {
                        storyData.currentStory = storyData.stories[bundleIndex + 1].id
                    }
                }
            }
        } else {
            if currentStoryIndex - 1 >= 0 {
                currentStoryIndex -= 1
                setupPlayer()
            } else {
                if let firstBundle = storyData.stories.first, firstBundle.id == bundle.id {
                    setupPlayer()
                } else {
                    let bundleIndex = storyData.stories.firstIndex { $0.id == bundle.id } ?? 0
                    withAnimation {
                        storyData.currentStory = storyData.stories[bundleIndex - 1].id
                    }
                }
            }
        }
    }

    private func resetProgress() {
        timerProgress = Array(repeating: 0, count: bundle.stories.count)
    }

    private func getAngle(proxy: GeometryProxy) -> Angle {
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        return Angle(degrees: Double(degrees))
    }

    @ViewBuilder
    private func StoryDetailsView() -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("player")
                    .font(.callout)
                    .lineLimit(1)
                    .foregroundColor(.white)
                
                Text("Lorem Ipsum is a dummy text of the printing and typesetting industry")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .clipped()
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .padding(.bottom, safeArea.bottom + 15)
    }
}



