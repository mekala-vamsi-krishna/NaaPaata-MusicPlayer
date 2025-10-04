//
//  MusicPlayerManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/21/25.
//

import SwiftUI
import AVFoundation

class MusicPlayerManager: ObservableObject {
    @Published var currentTrack: URL?
    @Published var artworkImage: UIImage?
    @Published var currentTitle: String?
    @Published var artistName: String?
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    var trackList: [URL] = []
    private var currentIndex: Int = 0
    
    // MARK: - Play Track
    func playTrack(_ url: URL) {
        currentTrack = url
        currentIndex = trackList.firstIndex(of: url) ?? 0
        extractMetadata(from: url)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true
            duration = player?.duration ?? 0
            startTimer()
        } catch {
            print("Error playing: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Next Track
    func playNext() {
        guard !trackList.isEmpty else { return }
        currentIndex = (currentIndex + 1) % trackList.count
        playTrack(trackList[currentIndex])
    }
    
    // MARK: - Previous Track
    func playPrevious() {
        guard !trackList.isEmpty else { return }
        currentIndex = (currentIndex - 1 + trackList.count) % trackList.count
        playTrack(trackList[currentIndex])
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
}

