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
        // Use the playlist's name as the identifier to ensure there's only one file per playlist
        // Sanitize the name to make it a valid filename
        let sanitizedName = sanitizeFileName(playlist.name)
        let url = playlistsDir.appendingPathComponent("\(sanitizedName).json")
        do {
            let data = try JSONEncoder().encode(playlist)
            try data.write(to: url)
        } catch {
            print("Error saving playlist \(playlist.name): \(error.localizedDescription)")
        }
    }
    
    // Helper to sanitize playlist names for use as filenames
    private func sanitizeFileName(_ name: String) -> String {
        // Replace invalid characters for filenames with underscores
        let invalidChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
        var sanitizedName = ""
        for char in name.unicodeScalars {
            if invalidChars.contains(char) {
                sanitizedName += "_"
            } else {
                sanitizedName += String(char)
            }
        }
        // Remove any trailing spaces or periods that might cause issues
        sanitizedName = sanitizedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return sanitizedName.isEmpty ? "unnamed_playlist" : sanitizedName
    }
    
    // MARK: - Load All Playlist Names
    func getAllPlaylists() -> [String] {
        guard let files = try? fileManager.contentsOfDirectory(at: playlistsDir, includingPropertiesForKeys: nil)
        else { return [] }
        
        // For each JSON file, load the playlist to get its name
        var playlistNames: [String] = []
        for fileURL in files {
            if fileURL.pathExtension.lowercased() == "json" {
                if let playlist = try? JSONDecoder().decode(Playlist.self, from: Data(contentsOf: fileURL)) {
                    playlistNames.append(playlist.name)
                }
            }
        }
        return Array(Set(playlistNames)) // Use Set to ensure unique names only
    }
    
    // MARK: - Get Songs in Playlist
    func getSongsInPlaylist(playlistName: String) -> [URL] {
        guard let playlist = loadPlaylist(name: playlistName) else { return [] }
        return playlist.songs.map { $0.url }
    }
    
    // MARK: - Load Playlist
    func loadPlaylist(name: String) -> Playlist? {
        // Use the playlist name to load the specific file
        let sanitizedName = sanitizeFileName(name)
        let url = playlistsDir.appendingPathComponent("\(sanitizedName).json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(Playlist.self, from: data)
    }
    
    // MARK: - Delete Playlist
    func deletePlaylist(name: String) {
        let sanitizedName = sanitizeFileName(name)
        let url = playlistsDir.appendingPathComponent("\(sanitizedName).json")
        
        // Check if the file exists before attempting to remove
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
