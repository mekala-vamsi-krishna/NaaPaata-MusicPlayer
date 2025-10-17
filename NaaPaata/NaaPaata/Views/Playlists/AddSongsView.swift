//
//  AddSongsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct AddSongsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var playlist: Playlist
    @State private var searchText = ""
    @State private var selectedSongs: Set<UUID> = []
    
    @State private var availableSongs: [Song] = []
    private let playlistManager = PlaylistManager.shared
       
    
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
                        VStack(spacing: 8) {
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
            loadAvailableSongs()
        }
    }
}

extension AddSongsView {
    
    private func loadAvailableSongs() {
        let mp3Files = LoadAllSongsFromDocuments().loadSongsFromDocuments()
        
        availableSongs = mp3Files.map { url in
            Song(
                title: url.deletingPathExtension().lastPathComponent,
                artist: "Unknown Artist", // You can extract metadata later
                duration: 0,
                fileURL: url, // Store the actual file URL
                artworkImage: "music.note",
                dateAdded: Date()
            )
        }
    }
    
    
    private func addSelectedSongsToPlaylist() {
        let songsToAdd = availableSongs.filter { selectedSongs.contains($0.id) }
        
        for song in songsToAdd {
            if let fileURL = song.fileURL {
                // 1. Add to file system using PlaylistManager
                playlistManager.addSongToPlaylist(songURL: fileURL, playlistName: playlist.name)
                
                // 2. Add to UI model
                playlist.songs.append(song)
            }
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
                    
                    Image(systemName: song.artworkImage)
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary)
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
