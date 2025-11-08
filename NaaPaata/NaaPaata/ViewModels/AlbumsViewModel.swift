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

    enum SortKey {
        case name, artist, dateAdded, dateModified, size
    }

    func loadAlbums() {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let musicFolder = docsURL.appendingPathComponent("Music", isDirectory: true)

        if !fileManager.fileExists(atPath: musicFolder.path) {
            try? fileManager.createDirectory(at: musicFolder, withIntermediateDirectories: true)
        }

        // Recursively find all MP3 files
        let enumerator = fileManager.enumerator(at: musicFolder,
                                                includingPropertiesForKeys: [.isRegularFileKey],
                                                options: [.skipsHiddenFiles, .skipsPackageDescendants])
        var mp3Files: [URL] = []
        while let fileURL = enumerator?.nextObject() as? URL {
            if fileURL.pathExtension.lowercased() == "mp3" {
                mp3Files.append(fileURL)
            }
        }

        var albumMap: [String: Album] = [:]

        for fileURL in mp3Files {
            let asset = AVAsset(url: fileURL)
            
            let title = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                     withKey: AVMetadataKey.commonKeyTitle,
                                                     keySpace: .common).first?.stringValue ?? fileURL.deletingPathExtension().lastPathComponent
            
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
            
            let song = Song(url: fileURL, title: title, artist: artist, duration: duration, artworkImage: artwork)

            if albumMap[albumName] == nil {
                // Folder attributes
                let folderURL = fileURL.deletingLastPathComponent()
                let folderAttributes = try? FileManager.default.attributesOfItem(atPath: folderURL.path)
                let dateAdded = folderAttributes?[.creationDate] as? Date ?? Date()
                let dateModified = folderAttributes?[.modificationDate] as? Date ?? Date()
                
                albumMap[albumName] = Album(
                    name: albumName,
                    artworkImage: artwork,
                    songs: [song],
                    dateAdded: dateAdded,
                    dateModified: dateModified
                )
            } else {
                albumMap[albumName]?.songs.append(song)
            }
        }

        DispatchQueue.main.async {
            self.albums = Array(albumMap.values)
            // Sort albums by name by default
            self.sortAlbums(by: .name)
        }
    }

    func sortAlbums(by key: SortKey) {
        switch key {
        case .name:
            albums.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .artist:
            albums.sort {
                let artist1 = $0.songs.first?.artist ?? ""
                let artist2 = $1.songs.first?.artist ?? ""
                return artist1.localizedCaseInsensitiveCompare(artist2) == .orderedAscending
            }
        case .dateAdded:
            albums.sort { $0.dateAdded < $1.dateAdded }
        case .dateModified:
            albums.sort { $0.dateModified < $1.dateModified }
        case .size:
            albums.sort { $0.songs.count > $1.songs.count }
        }
    }
}

