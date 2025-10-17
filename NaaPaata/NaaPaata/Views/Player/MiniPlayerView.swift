//
//  MiniPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Artwork with subtle shadow
            Image(uiImage: musicPlayerManager.artworkImage ?? UIImage(systemName: "music.note")!)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Capsule(style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Song Info
            VStack(alignment: .leading, spacing: 2) {
                Text(musicPlayerManager.currentTitle ?? "Unknown Song")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(musicPlayerManager.artistName ?? "Unknown Artist")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 8)
            
            // Playback Controls
            HStack(spacing: 20) {
                Button {
                    musicPlayerManager.togglePlayPause()
                } label: {
                    Image(systemName: musicPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
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
        .background {
            // Modern iOS material with proper blur
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -2)
        }
        .overlay(alignment: .top) {
            // Subtle top separator line
            Capsule(style: .continuous)
                .stroke(.quaternary, lineWidth: 0.5)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}


#Preview {
    MiniPlayerView()
        .environmentObject(MusicPlayerManager())
}
