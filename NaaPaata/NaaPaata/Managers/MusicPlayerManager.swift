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
    
    // MARK: - Repeat Mode
    private var repeatMode: RepeatMode = .none
    enum RepeatMode {
        case none, one, all
    }
    
    // MARK: - Shuffle State
    private var isShuffleActive: Bool = false
    private var originalAllSongs: [Song] = [] // Store original order when shuffle is toggled on
    
    var allSongs: [Song] = []  // This will always be the original playlist
    private var shuffledPlaylist: [Song] = [] // This will store the shuffled playlist when shuffle is active
    private var playQueue: [Song] = []
    private var currentIndex: Int = 0
    
    private override init() {
        super.init()
    }
    
    // MARK: - Computed Properties
    private var currentPlaylist: [Song] {
        // When repeat mode is active (single or all), use original order 
        // according to the requirement: "songs should be played one by one without shuffle"
        if repeatMode != .none {
            // Repeat is active, always use original order
            if playQueue.isEmpty {
                return allSongs
            } else {
                return playQueue
            }
        } else {
            // No repeat, use shuffled playlist if shuffle is active
            if playQueue.isEmpty {
                return isShuffleActive ? (shuffledPlaylist.isEmpty ? allSongs : shuffledPlaylist) : allSongs
            } else {
                return playQueue
            }
        }
    }
    
    var currentSongArtwork: UIImage? {
        // Use already stored artwork from the song object to avoid repeated extraction
        guard let song = currentSong else { return nil }
        if let storedArtwork = song.artworkImage {
            return storedArtwork
        } else {
            // Fallback to extracting artwork from URL if not stored
            return getArtwork(for: song)
        }
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
            // Use the artwork already stored in the song object instead of extracting again
            artworkImage = song.artworkImage
            startTimer()
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
    
    func playFromAllSongs(_ songs: [Song], startAt song: Song? = nil) {
        allSongs = songs
        originalAllSongs = songs  // Store original playlist
        // When loading new playlist, reset shuffle state and shuffled playlist
        shuffledPlaylist = []
        isShuffleActive = false
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
            // Update currentIndex to match the song in the original list
            if let originalIndex = allSongs.firstIndex(of: nextSong) {
                currentIndex = originalIndex
            } else {
                currentIndex = allSongs.firstIndex(of: nextSong) ?? currentIndex
            }
            playSong(nextSong)
        } else if !allSongs.isEmpty {
            // When repeat mode is active, always use original order regardless of shuffle state
            // According to requirement: "songs should be played one by one without shuffle"
            let playlistToUse = (repeatMode != .none) ? allSongs : 
                              (isShuffleActive ? (shuffledPlaylist.isEmpty ? allSongs : shuffledPlaylist) : allSongs)
            
            switch repeatMode {
            case .all:
                currentIndex = (currentIndex + 1) % playlistToUse.count
                let nextSong = playlistToUse[currentIndex]
                playSong(nextSong)
            case .one:
                // For one repeat, play the same song again
                if let current = currentSong {
                    playSong(current)
                }
            case .none:
                // For no repeat, go to next song but stop if at the end
                if currentIndex < playlistToUse.count - 1 {
                    currentIndex += 1
                    let nextSong = playlistToUse[currentIndex]
                    playSong(nextSong)
                }
                // If at the end, do nothing (the song will stop naturally)
            }
        }
    }
    
    func playPrevious() {
        // When repeat mode is active, always use original order regardless of shuffle state
        let playlistToUse = (repeatMode != .none) ? allSongs : 
                          (isShuffleActive ? (shuffledPlaylist.isEmpty ? allSongs : shuffledPlaylist) : allSongs)
        guard !playlistToUse.isEmpty else { return }
        if repeatMode == .one {
            // For one repeat, restart current song instead of going to previous
            if let current = currentSong {
                playSong(current) // This will restart the current song
            }
        } else {
            // For none and all repeat modes, go to previous song
            currentIndex = (currentIndex - 1 + playlistToUse.count) % playlistToUse.count
            playSong(playlistToUse[currentIndex])
        }
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
        // Store original playlist
        allSongs = playlist
        originalAllSongs = playlist  // Store original order
        
        // Enable shuffle mode
        isShuffleActive = true
        
        // If there's a current song, put it at the beginning and shuffle the rest
        if let currentSong = currentSong {
            var songsToShuffle = playlist.filter { $0 != currentSong }
            songsToShuffle = songsToShuffle.shuffled()
            songsToShuffle.insert(currentSong, at: 0)
            shuffledPlaylist = songsToShuffle
            currentIndex = 0
        } else {
            // If no current song, just shuffle the playlist
            shuffledPlaylist = playlist.shuffled()
            currentIndex = 0
        }
        
        playQueue = []
        if let songToPlay = isShuffleActive ? shuffledPlaylist.first : allSongs.first {
            playSong(songToPlay)
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
        
        switch repeatMode {
        case .none:
            playNext()
        case .one:
            // Replay the same song by playing it again through the manager
            if let current = currentSong {
                playSong(current)
            }
        case .all:
            playNext()
        }
    }
    
    // MARK: - Repeat Mode
    func toggleRepeatMode() {
        // If shuffle is active, disable it when enabling repeat
        if isShuffleActive {
            isShuffleActive = false
        }
        
        switch repeatMode {
        case .none:
            // When enabling repeat, start with repeat one
            repeatMode = .one
        case .one:
            // When switching from repeat one to repeat all
            repeatMode = .all
        case .all:
            // When switching from repeat all to none (turn off)
            repeatMode = .none
        }
    }
    
    // New method to specifically toggle repeat all mode
    func toggleRepeatAll() {
        // If shuffle is active, disable it when enabling repeat
        if isShuffleActive {
            isShuffleActive = false
        }
        
        switch repeatMode {
        case .none:
            // When enabling repeat all, switch to all mode
            repeatMode = .all
        case .all:
            // When disabling repeat all, turn off repeat
            repeatMode = .none
        case .one:
            // When switching from repeat one to repeat all
            repeatMode = .all
        }
    }
    
    // New method to specifically toggle repeat one mode
    func toggleRepeatOne() {
        // If shuffle is active, disable it when enabling repeat
        if isShuffleActive {
            isShuffleActive = false
        }
        
        switch repeatMode {
        case .none:
            // When enabling repeat one, switch to one mode
            repeatMode = .one
        case .one:
            // When disabling repeat one, turn off repeat
            repeatMode = .none
        case .all:
            // When switching from repeat all to repeat one
            repeatMode = .one
        }
    }
    
    // Helper function to disable shuffle while preserving the current song at its position
    private func disableShufflePreservingCurrentSong() {
        // Simply turn off shuffle flag, which will cause the player to use the original allSongs
        isShuffleActive = false
    }
    
    var currentRepeatMode: RepeatMode {
        return repeatMode
    }
    
    func setRepeatMode(_ mode: RepeatMode) {
        repeatMode = mode
    }
    
    var shuffleIsActive: Bool {
        return isShuffleActive
    }
    
    func toggleShuffle() {
        // If any repeat mode is active, turn it off when shuffle is enabled
        if repeatMode != .none {
            repeatMode = .none
        }
        
        if isShuffleActive {
            // Turning shuffle OFF: just deactivate shuffle flag
            isShuffleActive = false
        } else {
            // Turning shuffle ON: create shuffled playlist while keeping current song as first
            if let currentSong = currentSong, !allSongs.isEmpty {
                var songsToShuffle = allSongs.filter { $0 != currentSong }
                songsToShuffle = songsToShuffle.shuffled()
                songsToShuffle.insert(currentSong, at: 0)
                shuffledPlaylist = songsToShuffle
                currentIndex = 0
            } else if !allSongs.isEmpty {
                // If no current song, shuffle the existing allSongs
                shuffledPlaylist = allSongs.shuffled()
                currentIndex = 0
            }
            isShuffleActive = true
        }
    }
    
    // MARK: - Artwork Extraction
    func getArtwork(for song: Song) -> UIImage {
        // Return the artwork if already available in the song object
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
    
    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = time
        currentTime = time
    }

}

