//
//  PlaylistViewModel.swift
//  NaaPaata
//
//  Created by User on 06/10/25.
//

import SwiftUI
import AVFoundation

final class PlaylistsViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var isLoading: Bool = true  // Track loading state
    @Published var favoriteSongs: Set<URL> = [] // Track favorite song URLs for quick access
    
    let playlistManager = PlaylistManager.shared
    
    init() {
        loadPlaylists()
        isLoading = false
    }
    
    func loadPlaylists() {
        // Prevent reloading if already loaded to avoid lag on tab switch
        if !playlists.isEmpty {
            return
        }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let playlistNames = self.playlistManager.getAllPlaylists()
            
            // Create a dictionary to ensure each playlist name only appears once
            var uniquePlaylists: [UUID: Playlist] = [:]
            
            // Get current available songs from cache or documents
            // Use SongCacheService to avoid re-scanning files
            let availableSongs = SongCacheService.shared.loadSongs() ?? self.getSongsFromDocumentsDirectory()
            
            for name in playlistNames {
                // Load the playlist from JSON which contains the full playlist with songs
                guard let savedPlaylist = self.playlistManager.loadPlaylist(name: name) else { continue }
                
                // Skip if we've already processed this playlist (by UUID)
                if uniquePlaylists[savedPlaylist.id] != nil {
                    continue
                }
                
                // Match playlist songs with currently available songs
                // Use a more robust matching method, comparing by file path components
                var validSongs: [Song] = []
                for playlistSong in savedPlaylist.songs {
                    // First try exact URL match
                    if let currentSong = availableSongs.first(where: { $0.url == playlistSong.url }) {
                        validSongs.append(currentSong)
                    } else {
                        // If exact match fails, try matching by file name and path components
                        let playlistFileName = playlistSong.url.lastPathComponent
                        if let currentSong = availableSongs.first(where: { $0.url.lastPathComponent == playlistFileName }) {
                            validSongs.append(currentSong)
                        }
                    }
                }
                
                let playlist = Playlist(
                    name: savedPlaylist.name,
                    songs: validSongs,
                    coverImage: savedPlaylist.coverImage,
                    description: savedPlaylist.description,
                    isPrivate: savedPlaylist.isPrivate,
                    dateCreated: savedPlaylist.dateCreated
                )
                
                uniquePlaylists[savedPlaylist.id] = playlist
            }
            
            // Convert the dictionary values to an array
            let loadedPlaylists = Array(uniquePlaylists.values)
            
            DispatchQueue.main.async {
                self.playlists = loadedPlaylists
                
                // Update favoriteSongs set for quick access
                if let favPlaylist = self.playlists.first(where: { $0.name == "Favorites" }) {
                    self.favoriteSongs = Set(favPlaylist.songs.map { $0.url })
                }
                
                self.isLoading = false
            }
        }
    }
    
    // Helper function to get current songs from documents directory
    // Kept as fallback if cache is empty
    private func getSongsFromDocumentsDirectory() -> [Song] {
        let loader = LoadAllSongsFromDocuments()
        let urls = loader.loadSongsFromDocuments()
        
        return urls.map { url in
            let asset = AVAsset(url: url)
            let metadata = asset.commonMetadata
            
            // Extract title
            let title = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: .common).first?.stringValue ?? url.lastPathComponent
            
            // Extract artist
            let artist = AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.commonKeyArtist, keySpace: .common).first?.stringValue ?? "Unknown Artist"
            
            // Extract duration
            let duration = CMTimeGetSeconds(asset.duration)
            
            // Extract artwork
            var artwork: UIImage? = nil
            if let artworkData = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                             withKey: AVMetadataKey.commonKeyArtwork,
                                                             keySpace: .common).first?.dataValue {
                artwork = UIImage(data: artworkData)
            }
            
            return Song(
                url: url,
                title: title,
                artist: artist,
                duration: duration,
                artworkImage: artwork,
                dateAdded: Date()
            )
        }
    }
    
    func addPlaylist(name: String, description: String = "") {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Check for duplicate names and modify if needed
        var uniqueName = trimmedName
        var counter = 1
        while playlists.contains(where: { $0.name == uniqueName }) {
            uniqueName = "\(trimmedName)(\(counter))"
            counter += 1
        }
        
        let newPlaylist = Playlist(
            name: uniqueName,
            songs: [],
            coverImage: UIImage(systemName: "music.note.list"),
            description: description,
            isPrivate: false,
            dateCreated: Date()
        )
        
        playlistManager.savePlaylist(newPlaylist) // Save to file first
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            playlists.insert(newPlaylist, at: 0)
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlistManager.deletePlaylist(name: playlist.name)
        playlists.removeAll { $0.id == playlist.id }
    }
    
    func updatePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index] = playlist
            playlistManager.savePlaylist(playlist) // Persist changes to JSON
        }
    }
    
    // MARK: - Favorites Functions
    func isSongInFavorites(_ song: Song) -> Bool {
        return favoriteSongs.contains(song.url)
    }
    
    func toggleFavoriteSong(_ song: Song) {
        let isCurrentlyFavorited = isSongInFavorites(song)
        
        if let favPlaylist = playlistManager.loadPlaylist(name: "Favorites") {
            var updatedPlaylist = favPlaylist
            if isCurrentlyFavorited {
                // Remove from favorites using URL comparison
                updatedPlaylist.songs.removeAll { $0.url == song.url }
                
                // If the favorites playlist is now empty, we might want to delete it
                // or just keep it for future use - let's keep it for now
            } else {
                // Add to favorites - but check if the song with the same URL already exists in the playlist
                // and update with the current song's data instead of duplicating
                let existingIndex = updatedPlaylist.songs.firstIndex { $0.url == song.url }
                if let index = existingIndex {
                    // Replace the existing song with the current one to update metadata
                    updatedPlaylist.songs[index] = song
                } else {
                    // Add the song if it doesn't exist
                    updatedPlaylist.songs.append(song)
                }
            }
            playlistManager.savePlaylist(updatedPlaylist)
            // Update the favoriteSongs set to reflect the change
            if isCurrentlyFavorited {
                self.favoriteSongs.remove(song.url)
            } else {
                self.favoriteSongs.insert(song.url)
            }
            // Refresh all playlists to ensure UI updates properly
            DispatchQueue.main.async {
                self.refreshPlaylists()
            }
        } else {
            // Create favorites playlist and add the song
            let newFavPlaylist = Playlist(
                name: "Favorites",
                songs: [song],
                coverImage: UIImage(systemName: "heart.fill"),
                description: "Your favorite songs",
                isPrivate: false,
                dateCreated: Date()
            )
            playlistManager.savePlaylist(newFavPlaylist)
            // Update the favoriteSongs set to reflect the change
            self.favoriteSongs.insert(song.url)
            // Refresh all playlists to ensure UI updates properly
            DispatchQueue.main.async {
                self.refreshPlaylists()
            }
        }
    }
    
    func getFavoritesPlaylist() -> Playlist? {
        return playlistManager.loadPlaylist(name: "Favorites")
    }
    
    // Refresh playlists to ensure UI updates properly
    func refreshPlaylists() {
        loadPlaylists()
    }
    
    // MARK: - Helper: Extract metadata from URL
    private func extractSongMetadata(from url: URL) -> Song {
        let asset = AVAsset(url: url)
        
        let title = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                 withKey: AVMetadataKey.commonKeyTitle,
                                                 keySpace: .common).first?.stringValue ?? url.deletingPathExtension().lastPathComponent
        
        let artist = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                  withKey: AVMetadataKey.commonKeyArtist,
                                                  keySpace: .common).first?.stringValue ?? "Unknown Artist"
        
        let duration = CMTimeGetSeconds(asset.duration)
        
        var artwork: UIImage? = nil
        if let artData = AVMetadataItem.metadataItems(from: asset.commonMetadata,
                                                     withKey: AVMetadataKey.commonKeyArtwork,
                                                     keySpace: .common).first?.dataValue {
            artwork = UIImage(data: artData)
        }
        
        return Song(
            url: url,
            title: title,
            artist: artist,
            duration: duration,
            artworkImage: artwork,
            dateAdded: Date()
        )
    }
}

