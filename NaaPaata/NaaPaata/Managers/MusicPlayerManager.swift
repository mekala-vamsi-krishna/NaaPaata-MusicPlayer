//
//  MusicPlayerManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation

final class MusicPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = MusicPlayerManager()
    
    // MARK: - Published Properties
    @Published var artworkImage: UIImage?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentSong: Song?
    
    // MARK: - Private Properties
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    private var allSongs: [Song] = []
    private var playQueue: [Song] = []
    private var currentIndex: Int = 0
    
    private override init() {
        super.init()
    }
    
    // MARK: - Computed Properties
    private var currentPlaylist: [Song] {
        playQueue.isEmpty ? allSongs : playQueue
    }
    
    var currentSongArtwork: UIImage? {
        guard let song = currentSong else { return nil }
        return getArtwork(for: song)
    }
    
    // MARK: - Playback Methods
    func playSong(_ song: Song) {
        currentSong = song
        
        do {
            player = try AVAudioPlayer(contentsOf: song.url)
            player?.delegate = self
            player?.play()
            isPlaying = true
            duration = player?.duration ?? 0
            artworkImage = currentSongArtwork
            startTimer()
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
    
    func playFromAllSongs(_ songs: [Song], startAt song: Song? = nil) {
        allSongs = songs
        playQueue = []

        // Determine the starting song
        if let startSong = song {
            currentSong = startSong
            if let index = songs.firstIndex(of: startSong) {
                currentIndex = index
                playSong(startSong)
            } else {
                // Song not in the list, fallback to first song
                currentIndex = 0
                if let first = songs.first {
                    currentSong = first
                    playSong(first)
                }
            }
        } else if let first = songs.first {
            currentSong = first
            currentIndex = 0
            playSong(first)
        }
    }
    
    // MARK: - Play Next in Queue
    func addToQueueNext(_ song: Song) {
        guard !allSongs.isEmpty else {
            playQueue = [song]
            return
        }

        let safeIndex = (0..<allSongs.count).contains(currentIndex)
            ? currentIndex
            : -1

        let remaining: [Song]
        if safeIndex >= 0 && safeIndex + 1 < allSongs.count {
            remaining = Array(allSongs[(safeIndex + 1)...])
        } else {
            remaining = []
        }

        playQueue = remaining
        playQueue.insert(song, at: 0)
    }
    
    func playNext() {
        // If there's a queue, play the first song in it
        if !playQueue.isEmpty {
            let nextSong = playQueue.removeFirst()
            currentIndex = allSongs.firstIndex(of: nextSong) ?? currentIndex
            playSong(nextSong)
        } else if !allSongs.isEmpty {
            currentIndex = (currentIndex + 1) % allSongs.count
            playSong(allSongs[currentIndex])
        }
    }
    
    func playPrevious() {
        guard !currentPlaylist.isEmpty else { return }
        currentIndex = (currentIndex - 1 + currentPlaylist.count) % currentPlaylist.count
        playSong(currentPlaylist[currentIndex])
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentSong = nil
        artworkImage = nil
        stopTimer()
    }
    
    // MARK: - Shuffle
    func shufflePlay(playlist: [Song]) {
        allSongs = playlist.shuffled()
        playQueue = []
        currentIndex = 0
        if let first = allSongs.first {
            playSong(first)
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player = self.player else { return }
            self.currentTime = player.currentTime
            self.duration = player.duration
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        playNext()
    }
    
    // MARK: - Artwork Extraction
    func getArtwork(for song: Song) -> UIImage {
        // Return the artwork if already available
        if let artwork = song.artworkImage {
            return artwork
        }
        
        // Otherwise, try to extract from metadata
        let asset = AVAsset(url: song.url)
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "artwork",
               let data = meta.value as? Data,
               let image = UIImage(data: data) {
                return image
            }
        }
        
        // Fallback system image
        return UIImage(systemName: "music.note")!
    }
    
    func loadSong(from url: URL) -> Song {
        let asset = AVAsset(url: url)
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var duration: TimeInterval = 0
        var artwork: UIImage? = nil // Use UIImage directly

        duration = CMTimeGetSeconds(asset.duration)
        
        for item in asset.commonMetadata {
            guard let key = item.commonKey else { continue }
            switch key {
            case .commonKeyTitle:
                if let value = item.stringValue { title = value }
            case .commonKeyArtist:
                if let value = item.stringValue { artist = value }
            case .commonKeyArtwork:
                if let data = item.dataValue, let image = UIImage(data: data) {
                    artwork = image
                }
            default: break
            }
        }

        return Song(url: url, title: title, artist: artist, duration: duration, artworkImage: artwork)
    }
    
    func delete(song: Song) {
        // Stop playback if currently playing
        if currentSong == song {
            stop()
        }
        
        // Remove from allSongs and playQueue
        allSongs.removeAll { $0 == song }
        playQueue.removeAll { $0 == song }
        
        // Remove file from disk
        do {
            try FileManager.default.removeItem(at: song.url)
            print("Deleted file at \(song.url.path)")
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
        
        // If needed, play next song automatically
        if !allSongs.isEmpty {
            playNext()
        }
    }

}

