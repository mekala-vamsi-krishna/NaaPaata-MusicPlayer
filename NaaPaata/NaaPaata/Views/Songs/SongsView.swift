//
//  ContentView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct SongsTopBar: View {
    @ObservedObject var viewModel: SongsViewModel
    var onSort: ((SongsViewModel.SortKey) -> Void)?

    var body: some View {
        HStack {
            // Total songs
            Text("\(viewModel.totalSongs) Songs")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.leading, 5)

            Spacer()

            // Buttons on the right with spacing
            HStack(spacing: 20) {
                Button(action: viewModel.playAll) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primary)
                }

                Button(action: viewModel.playShuffled) {
                    Image(systemName: "shuffle")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primary)
                }

                Menu {
                    Button("Title") { onSort?(.title) }
                    Button("Artist") { onSort?(.artist) }
                    Button("Duration") { onSort?(.duration) }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}



struct SongsView: View {
    @StateObject private var viewModel = SongsViewModel()
    @EnvironmentObject var playlistsViewModel: PlaylistsViewModel
    @EnvironmentObject var tabState: TabState
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            
            TextField("Search songs...", text: $viewModel.searchText)
                .foregroundColor(.primary)
            
            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
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
                
                VStack(spacing: 10) {
                    // Search Bar (like PlayListsView)
                    if !viewModel.songs.isEmpty {
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    }
                    
                    if viewModel.songs.isEmpty {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(AppColors.primary).opacity(0.7)
                            .padding(.top, 50)

                        Text("Add MP3 files to the MyAppFiles folder in the Files app to enjoy playback anytime.")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer()
                    } else {
                        // Top toolbar
                        SongsTopBar(viewModel: viewModel) { key in
                            viewModel.sortSongs(by: key)
                        }
                        
                        List(viewModel.filteredSongs, id: \.self) { song in
                            Button {
                                if viewModel.searchText.isEmpty {
                                    viewModel.play(song)
                                } else {
                                    viewModel.playFromSearchResults(song)
                                }
                            } label: {
                                MP3FileCell(song: song)
                            }
                        }
                        .listStyle(.plain)

                    }
                }
            }
            .navigationTitle("Naa Paata")
            .onAppear { viewModel.loadSongs() }
        }
    }
}




#Preview {
    SongsView()
}
