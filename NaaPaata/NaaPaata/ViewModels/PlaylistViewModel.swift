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
    
    let playlistManager = PlaylistManager.shared
    
    init() {
        loadPlaylists()
    }
    
    func loadPlaylists() {
        let playlistNames = playlistManager.getAllPlaylists()
        
        playlists = playlistNames.map { name in
            let songURLs = playlistManager.getSongsInPlaylist(playlistName: name)
            let songs = songURLs.map { url in
                extractSongMetadata(from: url)
            }
            
            return Playlist(
                name: name,
                songs: songs,
                coverImage: UIImage(systemName: "music.note.list"), // Updated to UIImage
                description: "",
                isPrivate: false,
                dateCreated: Date() // Or get from folder metadata
            )
        }
    }
    
    func addPlaylist(name: String, description: String = "") {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        playlistManager.createPlaylist(name: trimmedName)
        
        let newPlaylist = Playlist(
            name: trimmedName,
            songs: [],
            coverImage: UIImage(systemName: "music.note.list"),
            description: description,
            isPrivate: false,
            dateCreated: Date()
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            playlists.insert(newPlaylist, at: 0)
        }
        
        playlistManager.savePlaylist(newPlaylist) // ✅ persist JSON
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlistManager.deletePlaylist(name: playlist.name)
        playlists.removeAll { $0.id == playlist.id }
    }
    
    func updatePlaylist(_ playlist: Playlist) {
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists[index] = playlist
        }
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

