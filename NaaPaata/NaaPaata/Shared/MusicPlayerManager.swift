//
//  MusicPlayerManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation

class MusicPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentTrack: URL?
    @Published var artworkImage: UIImage?
    @Published var currentTitle: String?
    @Published var artistName: String?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playQueue: [URL] = []
    private var activeList: [URL] { playQueue.isEmpty ? trackList : playQueue }
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    var trackList: [URL] = []
    private var currentIndex: Int = 0
    
    // MARK: - Play Track
    func playTrack(_ url: URL) {
        currentTrack = url
        currentIndex = activeList.firstIndex(of: url) ?? 0
        extractMetadata(from: url)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
            duration = player?.duration ?? 0
            startTimer()
        } catch {
            print("Error playing: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Queue Management
    /// Set a scoped play queue (e.g., an album) and optionally start at a specific track
    func setPlayQueue(_ urls: [URL], startAt startURL: URL? = nil) {
        playQueue = urls
        if let startURL = startURL, let idx = urls.firstIndex(of: startURL) {
            currentIndex = idx
            playTrack(startURL)
        } else if let first = urls.first {
            currentIndex = 0
            playTrack(first)
        }
    }

    /// Clear the scoped play queue so that navigation uses the full trackList again
    func clearPlayQueue() {
        playQueue = []
    }
    
    // MARK: - Playback Sources
    /// Play from the full Songs tab list. Sets the global trackList and clears any album queue.
    func playFromAllSongs(_ urls: [URL], startAt startURL: URL? = nil) {
        trackList = urls
        clearPlayQueue()
        if let startURL = startURL, let idx = urls.firstIndex(of: startURL) {
            currentIndex = idx
            playTrack(startURL)
        } else {
            // Do not auto-play when just setting the songs list; wait for user selection.
            currentIndex = 0
            // Leave `currentTrack` unchanged; playback will start when the user taps a song.
        }
    }

    /// Play within a specific album. Sets a scoped queue and starts from the given song or the first one.
    func playFromAlbum(_ urls: [URL], startAt startURL: URL? = nil) {
        setPlayQueue(urls, startAt: startURL)
    }
    
    // MARK: - Next Track
    func playNext() {
        let list = activeList
        guard !list.isEmpty else { return }
        currentIndex = (currentIndex + 1) % list.count
        playTrack(list[currentIndex])
    }
    
    // MARK: - Previous Track
    func playPrevious() {
        let list = activeList
        guard !list.isEmpty else { return }
        currentIndex = (currentIndex - 1 + list.count) % list.count
        playTrack(list[currentIndex])
    }
    
    // MARK: - Play/Pause
    func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    // MARK: - Stop
    func stop() {
        player?.stop()
        isPlaying = false
        currentTrack = nil
        artworkImage = nil
        currentTitle = nil
        artistName = nil
        stopTimer()
    }
    
    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let player = self.player, self.isPlaying {
                self.currentTime = player.currentTime
                self.duration = player.duration
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func extractMetadata(from url: URL) {
        artistName = nil
        let asset = AVAsset(url: url)
        for meta in asset.commonMetadata {
            if meta.commonKey?.rawValue == "artwork",
               let data = meta.value as? Data,
               let img = UIImage(data: data) {
                artworkImage = img
            }
            if meta.commonKey?.rawValue == "title" {
                currentTitle = meta.stringValue
            }
            if meta.commonKey?.rawValue == "artist" {
                artistName = meta.stringValue
            }
        }
        if currentTitle == nil {
            currentTitle = url.lastPathComponent
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        playNext()
    }
}

