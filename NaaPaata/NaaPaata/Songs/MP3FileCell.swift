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
            extractMetadata()
        }
    }
    
    private func extractMetadata() {
        let asset = AVAsset(url: fileURL)
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "artwork",
               let data = meta.value as? Data,
               let img = UIImage(data: data) {
                artworkImage = img
            }
            if meta.commonKey?.rawValue == "artist",
               let artist = meta.stringValue {
                artistName = artist
            }
        }
    }
}
