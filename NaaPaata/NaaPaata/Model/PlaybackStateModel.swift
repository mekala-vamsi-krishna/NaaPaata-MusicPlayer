//
//  PlaybackStateModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/9/25.
//

import Foundation

// MARK: - Playback State Management
struct PlaybackState: Codable {
    let songURL: String
    let songTitle: String
    let songArtist: String
    let playbackPosition: TimeInterval
    let isPlaying: Bool
    let artworkData: Data?
    
    init(songURL: String, songTitle: String, songArtist: String, artworkData: Data?, position: TimeInterval, isPlaying: Bool) {
        self.songURL = songURL
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.playbackPosition = position
        self.isPlaying = isPlaying
        self.artworkData = artworkData
    }
    
    init(song: Song, position: TimeInterval, isPlaying: Bool) {
        self.songURL = song.url.absoluteString
        self.songTitle = song.title
        self.songArtist = song.artist
        self.playbackPosition = position
        self.isPlaying = isPlaying
        self.artworkData = song.artworkData
    }
}
