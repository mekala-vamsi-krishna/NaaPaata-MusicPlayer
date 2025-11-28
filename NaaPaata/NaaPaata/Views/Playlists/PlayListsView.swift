//
//  PlayListsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

struct PlayListsView: View {
    @EnvironmentObject private var viewModel: PlaylistsViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var showAddPlaylistSheet = false
    @State private var newPlaylistName = ""
    @State private var newPlaylistDescription = ""
    @State private var searchText = ""
    
    var filteredPlaylists: [Playlist] {
        if searchText.isEmpty {
            return viewModel.playlists
        }
        return viewModel.playlists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let layout = AdaptiveLayout(
                horizontalSizeClass: sizeClass,
                screenWidth: geometry.size.width
            )
            let columns = Array(
                repeating: GridItem(.flexible(), spacing: layout.gridSpacing),
                count: layout.gridColumns
            )
            
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: [
                            AppColors.background,
                            AppColors.background.opacity(0.95),
                            AppColors.primary.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        if viewModel.isLoading {
                            VStack {
                                Spacer()
                                    .frame(height: 100)
                                ProgressView("Loading Playlists...")
                                    .tint(AppColors.primary)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                            }
                        } else {
                            VStack(spacing: 24) {
                                searchBar(layout: layout)
                                playlistsGrid(columns: columns, layout: layout)
                                emptyState
                            }
                        }
                    }
                }
                .navigationTitle("Playlists")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !viewModel.playlists.isEmpty {
                            Button {
                                showAddPlaylistSheet = true
                            } label: {
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
                            viewModel.addPlaylist(name: newPlaylistName, description: newPlaylistDescription)
                            newPlaylistName = ""
                            newPlaylistDescription = ""
                            showAddPlaylistSheet = false
                        }
                    )
                }
                .onAppear {
                    viewModel.loadPlaylists()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension PlayListsView {
    func searchBar(layout: AdaptiveLayout) -> some View {
        if viewModel.playlists.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("Search playlists...", text: $searchText)
                    .foregroundColor(AppColors.textPrimary)
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.top, 8)
        )
    }
    
    func playlistsGrid(columns: [GridItem], layout: AdaptiveLayout) -> some View {
        LazyVGrid(columns: columns, spacing: layout.gridSpacing) {
            ForEach(filteredPlaylists) { playlist in
                NavigationLink(destination: PlaylistDetailsView(
                    playlist: playlist,
                    onUpdate: viewModel.updatePlaylist,
                    onDelete: { viewModel.deletePlaylist(playlist) }
                )) {
                    PlaylistCard(playlist: playlist, cardHeight: layout.playlistCardHeight)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, layout.horizontalPadding)
        .padding(.bottom, 32)
    }
    
    var emptyState: some View {
        if !viewModel.playlists.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
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
                
                Button {
                    showAddPlaylistSheet = true
                } label: {
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
                        LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 40)
        )
    }
}
#Preview {
    PlayListsView()
}
