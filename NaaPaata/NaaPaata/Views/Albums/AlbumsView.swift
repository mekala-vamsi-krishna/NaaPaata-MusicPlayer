//
//  AlbumsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct AlbumsView: View {
    @StateObject private var viewModel = AlbumsViewModel()
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(viewModel.albums) { album in
                        NavigationLink {
                            AlbumDetailsView(
                                title: album.name,
                                artwork: album.artworkImage,
                                songs: album.songs // Pass full metadata
                            )
                        } label: {
                            AlbumCellView(album: album)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .onAppear {
                viewModel.loadAlbums()
            }
        }
    }
}

struct AlbumCellView: View {
    let album: Album
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let artwork = album.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "opticaldisc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding()
                        .foregroundColor(.gray.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                }
            }
            
            Text(album.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
        }
    }
}



#Preview {
    AlbumsView()
}
