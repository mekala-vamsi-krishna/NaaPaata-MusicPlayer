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
                    Button(action: {
                        onSort?(.title)
                    }) {
                        HStack {
                            Text("Title")
                            if viewModel.currentSort == .title {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.artist)
                    }) {
                        HStack {
                            Text("Artist")
                            if viewModel.currentSort == .artist {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.duration)
                    }) {
                        HStack {
                            Text("Duration")
                            if viewModel.currentSort == .duration {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.dateAddedDescending)
                    }) {
                        HStack {
                            Text("Date Added (Newest)")
                            if viewModel.currentSort == .dateAddedDescending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.dateAddedAscending)
                    }) {
                        HStack {
                            Text("Date Added (Oldest)")
                            if viewModel.currentSort == .dateAddedAscending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
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
    @EnvironmentObject var viewModel: SongsViewModel
    @EnvironmentObject var playlistsViewModel: PlaylistsViewModel
    @EnvironmentObject var tabState: TabState
    @State private var showingOnboarding = false
    


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
                
                if viewModel.isLoading {
                    ProgressView("Loading Songs...")
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(1.2)
                } else if viewModel.songs.isEmpty {
                    VStack {
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

                        Button(action: {
                            showingOnboarding = true
                        }) {
                            Text("Learn More")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 20)

                        Spacer()
                    }
                } else {
                    List {
                        SongsTopBar(viewModel: viewModel) { key in
                            viewModel.currentSort = key
                            viewModel.sortSongs(by: key)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        ForEach(viewModel.filteredSongs, id: \.self) { song in
                            Button {
                                if viewModel.searchText.isEmpty {
                                    viewModel.play(song)
                                } else {
                                    viewModel.playFromSearchResults(song)
                                }
                            } label: {
                                MP3FileCell(song: song)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden) // Allow ZStack background to show
                }
            }
            .navigationTitle("Naa Paata ♪")
            // Apply native search bar
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search songs...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud.fill")
                            .foregroundStyle(AppColors.primary)
                    }

                }
            }
            .onAppear {
                // Songs are loaded in App entry point
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
        }
    }
}



#Preview {
    SongsView()
}
