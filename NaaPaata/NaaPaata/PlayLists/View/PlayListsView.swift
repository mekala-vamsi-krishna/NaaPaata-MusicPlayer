//
//  PlayListsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

// MARK: - Playlists View
struct PlayListsView: View {
    @State private var playlists: [Playlist] = [
        Playlist(
            name: "Chill Vibes",
            songs: [
                Song(title: "Midnight Dreams", artist: "Luna Bay", duration: 245, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 5)),
                Song(title: "Ocean Waves", artist: "Coastal Hearts", duration: 198, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 3)),
                Song(title: "Starlight", artist: "Nova Sound", duration: 212, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 2))
            ],
            coverImage: "music.note.list",
            description: "Perfect playlist for relaxing",
            isPrivate: false,
            dateCreated: Date().addingTimeInterval(-86400 * 30)
        ),
        Playlist(
            name: "Workout Mix",
            songs: [
                Song(title: "Thunder Storm", artist: "Weather Sounds", duration: 267, artworkImage: "music.note", dateAdded: Date()),
                Song(title: "Electric Feel", artist: "Neon Pulse", duration: 223, artworkImage: "music.note", dateAdded: Date())
            ],
            coverImage: "music.note.list",
            description: "High energy workout tracks",
            isPrivate: false,
            dateCreated: Date().addingTimeInterval(-86400 * 15)
        )
    ]
    
    @State private var showAddPlaylistSheet = false
    @State private var newPlaylistName = ""
    @State private var newPlaylistDescription = ""
    @State private var searchText = ""
    @State private var selectedPlaylist: Playlist?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredPlaylists: [Playlist] {
        if searchText.isEmpty {
            return playlists
        }
        return playlists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        AppColors.background,
                        AppColors.background.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Search bar
                        if !playlists.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Search playlists...", text: $searchText)
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
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                        
                        // Grid of playlists
                        LazyVGrid(columns: columns, spacing: 20) {
                            // Playlist Items
                            ForEach(filteredPlaylists) { playlist in
                                NavigationLink(destination: PlaylistDetailsView(playlist: playlist, onUpdate: { updatedPlaylist in
                                    if let index = playlists.firstIndex(where: { $0.id == updatedPlaylist.id }) {
                                        playlists[index] = updatedPlaylist
                                    }
                                }, onDelete: {
                                    playlists.removeAll { $0.id == playlist.id }
                                })) {
                                    PlaylistCard(playlist: playlist)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Add Playlist Card
                            AddPlaylistCard {
                                showAddPlaylistSheet = true
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
                
                // Empty state
                if playlists.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 8) {
                            Text("No Playlists Yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Create your first playlist to get started")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showAddPlaylistSheet = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Create Playlist")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
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
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 40)
                }
            }
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !playlists.isEmpty {
                        Button(action: { showAddPlaylistSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddPlaylistSheet) {
                CreatePlaylistSheet(
                    name: $newPlaylistName,
                    description: $newPlaylistDescription,
                    onCreate: {
                        addNewPlaylist()
                    }
                )
            }
        }
    }
    
    private func addNewPlaylist() {
        let trimmedName = newPlaylistName.trimmingCharacters(in: .whitespaces)
        
        if !trimmedName.isEmpty {
            let newPlaylist = Playlist(
                name: trimmedName,
                songs: [],
                coverImage: "music.note.list",
                description: newPlaylistDescription.trimmingCharacters(in: .whitespaces),
                isPrivate: false,
                dateCreated: Date()
            )
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                playlists.insert(newPlaylist, at: 0)
            }
        }
        
        // Reset
        newPlaylistName = ""
        newPlaylistDescription = ""
    }
}

// MARK: - Playlist Card
struct PlaylistCard: View {
    let playlist: Playlist
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover art
            ZStack {
                // Glow effect
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.primary.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 90
                        )
                    )
                    .frame(height: 160)
                    .blur(radius: 20)
                
                // Main card
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(height: 160)
                    .overlay(
                        ZStack {
                            // Cover image
                            Image(systemName: playlist.coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Song count badge
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "music.note")
                                            .font(.system(size: 10, weight: .semibold))
                                        Text("\(playlist.songs.count)")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(AppColors.primary.opacity(0.9))
                                    )
                                    .padding(10)
                                }
                                Spacer()
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            
            // Playlist info
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if playlist.isPrivate {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                    }
                    Text(playlist.songs.isEmpty ? "Empty" : "\(playlist.songs.count) song\(playlist.songs.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(AppColors.textSecondary)
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Add Playlist Card
struct AddPlaylistCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Dashed border card
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.5))
                        .frame(height: 160)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                        )
                        .foregroundColor(AppColors.primary.opacity(0.6))
                        .frame(height: 160)
                    
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primary.opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Text("New Playlist")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                
                // Placeholder text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Playlist")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Add your favorite songs")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Supporting Views
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    PlayListsView()
        .preferredColorScheme(.dark)
}


#Preview {
//    PlayListsView(newPlaylistName: Playlist)
}
