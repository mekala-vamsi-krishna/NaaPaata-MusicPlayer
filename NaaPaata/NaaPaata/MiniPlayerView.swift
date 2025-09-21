//
//  MiniPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    
    var body: some View {
        HStack {
            Image(uiImage: musicPlayerManager.artworkImage ?? UIImage(systemName: "music.note")!)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .cornerRadius(6)
            
            Text(musicPlayerManager.currentTitle ?? "Unknown Song")
                .font(.subheadline)
                .lineLimit(1)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button {
                    // Previous button
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                }
                
                Button {
                    musicPlayerManager.togglePlayPause()
                } label: {
                    Image(systemName: musicPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                }
                
                Button {
                    // Next button
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                }

            }
            
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.bottom, 4) // sits above tab bar
    }
}


#Preview {
    MiniPlayerView()
}
