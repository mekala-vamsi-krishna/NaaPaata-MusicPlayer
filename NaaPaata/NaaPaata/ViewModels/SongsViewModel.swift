//
//  SongsViewModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/17/25.
//

import Foundation
import AVFoundation
import SwiftUI

final class SongsViewModel: ObservableObject {
    private let musicManager = MusicPlayerManager.shared
    
    @Published var searchText: String = ""
    @Published var songs: [Song] = []
    var totalSongs: Int { songs.count }
    
    enum SortKey: String, CaseIterable {
        case title, artist, duration
    }
    
    @AppStorage("songsSortOption") var currentSort: SortKey = .title

    var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return songs }
        return songs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }

    @Published var isLoading: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSongDeleted), name: .songDeleted, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Function to play within search results
    func playFromSearchResults(_ song: Song) {
        let results = filteredSongs
        musicManager.playFromAllSongs(results, startAt: song)
    }
    
    @objc private func handleSongDeleted(notification: Notification) {
        guard let song = notification.userInfo?["song"] as? Song else { return }
        
        DispatchQueue.main.async {
            // Remove the song from the list
            if let index = self.songs.firstIndex(where: { $0.url == song.url }) {
                self.songs.remove(at: index)
            }
        }
    }

    func loadSongs() {
        // 1. Load from cache first for instant UI
        if songs.isEmpty {
            if let cachedSongs = SongCacheService.shared.loadSongs(), !cachedSongs.isEmpty {
                self.songs = cachedSongs
                self.sortSongs(by: self.currentSort)
                // Don't set isLoading = true if we have cached data
            } else {
                isLoading = true
            }
        }
        
        // 2. Perform background sync to check for file changes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let loader = LoadAllSongsFromDocuments()
            let urls = loader.loadSongsFromDocuments()
            
            let loadedSongs = urls.map { url -> Song in
                let asset = AVAsset(url: url)
                let metadata = asset.commonMetadata
                
                // Extract title
                let title = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: .common).first?.stringValue ?? url.lastPathComponent
                
                // Extract artist
                let artist = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: .common).first?.stringValue ?? "Unknown Artist"
                
                // Extract duration
                let duration = CMTimeGetSeconds(asset.duration)
                
                // Extract artwork
                var artwork: UIImage? = nil
                if let data = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyArtwork, keySpace: .common).first?.dataValue {
                    artwork = UIImage(data: data)
                }
                
                return Song(
                    url: url,
                    title: title,
                    artist: artist,
                    duration: duration,
                    artworkImage: artwork
                )
            }
            
            DispatchQueue.main.async {
                // Check if the loaded songs are different from current songs
                // We compare counts or sets of URLs to decide if update is needed
                // For simplicity and correctness, we'll update if the list is different
                
                let currentURLs = Set(self.songs.map { $0.url })
                let newURLs = Set(loadedSongs.map { $0.url })
                
                if currentURLs != newURLs || self.songs.isEmpty {
                    self.songs = loadedSongs
                    self.sortSongs(by: self.currentSort)
                    // Save to cache
                    SongCacheService.shared.saveSongs(loadedSongs)
                }
                
                self.isLoading = false
            }
        }
    }
    
    // Shuffle songs
    func shuffleSongs() -> [Song] {
        songs.shuffled()
    }
    
    // Sort songs (by title or artist)
    func sortSongs(by key: SortKey) {
        switch key {
        case .title: songs.sort { $0.title < $1.title }
        case .artist: songs.sort { $0.artist < $1.artist }
        case .duration: songs.sort { $0.duration < $1.duration }
        }
        // Update the current sort option
        currentSort = key
    }
    
    func play(_ song: Song) {
        musicManager.playFromAllSongs(songs, startAt: song, fromPlaylist: "All Songs")
    }
    
    func playAll() {
        musicManager.playFromAllSongs(songs, fromPlaylist: "All Songs")
    }
    
    func playShuffled() {
        // Play all songs first to set the original playlist
        musicManager.playFromAllSongs(songs, fromPlaylist: "All Songs")
        
        // Then toggle shuffle mode to shuffle the playlist while starting from the current song
        musicManager.toggleShuffle()
    }
    
    // Call this after delete or whenever manager changes
    func refresh() {
        loadSongs()
    }
}
