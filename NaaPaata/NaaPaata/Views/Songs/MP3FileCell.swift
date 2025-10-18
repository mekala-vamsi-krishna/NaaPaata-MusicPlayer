//
//  MP3FileCell.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MP3FileCell: View {
    let song: Song
    @EnvironmentObject var musicManager: MusicPlayerManager

    var body: some View {
        HStack(spacing: 15) {
            // Artwork
            Image(uiImage: musicManager.getArtwork(for: song) ?? song.artworkImage ?? UIImage(systemName: "music.note")!)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Song details
            VStack(alignment: .leading, spacing: 4) {
                Text(song.displayName)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Now Playing Indicator
            if musicManager.currentSong == song {
                EqualizerBars()
                    .frame(width: 20, height: 20)
            }
        }
    }
}


struct EqualizerBars: View {
    @State private var heights: [CGFloat] = [5, 10, 7]
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<heights.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.purple)
                    .frame(width: 3, height: heights[i])
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.25)) {
                heights = heights.map { _ in CGFloat(Int.random(in: 5...15)) }
            }
        }
    }
}





