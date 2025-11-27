//
//  MusicPlayerManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import Foundation

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
    
    var allSongs: [Song] = []  // This will be the current playlist or all songs
    private var shuffledPlaylist: [Song] = [] // This will store the shuffled playlist when shuffle is active
    private var playQueue: [Song] = []
    private var currentIndex: Int = 0
    private var currentPlaylistName: String? = nil // Track the source playlist
    private var isPlayingFromPlaylist: Bool = false // Track if we're currently playing from a specific playlist
    
    // Cache for artwork to improve scrolling performance
    private let artworkCache = NSCache<NSString, UIImage>()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .began {
            player?.pause()
            isPlaying = false
        } else if type == .ended {
            player?.play()
            isPlaying = true
            updateNowPlayingInfo()
        }
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
        
        // ✅ 1️⃣ Setup audio session BEFORE player init
        setupAudioSession()
        
        do {
            player = try AVAudioPlayer(contentsOf: song.url)
            player?.delegate = self
            
            // ✅ 2️⃣ Setup lock screen controls BEFORE playback
            setupRemoteTransportControls()
            
            player?.prepareToPlay()
            player?.play()
            
            isPlaying = true
            duration = player?.duration ?? 0
            artworkImage = song.artworkImage  // ✅ before updating Now Playing
            
            updateNowPlayingInfo()            // ✅ after artwork assigned
            startTimer()
            
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
        
        updateNowPlayingInfo()
    }
    
    func playFromAllSongs(_ songs: [Song], startAt song: Song? = nil, fromPlaylist playlistName: String? = nil) {
        allSongs = songs
        originalAllSongs = songs  // Store original playlist
        // When loading new playlist, reset shuffle state and shuffled playlist
        shuffledPlaylist = []
        isShuffleActive = false
        playQueue = []
        currentPlaylistName = playlistName // Track which playlist we're playing from
        isPlayingFromPlaylist = (playlistName != nil) // Set flag based on whether playlist name is provided

        // Determine the starting song
        if let startSong = song {
            currentSong = startSong
            // Use URL-based comparison instead of object identity since Song UUIDs are auto-generated
            if let index = songs.firstIndex(where: { $0.url == startSong.url }) {
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
            // Use URL-based comparison instead of object identity
            if let originalIndex = allSongs.firstIndex(where: { $0.url == nextSong.url }) {
                currentIndex = originalIndex
            } else {
                currentIndex = allSongs.firstIndex(where: { $0.url == nextSong.url }) ?? currentIndex
            }
            playSong(nextSong)
        } else if !allSongs.isEmpty {
            // Use shuffled playlist if shuffle is active, otherwise use original order
            // Repeat mode doesn't override shuffle - both can coexist
            let playlistToUse = isShuffleActive ? (shuffledPlaylist.isEmpty ? allSongs : shuffledPlaylist) : allSongs
            
            switch repeatMode {
            case .all:
                // For all repeat, go to next song and wrap around to the beginning
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
        // Use shuffled playlist if shuffle is active, otherwise use original order
        let playlistToUse = isShuffleActive ? (shuffledPlaylist.isEmpty ? allSongs : shuffledPlaylist) : allSongs
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
        
        updateNowPlayingInfo()
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        currentSong = nil
        artworkImage = nil
        stopTimer()
        // Clear the saved playback state when playback is stopped
        PlaybackStateService.shared.clearPlaybackState()
    }
    
    // MARK: - Shuffle
    func shufflePlay(playlist: [Song], fromPlaylist playlistName: String? = nil) {
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
        
        currentPlaylistName = playlistName // Track which playlist we're playing from
        isPlayingFromPlaylist = (playlistName != nil) // Set flag based on whether playlist name is provided
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
            self.updateNowPlayingProgress()
                self.updateNowPlayingInfo()
            
            // Update lock screen progress
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime

        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Persistent Playback State Methods
    func saveCurrentPlaybackState() {
        guard let currentSong = currentSong else { return }
        
        let playbackState = PlaybackState(
            song: currentSong,
            position: currentTime,
            isPlaying: isPlaying
        )
        PlaybackStateService.shared.savePlaybackState(playbackState)
    }
    
    func restoreLastPlaybackState() {
        guard let playbackState = PlaybackStateService.shared.loadPlaybackState() else { return }
        
        // Check if the file still exists
        guard let songURL = URL(string: playbackState.songURL),
              FileManager.default.fileExists(atPath: songURL.path) else {
            // If the file doesn't exist, clear the saved state
            PlaybackStateService.shared.clearPlaybackState()
            return
        }
        
        // Create a song object with the restored state
        let restoredSong = Song(
            url: songURL,
            title: playbackState.songTitle,
            artist: playbackState.songArtist,
            duration: 0, // Duration will be updated when loaded
            artworkImage: playbackState.artworkData != nil ? UIImage(data: playbackState.artworkData!) : nil
        )
        
        // Play the song and seek to the saved position
        playSong(restoredSong)
        
        // Update playback position after a short delay to ensure player is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if playbackState.playbackPosition > 0 {
                self.seek(to: playbackState.playbackPosition)
            }
            
            // Keep the song paused when app opens, regardless of previous state
            // Only seek to the position but don't resume playback
            if self.isPlaying {
                self.togglePlayPause()  // Pause if it starts playing automatically
            }
        }
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
        
        updateNowPlayingInfo()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(error?.localizedDescription ?? "Unknown error")")
        // Clear the saved playback state if there's an error with the current song
        PlaybackStateService.shared.clearPlaybackState()
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
        
        // Fallback custom image
        return generateDefaultArtwork()
    }
    
    func loadArtworkAsync(for song: Song) async -> UIImage {
        // Check cache first
        let key = song.url.absoluteString as NSString
        if let cached = artworkCache.object(forKey: key) {
            return cached
        }
        
        // Check song object
        if let artwork = song.artworkImage {
            artworkCache.setObject(artwork, forKey: key)
            return artwork
        }
        
        // Extract from file asynchronously
        return await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return UIImage(systemName: "music.note")! }
            
            let asset = AVAsset(url: song.url)
            var image: UIImage?
            
            let metadata = try? await asset.load(.commonMetadata)
            if let metadata = metadata {
                for meta in metadata {
                    if meta.commonKey?.rawValue == "artwork",
                       let data = try? await meta.load(.value) as? Data,
                       let img = UIImage(data: data) {
                        image = img
                        break
                    }
                }
            }
            
            let result = image ?? self.generateDefaultArtwork()
            self.artworkCache.setObject(result, forKey: key)
            return result
        }.value
    }
    
    private func generateDefaultArtwork() -> UIImage {
        let size = CGSize(width: 500, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Draw Gradient Background
            let colors = [UIColor(AppColors.primary).cgColor, UIColor(AppColors.primary).cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Draw Music Note Symbol
            if let symbolImage = UIImage(systemName: "music.note")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
                let symbolSize = CGSize(width: size.width * 0.5, height: size.height * 0.5)
                let symbolOrigin = CGPoint(
                    x: (size.width - symbolSize.width) / 2,
                    y: (size.height - symbolSize.height) / 2
                )
                symbolImage.draw(in: CGRect(origin: symbolOrigin, size: symbolSize))
            }
        }
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
            // Clear the saved playback state if this was the current song
            PlaybackStateService.shared.clearPlaybackState()
        }
        
        // Remove from allSongs and playQueue
        allSongs.removeAll { $0 == song }
        playQueue.removeAll { $0 == song }
        
        // Remove file from disk
        do {
            try FileManager.default.removeItem(at: song.url)
            print("Deleted file at \(song.url.path)")
            
            // Notify listeners that a song has been deleted
            NotificationCenter.default.post(
                name: .songDeleted,
                object: nil,
                userInfo: ["song": song]
            )
            
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
        updateNowPlayingInfo()
    }

}

extension Notification.Name {
    static let songDeleted = Notification.Name("songDeleted")
}

// MARK: - Lock Screen (Now Playing)
extension MusicPlayerManager {
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("Audio Session Error: \(error.localizedDescription)") }
    }
    
    private func updateNowPlayingInfo() {
        guard let song = currentSong, let player = player else { return }
        
        var info: [String : Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyPlaybackDuration: player.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        if let img = currentSong?.artworkImage {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 600, height: 600)) { _ in img }
            info[MPMediaItemPropertyArtwork] = artwork
        } else {
            let fallback = UIImage(systemName: "music.note")!
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 600, height: 600)) { _ in fallback }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        if let img = song.artworkImage {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateNowPlayingProgress() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
    }
    
    private func setupRemoteTransportControls() {
        let cc = MPRemoteCommandCenter.shared()
        
        cc.playCommand.isEnabled = true
        cc.pauseCommand.isEnabled = true
        cc.nextTrackCommand.isEnabled = true
        cc.previousTrackCommand.isEnabled = true
        cc.changePlaybackPositionCommand.isEnabled = true
        
        cc.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            self?.isPlaying = true
            self?.updateNowPlayingInfo()
            return .success
        }
        
        cc.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let player = self.player,
                  let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            player.currentTime = positionEvent.positionTime
            self.updateNowPlayingInfo()
            return .success
        }
        
        cc.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            self?.isPlaying = false
            self?.updateNowPlayingInfo()
            return .success
        }
        
        cc.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }
        
        cc.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }
    }
}
