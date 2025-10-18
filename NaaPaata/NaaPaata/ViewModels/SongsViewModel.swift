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
    
    @Published var songs: [Song] = []
    var totalSongs: Int { songs.count }
    
    enum SortKey {
        case title, artist, duration
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
}
