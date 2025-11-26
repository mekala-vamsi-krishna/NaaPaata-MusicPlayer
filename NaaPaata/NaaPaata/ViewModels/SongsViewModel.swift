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
    
    // Function to play within search results
    func playFromSearchResults(_ song: Song) {
        let results = filteredSongs
        musicManager.playFromAllSongs(results, startAt: song)
    }

    func loadSongs() {
        guard songs.isEmpty else { return } // Prevent reloading if already loaded
        
        isLoading = true
        
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
                
                return Song(
                    url: url,
                    title: title,
                    artist: artist,
                    duration: duration
                )
            }
            
            DispatchQueue.main.async {
                self.songs = loadedSongs
                self.sortSongs(by: self.currentSort)
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
