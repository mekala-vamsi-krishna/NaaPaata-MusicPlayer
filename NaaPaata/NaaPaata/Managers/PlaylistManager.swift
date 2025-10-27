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

final class PlaylistManager {
    static let shared = PlaylistManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    private var playlistsDir: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("Playlists", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    // MARK: - Create Playlist
    func createPlaylist(name: String) {
        let playlist = Playlist(
            name: name,
            songs: [],
            description: "",
            isPrivate: false,
            dateCreated: Date()
        )
        savePlaylist(playlist)
    }
    
    // MARK: - Save Playlist to JSON
    func savePlaylist(_ playlist: Playlist) {
        let url = playlistsDir.appendingPathComponent("\(playlist.name).json")
        do {
            let data = try JSONEncoder().encode(playlist)
            try data.write(to: url)
        } catch {
            print("Error saving playlist \(playlist.name): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load All Playlist Names
    func getAllPlaylists() -> [String] {
        guard let files = try? fileManager.contentsOfDirectory(at: playlistsDir, includingPropertiesForKeys: nil)
        else { return [] }
        return files.map { $0.deletingPathExtension().lastPathComponent }
    }
    
    // MARK: - Get Songs in Playlist
    func getSongsInPlaylist(playlistName: String) -> [URL] {
        guard let playlist = loadPlaylist(name: playlistName) else { return [] }
        return playlist.songs.map { $0.url }
    }
    
    // MARK: - Load Playlist
    func loadPlaylist(name: String) -> Playlist? {
        let url = playlistsDir.appendingPathComponent("\(name).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Playlist.self, from: data)
    }
    
    // MARK: - Delete Playlist
    func deletePlaylist(name: String) {
        let url = playlistsDir.appendingPathComponent("\(name).json")
        try? fileManager.removeItem(at: url)
    }
}
