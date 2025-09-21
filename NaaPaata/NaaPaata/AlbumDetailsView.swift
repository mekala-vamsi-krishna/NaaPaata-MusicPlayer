//
//  AlbumDetailsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI

struct AlbumDetailsView: View {
    var title: String
    var artwork: UIImage?
    var songs: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    // Big Artwork (Parallax style)
                    GeometryReader { geometry in
                        (artwork.map { Image(uiImage: $0) } ?? Image("Magadheera"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width,
                                   height: max(400, 400 - geometry.frame(in: .global).minY))
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.8)]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                            .offset(y: geometry.frame(in: .global).minY > 0 ? -geometry.frame(in: .global).minY : 0)
                            .ignoresSafeArea(edges: .top) // This makes big image go into safe area
                    }
                    .frame(height: 400)

                    // Small image overlayed on big one
                    HStack(spacing: 15) {
                        (artwork.map { Image(uiImage: $0) } ?? Image("Magadheera"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .offset(y: 40) // ✅ moves it down into content, half in/half out of big img

                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.title).fontWeight(.bold)
                                .lineLimit(2)

                            Text("Album by Unknown Artist")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 60) // add bottom padding so songs list doesn’t overlap

                // Song list
                VStack(spacing: 0) {
                    ForEach(songs, id: \.self) { song in
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.purple)
                            Text(song)
                            Spacer()
                            Button {
                                print("Play \(song)")
                            } label: {
                                Image(systemName: "play.fill").foregroundColor(.purple)
                            }
                        }
                        .padding()
                        Divider()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .padding()
            }
        }
        .background(
            artwork.map {
                Image(uiImage: $0).resizable().scaledToFill()
                    .blur(radius: 40).opacity(0.4)
                    .ignoresSafeArea()
            }
        )

    }
}

#Preview {
    AlbumDetailsView(title: "Magadheera", songs: [""])
}
