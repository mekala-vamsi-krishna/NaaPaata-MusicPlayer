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
    
    // MARK: - Create Playlist (Deprecated - use savePlaylist directly)
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
        // Use the playlist's UUID to ensure uniqueness
        let fileName = playlist.id.uuidString
        let url = playlistsDir.appendingPathComponent("\(fileName).json")
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
        
        // For each JSON file, load the playlist to get its name
        // Use a Set to ensure unique names only
        var playlistNames: Set<String> = []
        for fileURL in files {
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            // Only process files that look like UUIDs (36 chars with hyphens)
            if fileName.count == 36 && fileName.contains("-") {
                if let playlist = loadPlaylist(byID: fileName) {
                    playlistNames.insert(playlist.name)
                }
            }
        }
        return Array(playlistNames)
    }
    
    // MARK: - Load Playlist by ID (for internal use)
    private func loadPlaylist(byID id: String) -> Playlist? {
        let url = playlistsDir.appendingPathComponent("\(id).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Playlist.self, from: data)
    }
    
    // MARK: - Get Songs in Playlist
    func getSongsInPlaylist(playlistName: String) -> [URL] {
        guard let playlist = loadPlaylist(name: playlistName) else { return [] }
        return playlist.songs.map { $0.url }
    }
    
    // MARK: - Load Playlist
    func loadPlaylist(name: String) -> Playlist? {
        // Search for the playlist with the given name across all files
        let playlistFiles = (try? fileManager.contentsOfDirectory(at: playlistsDir, includingPropertiesForKeys: nil)) ?? []
        
        for fileURL in playlistFiles {
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            // Only process files that look like UUIDs (36 chars with hyphens)
            if fileName.count == 36 && fileName.contains("-") {
                if let playlist = try? JSONDecoder().decode(Playlist.self, from: Data(contentsOf: fileURL)),
                   playlist.name == name {
                    return playlist
                }
            }
        }
        return nil
    }
    
    // MARK: - Delete Playlist
    func deletePlaylist(name: String) {
        // Search for the file containing the playlist with the given name
        let playlistFiles = (try? fileManager.contentsOfDirectory(at: playlistsDir, includingPropertiesForKeys: nil)) ?? []
        
        for fileURL in playlistFiles {
            let fileName = fileURL.deletingPathExtension().lastPathComponent
            // Only process files that look like UUIDs (36 chars with hyphens)
            if fileName.count == 36 && fileName.contains("-") {
                if let playlist = try? JSONDecoder().decode(Playlist.self, from: Data(contentsOf: fileURL)),
                   playlist.name == name {
                    try? fileManager.removeItem(at: fileURL)
                    return
                }
            }
        }
    }
}
