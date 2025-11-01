//
//  AlbumDetailsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

struct AlbumDetailsView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    
    var title: String
    var artwork: UIImage?
    var songs: [Song] // global Song model
    
    @State private var showFullPlayer = false
    
    // Helper: total album duration
    private var totalDuration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Album Header
                VStack(spacing: 8) {
                    if let artwork = artwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(radius: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .frame(width: 200, height: 200)
                    }
                    
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("\(songs.count) songs • \(formatTime(totalDuration))")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .padding(.top, 20)
                
                // Play / Shuffle Buttons
                HStack(spacing: 16) {
                    actionButton(title: "Play All", isPrimary: true) {
                        musicPlayerManager.playFromAllSongs(songs)
                        showFullPlayer = true
                    }
                    actionButton(title: "Shuffle", isPrimary: false) {
                        musicPlayerManager.playFromAllSongs(songs.shuffled())
                        showFullPlayer = true
                    }
                }
                .padding(.horizontal, 20)
                
                // Songs List
                VStack(spacing: 0) {
                    ForEach(Array(songs.enumerated()), id: \.1.id) { index, song in
                        SongRow(
                            song: song,
                            index: index + 1,
                            isSelected: musicPlayerManager.currentSong == song && musicPlayerManager.isPlaying
                        )
                        .onTapGesture {
                            musicPlayerManager.playFromAllSongs(songs, startAt: song)
                            showFullPlayer = true
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .padding(.bottom, 80) /// Adding padding to ensure the mini player dont overlap on the songs
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helpers
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(mins)m \(secs)s"
    }
    
    private func actionButton(title: String, isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isPrimary ? "play.fill" : "shuffle")
                    .font(.system(size: 18, weight: .bold))
                Text(title).font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(isPrimary ? .white : AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Group {
                    if isPrimary {
                        LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                       startPoint: .leading, endPoint: .trailing)
                    } else {
                        Capsule().fill(.ultraThinMaterial)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                !isPrimary ? Capsule().strokeBorder(AppColors.primary.opacity(0.3), lineWidth: 1.5) : nil
            )
        }
    }
}


struct SongRow: View {
    let song: Song
    let index: Int
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Track number or playing waveform
            ZStack {
                if isSelected {
                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    Text("\(index)")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32)
                }
            }
            
            // Song title and artist
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Duration
            Text(formatTime(song.duration))
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isSelected ? Color.black.opacity(0.1) : Color.clear)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}



#Preview {
    AlbumDetailsView(
        title: "Greatest Hits",
        artwork: nil,
        songs: []
    )
}
