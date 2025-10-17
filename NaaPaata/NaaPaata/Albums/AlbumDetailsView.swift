//
//  AlbumDetailsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation

struct SongMetadata: Identifiable {
    let id = UUID()
    let url: URL
    let title: String
    let artist: String
    let duration: TimeInterval
    let artwork: UIImage?
}

struct AlbumDetailsView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    
    @State private var songMetadataList: [SongMetadata] = []

    var title: String
    var artwork: UIImage?
    var songs: [URL]
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showFullPlayer = false

    @Namespace private var animation
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.4), Color.orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header with parallax artwork
                    GeometryReader { geo in
                        let offset = geo.frame(in: .global).minY
                        let height: CGFloat = 400
                        let width = geo.size.width
                        
                        ZStack(alignment: .bottom) {
                            // Main artwork with parallax
                            if let artwork = artwork {
                                Image(uiImage: artwork)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: height + (offset > 0 ? offset : 0))
                                    .clipped()
                                    .offset(y: offset > 0 ? -offset : 0)
                                    .blur(radius: max(0, -offset / 50))
                            } else {
                                Rectangle()
                                    .fill(LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: width, height: height + (offset > 0 ? offset : 0))
                                    .offset(y: offset > 0 ? -offset : 0)
                            }
                            
                            // Gradient overlay for smooth transition
                            LinearGradient(
                                colors: [.clear, .clear, .black.opacity(0.3), .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(width: width)
                            
                            // Floating album card
                            VStack(spacing: 0) {
                                Spacer()
                                
                                albumCard
                                    .offset(y: 80)
                                    .scaleEffect(max(0.8, 1 - (-offset / 1000)))
                            }
                            .frame(width: width)
                        }
                        .frame(width: width, height: height)
                    }
                    .frame(height: 500)
                    
                    // Content section
                    VStack(spacing: 24) {
                        // Album info
                        VStack(spacing: 12) {
                            Text(title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 16) {
                                Label(songs.count == 1 ? "1 Song" : "\(songs.count ) songs", systemImage: "music.note.list")
                                Text("•")
                                Label("52 min", systemImage: "clock")
                            }
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Action buttons
                        HStack(spacing: 16) {
                            Button {
                                musicPlayerManager.playFromAlbum(songs)
                                showFullPlayer = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Play All")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            
                            Button {
                                let shuffled = songs.shuffled()
                                musicPlayerManager.playFromAlbum(shuffled)
                                showFullPlayer = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Shuffle")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(AppColors.primary.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Songs list with glassmorphic design
                        VStack(spacing: 0) {
                            ForEach(songMetadataList) { song in
                                SongRow(
                                    song: song.title,
                                    index: songMetadataList.firstIndex(where: { $0.id == song.id })! + 1,
                                    artistName: song.artist,
                                    duration: song.duration,
                                    isSelected: musicPlayerManager.currentTrack == song.url && musicPlayerManager.isPlaying
                                )
                                .onTapGesture {
                                    musicPlayerManager.playFromAlbum(songs, startAt: song.url)
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
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            loadAllMetadata()
        }

    }
    
    private func loadAllMetadata() {
        songMetadataList = songs.map { url in
            let asset = AVAsset(url: url)
            var artist = "Unknown Artist"
            var title = url.deletingPathExtension().lastPathComponent
            var artwork: UIImage? = nil
            
            // Extract metadata synchronously
            for item in asset.commonMetadata {
                guard let key = item.commonKey else { continue }
                
                switch key {
                case .commonKeyArtist:
                    if let value = item.stringValue { artist = value }
                case .commonKeyTitle:
                    if let value = item.stringValue { title = value }
                case .commonKeyArtwork:
                    if let data = item.dataValue, let image = UIImage(data: data) {
                        artwork = image
                    }
                default:
                    break
                }
            }
            
            let duration = CMTimeGetSeconds(asset.duration)
            return SongMetadata(url: url, title: title, artist: artist, duration: duration.isFinite ? duration : 0, artwork: artwork)
        }
    }
    
    private var albumCard: some View {
        VStack {
            if let artwork = artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 20)
            }
        }
    }
}

struct SongRow: View {
    let song: String
    let index: Int
    let artistName: String
    let duration: Double
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Track number with animated gradient
            ZStack {
                if isSelected {
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundColor(.white)
                } else {
                    Text("\(index)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32)
                }
            }
            .frame(width: 32)
            
            // Song title
            VStack(alignment: .leading, spacing: 4) {
                Text(song)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(artistName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Duration and menu
            HStack(spacing: 12) {
                Text("\(formatTime(duration))")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                Button {
                    // More options
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            isSelected ? Color.black.opacity(0.1) : Color.clear
        )
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
