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
    @Published var searchText: String = ""

    enum SortKey: String, CaseIterable {
        case name, artist, dateAddedAscending, dateAddedDescending, dateModified, size
    }
    
    @AppStorage("albumsSortOption") var currentSort: SortKey = .name

    @Published var isLoading: Bool = false
    
    var filteredAlbums: [Album] {
        guard !searchText.isEmpty else { return albums }
        return albums.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.songs.contains(where: { $0.artist.localizedCaseInsensitiveContains(searchText) })
        }
    }


    func loadAlbums() {
        // Cache check: if we already have albums, don't reload
        guard albums.isEmpty else { return }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
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
                // Sort albums by the saved sort option
                self.sortAlbums(by: self.currentSort)
                self.isLoading = false
            }
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
        case .dateAddedAscending:
            albums.sort { $0.dateAdded < $1.dateAdded }
        case .dateAddedDescending:
            albums.sort { $0.dateAdded > $1.dateAdded }
        case .dateModified:
            albums.sort { $0.dateModified < $1.dateModified }
        case .size:
            albums.sort { $0.songs.count > $1.songs.count }
        }
        // Update the current sort option
        currentSort = key
    }
}

