//
//  AddSongsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI
import AVFoundation

struct AddSongsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var playlist: Playlist
    @State private var searchText = ""
    @State private var selectedSongs: Set<UUID> = []
    
    @State private var availableSongs: [Song] = []
    private let playlistManager = PlaylistManager.shared
       
    @State var isLoaded = false
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return availableSongs
        }
        return availableSongs.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.artist.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textSecondary)
                        
                        TextField("Search songs...", text: $searchText)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(20)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredSongs) { song in
                                AddableSongRow(
                                    song: song,
                                    isSelected: selectedSongs.contains(song.id),
                                    onToggle: {
                                        if selectedSongs.contains(song.id) {
                                            selectedSongs.remove(song.id)
                                        } else {
                                            selectedSongs.insert(song.id)
                                        }
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                if !selectedSongs.isEmpty {
                    VStack {
                        Spacer()
                        
                        Button(action: {
                           // let songsToAdd = availableSongs.filter { selectedSongs.contains($0.id) }
                           // playlist.songs.append(contentsOf: songsToAdd)
                            addSelectedSongsToPlaylist()
                            dismiss()
                        }) {
                            Text("Add \(selectedSongs.count) Song\(selectedSongs.count == 1 ? "" : "s")")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Add Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            
        }
        .onAppear {
            loadIfNeeded()
        }
    }
}

extension AddSongsView {
    
    func loadIfNeeded() {
        guard !isLoaded else { return }
        isLoaded = true
        loadAvailableSongs()
    }
    
    func loadAvailableSongs() {
        // Use SongCacheService for instant load
        if let cachedSongs = SongCacheService.shared.loadSongs(), !cachedSongs.isEmpty {
            self.availableSongs = cachedSongs
            print("✅ Loaded \(cachedSongs.count) songs from cache.")
            return
        }
        
        // Fallback to background load if cache is empty
        DispatchQueue.global(qos: .userInitiated).async {
            let urls = LoadAllSongsFromDocuments().loadSongsFromDocuments()
            var loadedSongs: [Song] = []
            
            for url in urls {
                let song = self.loadMetadata(for: url)
                loadedSongs.append(song)
            }
            
            DispatchQueue.main.async {
                self.availableSongs = loadedSongs
                print("✅ Finished loading \(loadedSongs.count) songs from disk.")
                // Save to cache for next time
                SongCacheService.shared.saveSongs(loadedSongs)
            }
        }
    }

    private func loadMetadata(for url: URL) -> Song {
        let asset = AVAsset(url: url)
        
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var duration: TimeInterval = 0
        var artwork: UIImage? = nil // Don't set default here, let getArtwork handle it
        
        duration = CMTimeGetSeconds(asset.duration)
        for item in asset.commonMetadata {
            guard let key = item.commonKey else { continue }
            switch key {
            case .commonKeyTitle:
                title = item.stringValue ?? title
            case .commonKeyArtist:
                artist = item.stringValue ?? artist
            case .commonKeyArtwork:
                if let data = item.dataValue, let img = UIImage(data: data) {
                    artwork = img
                }
            default: break
            }
        }
        
        return Song(url: url, title: title, artist: artist, duration: duration, artworkImage: artwork)
    }
    
    
    // MARK: - Add selected songs to playlist
    private func addSelectedSongsToPlaylist() {
        // Filter only selected songs
        let songsToAdd = availableSongs.filter { selectedSongs.contains($0.id) }
        
        // Update playlist in memory immediately for UI responsiveness
        playlist.songs.append(contentsOf: songsToAdd)
        
        // Persist playlist JSON in background
        let playlistToSave = playlist
        DispatchQueue.global(qos: .background).async {
            PlaylistManager.shared.savePlaylist(playlistToSave)
        }
    }
    
}

struct AddableSongRow: View {
    let song: Song
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)
                    
                    // Use artwork from song directly to avoid expensive getArtwork call during scroll
                    if let artwork = song.artworkImage {
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(song.artist)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? AppColors.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
