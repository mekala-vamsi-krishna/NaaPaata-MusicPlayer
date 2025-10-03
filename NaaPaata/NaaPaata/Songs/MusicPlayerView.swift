//
//  MusicPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .padding()
                }
                Spacer()
            }
            
            Spacer()
            
            Image(uiImage: musicPlayerManager.artworkImage ?? UIImage(systemName: "opticaldisc")!)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding()
            
            Text(musicPlayerManager.currentTitle ?? "Unknown Title")
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Custom Progress Bar
            VStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background bar
                        Capsule()
                            .fill(AppColors.cardBackground)
                            .frame(height: 6)

                        // Filled progress
                        Capsule()
                            .fill(AppColors.primary)
                            .frame(width: progressWidth(totalWidth: geometry.size.width),
                                   height: 6)

                        // Draggable knob
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 14, height: 14)
                            .offset(x: progressWidth(totalWidth: geometry.size.width) - 7)
                    }
                }
                .frame(height: 20)
                .padding(.horizontal)

                // Time labels
                HStack {
                    Text(formatTime(musicPlayerManager.currentTime))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    Text(formatTime(musicPlayerManager.duration))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 20)
            }
            
            HStack(spacing: 60) {
                Button(action: { /* prev */ }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: {
                    musicPlayerManager.togglePlayPause()
                }) {
                    Image(systemName: musicPlayerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                }
                
                Button(action: { /* next */ }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppColors.primary)
                }
            }
            
            Spacer()
        }
    }
    
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard musicPlayerManager.duration > 0 else { return 0 }
        let progress = CGFloat(musicPlayerManager.currentTime / musicPlayerManager.duration)
        return totalWidth * progress
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

}

#Preview {
    MusicPlayerView()
}
