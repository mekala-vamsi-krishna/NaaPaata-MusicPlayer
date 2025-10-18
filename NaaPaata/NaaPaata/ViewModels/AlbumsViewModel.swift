//
//  AlbumsViewModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/18/25.
//

import SwiftUI
import AVFoundation

class AlbumsViewModel: ObservableObject {
    @Published var albums: [Album] = []
    
    func loadAlbums() {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let musicFolder = docsURL.appendingPathComponent("Music", isDirectory: true)
        
        // Ensure folder exists
        if !fileManager.fileExists(atPath: musicFolder.path) {
            try? fileManager.createDirectory(at: musicFolder, withIntermediateDirectories: true)
        }
        
        // Load all MP3 files
        let files = (try? fileManager.contentsOfDirectory(at: musicFolder,
                                                          includingPropertiesForKeys: nil,
                                                          options: [.skipsHiddenFiles])) ?? []
        let mp3Files = files.filter { $0.pathExtension.lowercased() == "mp3" }
        
        var albumMap: [String: Album] = [:]
        
        for fileURL in mp3Files {
            let asset = AVAsset(url: fileURL)
            
            // Extract metadata
            let title = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                     withKey: AVMetadataKey.commonKeyTitle,
                                                     keySpace: .common).first?.stringValue ?? fileURL.lastPathComponent
            
            let artist = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                      withKey: AVMetadataKey.commonKeyArtist,
                                                      keySpace: .common).first?.stringValue ?? "Unknown Artist"
            
            let duration = CMTimeGetSeconds(asset.duration)
            
            var artwork: UIImage? = nil
            if let artData = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                         withKey: AVMetadataKey.commonKeyArtwork,
                                                         keySpace: .common).first?.dataValue {
                artwork = UIImage(data: artData)
            }
            
            let albumName = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                         withKey: AVMetadataKey.commonKeyAlbumName,
                                                         keySpace: .common).first?.stringValue ?? "Unknown Album"
            
            // ✅ Use UIImage? for artworkImage
            let song = Song(url: fileURL, title: title, artist: artist, duration: duration, artworkImage: artwork)
            
            if albumMap[albumName] == nil {
                albumMap[albumName] = Album(name: albumName, artworkImage: artwork, songs: [song])
            } else {
                albumMap[albumName]?.songs.append(song)
            }
        }
        
        DispatchQueue.main.async {
            self.albums = Array(albumMap.values).sorted { $0.name < $1.name }
        }
    }
}


