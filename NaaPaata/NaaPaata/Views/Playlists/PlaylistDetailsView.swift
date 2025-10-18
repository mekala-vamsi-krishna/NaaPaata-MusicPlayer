//
//  PlaylistDetailsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct PlaylistDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var playlist: Playlist
    let onUpdate: (Playlist) -> Void
    let onDelete: () -> Void
    
    @State private var showAddSongs = false
    @State private var showEditPlaylist = false
    @State private var showSortOptions = false
    @State private var showDeletePlaylistConfirmation = false
    @State private var selectedSong: Song?
    @State private var currentSortOption: SortOption = .dateAdded
    @State private var isAscending = true
    @State private var searchText = ""
    @State private var editMode: EditMode = .inactive
    
    init(playlist: Playlist, onUpdate: @escaping (Playlist) -> Void, onDelete: @escaping () -> Void) {
        _playlist = State(initialValue: playlist)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    // MARK: - Sorted & Filtered Songs
    var sortedSongs: [Song] {
        var songs = playlist.songs
        
        switch currentSortOption {
        case .dateAdded:
            songs.sort { a, b in
                let dateA = a.dateAdded ?? Date.distantPast
                let dateB = b.dateAdded ?? Date.distantPast
                return isAscending ? dateA < dateB : dateA > dateB
            }
        case .title:
            songs.sort { a, b in
                isAscending ? a.title < b.title : a.title > b.title
            }
        case .artist:
            songs.sort { a, b in
                isAscending ? a.artist < b.artist : a.artist > b.artist
            }
        case .duration:
            songs.sort { a, b in
                isAscending ? a.duration < b.duration : a.duration > b.duration
            }
        }
        
        if !searchText.isEmpty {
            songs = songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return songs
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.background, AppColors.background.opacity(0.8)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    playlistHeader
                    actionButtons.padding(.vertical, 24)
                    searchAndSortBar.padding(.horizontal, 20).padding(.bottom, 16)
                    songsListSection
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: { onUpdate(playlist); dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                        Text("Playlists").font(.system(size: 17))
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showEditPlaylist = true }) { Label("Edit Playlist", systemImage: "pencil") }
                    Button(action: { playlist.isPrivate.toggle(); onUpdate(playlist) }) {
                        Label(playlist.isPrivate ? "Make Public" : "Make Private",
                              systemImage: playlist.isPrivate ? "eye" : "eye.slash")
                    }
                    Divider()
                    Button(role: .destructive, action: { showDeletePlaylistConfirmation = true }) {
                        Label("Delete Playlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle").font(.system(size: 20)).foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddSongs) {
            AddSongsView(playlist: $playlist)
        }
        .sheet(isPresented: $showEditPlaylist) {
            EditPlaylistView(playlist: $playlist)
        }
        .alert("Delete Song", isPresented: .constant(selectedSong != nil), presenting: selectedSong) { song in
            Button("Cancel", role: .cancel) { selectedSong = nil }
            Button("Delete", role: .destructive) {
                if let index = playlist.songs.firstIndex(where: { $0.id == song.id }) {
                    withAnimation { playlist.songs.remove(at: index) }
                    onUpdate(playlist)
                }
                selectedSong = nil
            }
        } message: { song in
            Text("Are you sure you want to remove '\(song.title)' from this playlist?")
        }
        .alert("Delete Playlist", isPresented: $showDeletePlaylistConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(playlist.name)'? This action cannot be undone.")
        }
    }
    
    // MARK: - Playlist Header
    private var playlistHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(RadialGradient(colors: [AppColors.primary.opacity(0.3), .clear],
                                         center: .center,
                                         startRadius: 100, endRadius: 150))
                    .frame(width: 220, height: 220)
                    .blur(radius: 30)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Group {
                            if let artwork = playlist.coverImage {
                                LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                .mask {
                                    Image(uiImage: artwork)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                } // bcoz I am using uiImage, to get te purple color
                            } else {
                                Image(systemName: "music.note.list")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(
                                        LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.3), .clear],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            }
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text(playlist.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if !playlist.description.isEmpty {
                    Text(playlist.description)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                HStack(spacing: 16) {
                    Label("\(playlist.songs.count) songs", systemImage: "music.note.list")
                    if !playlist.songs.isEmpty {
                        Text("•")
                        Label(totalDuration, systemImage: "clock")
                    }
                    if playlist.isPrivate {
                        Text("•")
                        Label("Private", systemImage: "lock.fill")
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: { MusicPlayerManager.shared.playFromAllSongs(playlist.songs) }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill").font(.system(size: 18, weight: .bold))
                    Text("Play All").font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                           startPoint: .leading, endPoint: .trailing))
                .clipShape(Capsule())
            }
            .disabled(playlist.songs.isEmpty)
            .opacity(playlist.songs.isEmpty ? 0.5 : 1.0)
            
            Button(action: { MusicPlayerManager.shared.shufflePlay(playlist: playlist.songs) }) {
                HStack(spacing: 12) {
                    Image(systemName: "shuffle").font(.system(size: 18, weight: .bold))
                    Text("Shuffle").font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(AppColors.primary.opacity(0.3), lineWidth: 1.5))
            }
            .disabled(playlist.songs.isEmpty)
            .opacity(playlist.songs.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search & Sort
    private var searchAndSortBar: some View {
        VStack(spacing: 12) {
            if !playlist.songs.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").foregroundColor(AppColors.textSecondary)
                    TextField("Search songs...", text: $searchText)
                        .foregroundColor(AppColors.textPrimary)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
                
                HStack {
                    Button(action: { showSortOptions = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.arrow.down").font(.system(size: 14, weight: .semibold))
                            Text("Sort: \(currentSortOption.rawValue)").font(.system(size: 14, weight: .medium))
                            Image(systemName: isAscending ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .confirmationDialog("Sort by", isPresented: $showSortOptions) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                withAnimation {
                                    if currentSortOption == option {
                                        isAscending.toggle()
                                    } else {
                                        currentSortOption = option
                                        isAscending = true
                                    }
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation { editMode = editMode == .active ? .inactive : .active }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: editMode == .active ? "checkmark" : "pencil")
                                .font(.system(size: 14, weight: .semibold))
                            Text(editMode == .active ? "Done" : "Edit").font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(editMode == .active ? .green : AppColors.primary)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(.ultraThinMaterial).clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Songs List
    private var songsListSection: some View {
        VStack(spacing: 0) {
            if sortedSongs.isEmpty && playlist.songs.isEmpty {
                emptyStateView
            } else if sortedSongs.isEmpty && !searchText.isEmpty {
                noSearchResultsView
            } else {
                ForEach(sortedSongs) { song in
                    PlaylistSongRowView(
                        song: song,
                        editMode: editMode,
                        onPlay: { MusicPlayerManager.shared.playSong(song) },
                        onDelete: { selectedSong = song }
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
            
            Button(action: { showAddSongs = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill").font(.system(size: 24))
                    Text("Add Songs").font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Empty & No Results Views
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list").font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            Text("No songs yet").font(.system(size: 20, weight: .semibold)).foregroundColor(AppColors.textPrimary)
            Text("Add songs to start building your playlist")
                .font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 60)
    }
    
    private var noSearchResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass").font(.system(size: 60))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            Text("No results found").font(.system(size: 20, weight: .semibold)).foregroundColor(AppColors.textPrimary)
            Text("Try searching with different keywords")
                .font(.system(size: 14)).foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 60)
    }
    
    // MARK: - Total Duration
    private var totalDuration: String {
        let total = playlist.songs.reduce(0) { $0 + $1.duration }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}


// MARK: - Preview
#Preview {
    NavigationView {
//        PlaylistDetailsView(playlist: <#Playlist#>, onUpdate: <#(Playlist) -> Void#>, onDelete: <#() -> Void#>)
    }
    .preferredColorScheme(.dark)
}
