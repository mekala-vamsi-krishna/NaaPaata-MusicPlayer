//
//  PlaybackStateService.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/9/25.
//
import Foundation

class PlaybackStateService {
    private let userDefaults = UserDefaults.standard
    private let playbackStateKey = "LastPlaybackState"
    
    static let shared = PlaybackStateService()
    
    private init() {}
    
    func savePlaybackState(_ state: PlaybackState) {
        do {
            let data = try JSONEncoder().encode(state)
            userDefaults.set(data, forKey: playbackStateKey)
        } catch {
            print("Error saving playback state: \(error)")
        }
    }
    
    func loadPlaybackState() -> PlaybackState? {
        guard let data = userDefaults.data(forKey: playbackStateKey) else { return nil }
        
        do {
            return try JSONDecoder().decode(PlaybackState.self, from: data)
        } catch {
            print("Error loading playback state: \(error)")
            return nil
        }
    }
    
    func clearPlaybackState() {
        userDefaults.removeObject(forKey: playbackStateKey)
    }
}
