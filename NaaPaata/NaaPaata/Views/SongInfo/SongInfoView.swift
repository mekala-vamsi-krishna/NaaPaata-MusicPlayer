//
//  SongInfoView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/20/25.
//

import SwiftUI
import AVFoundation
import MobileCoreServices

struct SongInfoView: View {
    let song: Song
    
    // MARK: - Helper Computed Properties
    private var asset: AVAsset { AVAsset(url: song.url) }
    
    private var title: String { song.displayName }
    
    private var artist: String {
        metadataString(for: .commonKeyArtist) ?? song.artist
    }
    
    private var albumName: String {
        metadataString(for: .commonKeyAlbumName) ?? "Unknown Album"
    }
    
    private var albumArtist: String {
        metadataString(for: .commonKeyAlbumName) ?? "Unknown"
    }
    
    private var genre: String {
        metadataString(for: .iTunesMetadataKeyUserGenre) ?? "Unknown"
    }
    
    private var year: String {
        metadataString(for: .id3MetadataKeyOriginalReleaseYear) ?? "Unknown"
    }
    
    private var duration: String {
        let mins = Int(song.duration) / 60
        let secs = Int(song.duration) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    private var mimeType: String {
        let ext = song.url.pathExtension.lowercased()
        switch ext {
        case "mp3": return "audio/mpeg"
        case "m4a": return "audio/mp4"
        case "wav": return "audio/wav"
        default: return "Unknown"
        }
    }
    
    private var filePath: String { song.url.path }
    
    private var artwork: UIImage? {
        song.artworkImage ?? metadataData(for: .commonKeyArtwork).flatMap { UIImage(data: $0) }
    }
    
    // MARK: - Metadata Helpers
    private func metadataString(for key: AVMetadataKey) -> String? {
        AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: key, keySpace: .common)
            .first?.stringValue
    }
    
    private func metadataData(for key: AVMetadataKey) -> Data? {
        AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: key, keySpace: .common)
            .first?.dataValue
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Artwork at top
                if let uiImage = artwork {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .padding(.top, 40)
                        .padding(.horizontal)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.top, 40)
                }
                
                // Metadata Form
                VStack(spacing: 12) {
                    metadataRow(title: "Title", value: title)
                    metadataRow(title: "Artist", value: artist)
                    metadataRow(title: "Album Name", value: albumName)
                    metadataRow(title: "Album Artist", value: albumArtist)
                    metadataRow(title: "Genre", value: genre)
                    metadataRow(title: "Year", value: year)
                    metadataRow(title: "Duration", value: duration)
                    metadataRow(title: "MIME Type", value: mimeType)
                    
                    Divider()
                    
                    metadataRow(title: "Path", value: filePath)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Song Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Reusable Row
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
    }
}
