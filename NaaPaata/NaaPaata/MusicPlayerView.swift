//
//  MusicPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    let fileURL: URL
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var artworkImage: UIImage? = nil
    @State private var songTitle: String = "Unknown Title"
    @State private var isFavorite = false
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Album Artwork Image
            Image(uiImage: artworkImage ?? UIImage(systemName: "opticaldisc")!)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding()
            
            // 🎵 Song Title and Action Buttons
            HStack {
                Text(songTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24, height: 24)
                        .padding(16)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    print("More options tapped")
                }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24, height: 24)
                        .padding(16)
                        .background(AppColors.cardBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            // Progress View with Time Labels
            VStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.cardBackground)
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(AppColors.primary)
                            .frame(width: progressWidth(totalWidth: geometry.size.width), height: 8)
                        
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 16, height: 16)
                            .offset(x: progressWidth(totalWidth: geometry.size.width) - 8)
                    }
                }
                .frame(height: 20)
                .padding(.horizontal)
                
                HStack {
                    Text(formatTime(currentTime))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
            }
            
            // Playback Controls
            HStack(spacing: 60) {
                Button(action: previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: playPauseToggle) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            Spacer()
        }
        .onAppear {
            setupAudioPlayer()
            extractMetadata()
        }
        .onReceive(timer) { _ in
            if let player = player, isPlaying {
                currentTime = player.currentTime
                duration = player.duration
            }
        }
    }
    
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        let progress = CGFloat(currentTime / duration)
        return totalWidth * progress
    }
    
    private func setupAudioPlayer() {
        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
        } catch {
            print("Failed to load audio: \(error.localizedDescription)")
        }
    }
    
    private func playPauseToggle() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    private func previousTrack() {
        print("Previous Track Action")
    }
    
    private func nextTrack() {
        print("Next Track Action")
    }
    
    private func extractMetadata() {
        let asset = AVAsset(url: fileURL)
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "artwork",
               let data = meta.value as? Data,
               let img = UIImage(data: data) {
                artworkImage = img
            }
            
            if meta.commonKey?.rawValue == "title",
               let title = meta.stringValue {
                songTitle = title
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}



#Preview {
    MusicPlayerView(fileURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!)
}
