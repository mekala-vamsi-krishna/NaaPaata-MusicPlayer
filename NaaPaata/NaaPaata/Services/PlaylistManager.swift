//
//  PlaylistManager.swift
//  NaaPaata
//
//  Created by User on 05/10/25.
//
/*
 * This shared PlaylistManager class does all thing it fetch al
 */
import Foundation
class PlaylistManager {
    static let shared = PlaylistManager()
    private let fileManager = FileManager.default
    private let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func createPlaylist(name: String) {
        let playlistURL = docsURL.appendingPathComponent("Playlists/\(name)")
        
        if !fileManager.fileExists(atPath: playlistURL.path) {
            try? fileManager.createDirectory(at: playlistURL, withIntermediateDirectories: true)
        }
    }
    
    func addSongToPlaylist(songURL: URL, playlistName: String) {
        let playlistURL = docsURL.appendingPathComponent("Playlists/\(playlistName)")
        let destinationURL = playlistURL.appendingPathComponent(songURL.lastPathComponent)
        
        // Copy song to playlist folder
        try? fileManager.copyItem(at: songURL, to: destinationURL)
    }
    
    func getSongsInPlaylist(playlistName: String) -> [URL] {
        let playlistURL = docsURL.appendingPathComponent("Playlists/\(playlistName)")
        
        do {
            return try fileManager.contentsOfDirectory(at: playlistURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "mp3" }
        } catch {
            return []
        }
    }
    func getAllPlaylists() -> [String] {
        let playlistsURL = docsURL.appendingPathComponent("Playlists")
        
        do {
            let items = try fileManager.contentsOfDirectory(at: playlistsURL, includingPropertiesForKeys: [.isDirectoryKey])
            return items.filter { item in
                let values = try? item.resourceValues(forKeys: [.isDirectoryKey])
                return values?.isDirectory == true
            }.map { $0.lastPathComponent }
        } catch {
            return []
        }
    }
    func deletePlaylist(name: String) {
        let playlistURL = docsURL.appendingPathComponent("Playlists/\(name)")
        try? fileManager.removeItem(at: playlistURL)
    }
    func removeSongFromPlaylist(songURL: URL, playlistName: String) {
        let playlistURL = docsURL.appendingPathComponent("Playlists/\(playlistName)")
        let songFileURL = playlistURL.appendingPathComponent(songURL.lastPathComponent)
        try? fileManager.removeItem(at: songFileURL)
    }
}
