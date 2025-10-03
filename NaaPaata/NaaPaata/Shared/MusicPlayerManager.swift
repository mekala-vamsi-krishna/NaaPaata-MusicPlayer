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
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    func playTrack(_ url: URL) {
        currentTrack = url
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
        currentTrack = nil
        artworkImage = nil
        currentTitle = nil
        stopTimer()
    }
    
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
        }
        if currentTitle == nil {
            currentTitle = url.lastPathComponent
        }
    }
}

