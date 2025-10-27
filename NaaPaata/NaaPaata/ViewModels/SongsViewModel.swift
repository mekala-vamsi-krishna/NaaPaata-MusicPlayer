//
//  SongsViewModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/17/25.
//

import Foundation
import AVFoundation

final class SongsViewModel: ObservableObject {
    private let musicManager = MusicPlayerManager.shared
    
    @Published var searchText: String = ""
    @Published var songs: [Song] = []
    var totalSongs: Int { songs.count }
    
    enum SortKey {
        case title, artist, duration
    }

    var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return songs }
        return songs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Function to play within search results
    func playFromSearchResults(_ song: Song) {
        let results = filteredSongs
        musicManager.playFromAllSongs(results, startAt: song)
    }

    func loadSongs() {
        let loader = LoadAllSongsFromDocuments()
        let urls = loader.loadSongsFromDocuments()
        
        songs = urls.map { url in
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
    }
    
    func play(_ song: Song) {
        musicManager.playFromAllSongs(songs, startAt: song)
    }
    
    func playAll() {
        musicManager.playFromAllSongs(songs)
    }
    
    func playShuffled() {
        musicManager.playFromAllSongs(songs.shuffled())
    }
    
    // Call this after delete or whenever manager changes
    func refresh() {
        loadSongs()
    }
}
