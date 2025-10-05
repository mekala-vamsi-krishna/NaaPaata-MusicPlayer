//
//  MP3FileCell.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MP3FileCell: View {
    var fileURL: URL
    @State private var artworkImage: UIImage? = nil
    @State private var artistName: String = "Unknown Artist"
    @State private var songDuration: String = "" /// currenlty, duration is not displayed
    
    var body: some View {
        NavigationLink(destination: MusicPlayerView()) {
            HStack(spacing: 15) {
                Image(uiImage: artworkImage ?? UIImage(systemName: "music.note")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fileURL.lastPathComponent)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(artistName)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
        }
        .onAppear {
            Task {
                await extractMetadata()
            }
        }
    }
    
    @MainActor
    private func extractMetadata() async {
        let asset = AVAsset(url: fileURL)
        /// All this code is about fetching the meta data of each song from it's url
        let commonMetadata = (try? await asset.load(.commonMetadata)) ?? []
        for meta in commonMetadata {
            if meta.commonKey?.rawValue == "artwork" {
                if let data = try? await meta.load(.dataValue),
                   let img = UIImage(data: data) {
                    artworkImage = img
                }
            } else if meta.commonKey?.rawValue == "artist" {
                if let artist = try? await meta.load(.stringValue) {
                    artistName = artist
                }
            }
        }
        
        // Load duration from the asset itself and format it
        if let time = try? await asset.load(.duration) {
            let seconds = CMTimeGetSeconds(time)
            if seconds.isFinite {
                songDuration = formatTime(seconds) /// currenlty, duration is not displayed
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
