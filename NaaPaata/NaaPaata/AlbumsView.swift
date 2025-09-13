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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(albums) { album in
                        VStack {
                            Image(uiImage: album.artworkImage ?? UIImage(systemName: "opticaldisc")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                            
                            Text(album.name)
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)
                                .padding(.top, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Albums")
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .onAppear {
                loadAlbumsFromMusicFiles()
            }
        }
    }
    
    private func loadAlbumsFromMusicFiles() {
        // Load all mp3 files from Documents directory
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "mp3" }
            
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
            
            self.albums = Array(albumMap.values)
            
        } catch {
            print("Error reading files: \(error)")
        }
    }
}

#Preview {
    AlbumsView()
}
