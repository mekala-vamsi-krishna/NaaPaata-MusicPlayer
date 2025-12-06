//
//  MiniPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI

import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Artwork - use optimized currentSongArtwork that handles fallbacks
            if let artwork = musicPlayerManager.artworkImage {
                Image(uiImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Capsule(style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(AppColors.primary)
                    .clipShape(Capsule(style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Song Info
            VStack(alignment: .leading, spacing: 2) {
                Text(musicPlayerManager.currentSong?.title ?? "Unknown Song")
                    .foregroundStyle(Color.primary)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(musicPlayerManager.currentSong?.artist ?? "Unknown Artist")
                    .foregroundStyle(Color.primary)
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            // Playback Controls
            HStack(spacing: 20) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        musicPlayerManager.togglePlayPause()
                    }
                } label: {
                    ZStack {
                        Image(systemName: "play.fill")
                            .opacity(musicPlayerManager.isPlaying ? 0 : 1)
                        Image(systemName: "pause.fill")
                            .opacity(musicPlayerManager.isPlaying ? 1 : 0)
                    }
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(AppColors.primary)
                    .foregroundColor(.white)
                    .animation(.easeInOut(duration: 0.01), value: musicPlayerManager.isPlaying)
                }
                .buttonStyle(.plain)
                
                Button {
                    musicPlayerManager.playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(.quaternary, lineWidth: 0.5),
            alignment: .top
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}


#Preview {
    MiniPlayerView()
        .environmentObject(MusicPlayerManager.shared)
}
