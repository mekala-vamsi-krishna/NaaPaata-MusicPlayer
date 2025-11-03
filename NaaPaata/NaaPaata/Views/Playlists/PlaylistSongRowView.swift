//
//  PlaylistSongRowView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI
import AVFoundation

struct PlaylistSongRowView: View {
    @EnvironmentObject var musicManager: MusicPlayerManager
    
    let song: Song
    let editMode: EditMode
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    // Share Properties
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    func loadArtwork(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        if let artData = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                     withKey: AVMetadataKey.commonKeyArtwork,
                                                     keySpace: .common).first?.dataValue {
            return UIImage(data: artData)
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Delete button in edit mode
            if editMode == .active {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Artwork
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                
                Image(uiImage: song.artworkImage ?? loadArtwork(from: song.url) ?? UIImage(systemName: "music.note")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            
            // Song title and artist
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title.isEmpty ? song.url.lastPathComponent : song.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if musicManager.currentSong == song {
                EqualizerBars()
                    .frame(width: 20, height: 20)
            }
            
            if editMode == .inactive {
                HStack(spacing: 12) {
                    Text(formatDuration(song.duration))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .monospacedDigit()
                    
                    Menu {
                        Button(action: onPlay) {
                            Label("Play Now", systemImage: "play.fill")
                        }
                        
                        Button(action: {
                            musicManager.addToQueueNext(song)
                        }) {
                            Label("Play Next", systemImage: "text.insert")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            shareItems = [song.url]
                            showShareSheet = true
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Remove", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                }
            } else {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            if editMode == .inactive {
                onPlay()
            }
        }
        // Share Sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: shareItems)
                .presentationDetents([.fraction(0.4)])
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

