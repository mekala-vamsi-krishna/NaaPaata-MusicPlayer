//
//  AlbumsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct Album: Identifiable {
    let id = UUID()
    let name: String
    var artworkImage: UIImage?
    var files: [URL]
}

struct AlbumsView: View {
    @State private var albums: [Album] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    ForEach(albums) { album in
                        NavigationLink {
                            AlbumDetailsView(
                                title: album.name,
                                artwork: album.artworkImage,
                                songs: album.files.map { $0.lastPathComponent }
                            )
                        } label: {
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
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 6)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .background(AppColors.background.ignoresSafeArea())
            .onAppear {
                loadAlbumsFromMusicFiles()
            }
        }
    }
    
    private func loadAlbumsFromMusicFiles() {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension.lowercased() == "mp3" }
            
            var albumMap: [String: Album] = [:]
            
            for fileURL in files {
                let asset = AVAsset(url: fileURL)
                var albumName = "Unknown Album"
                var artwork: UIImage? = nil
                
                for meta in asset.commonMetadata {
                    if meta.commonKey?.rawValue == "albumName",
                       let name = meta.stringValue {
                        albumName = name
                    }
                    
                    if meta.commonKey?.rawValue == "artwork",
                       let data = meta.value as? Data,
                       let img = UIImage(data: data) {
                        artwork = img
                    }
                }
                
                if albumMap[albumName] == nil {
                    albumMap[albumName] = Album(name: albumName, artworkImage: artwork, files: [fileURL])
                } else {
                    albumMap[albumName]?.files.append(fileURL)
                }
            }
            
            self.albums = Array(albumMap.values).sorted { $0.name < $1.name }
            
        } catch {
            print("Error reading files: \(error)")
        }
    }
}


#Preview {
    AlbumsView()
}
