//
//  AlbumsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct AlbumsTopBar: View {
    @ObservedObject var viewModel: AlbumsViewModel
    var filteredCount: Int
    var onSort: ((AlbumsViewModel.SortKey) -> Void)? // callback for sort

    var body: some View {
        HStack {
            // Total albums
            Text("\(filteredCount) Album\(filteredCount == 1 ? "" : "s")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.leading, 5)

            Spacer()

            // Right side buttons
            HStack(spacing: 16) {
                Menu {
                    Button(action: {
                        onSort?(.name)
                    }) {
                        HStack {
                            Text("Name")
                            if viewModel.currentSort == .name {
                                Image(systemName: "checkmark")
                                    .labelStyle(.titleAndIcon)
                                    .foregroundColor(AppColors.primary)
                                    .symbolRenderingMode(.hierarchical)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.dateAdded)
                    }) {
                        HStack {
                            Text("Date Added")
                            if viewModel.currentSort == .dateAdded {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.dateModified)
                    }) {
                        HStack {
                            Text("Date Modified")
                            if viewModel.currentSort == .dateModified {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                    Button(action: {
                        onSort?(.size)
                    }) {
                        HStack {
                            Text("Size")
                            if viewModel.currentSort == .size {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 18))
                        Text("Sort")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


struct AlbumsView: View {
    @StateObject private var viewModel = AlbumsViewModel()
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var selectedSort: AlbumsViewModel.SortKey = .name
    @State private var showingOnboarding = false
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            
            TextField("Search albums...", text: $viewModel.searchText)
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
                    
                    VStack(spacing: layout.verticalSpacing) {
                        if viewModel.isLoading {
                            Spacer()
                            ProgressView("Loading Albums...")
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                                .scaleEffect(1.2)
                            Spacer()
                        } else if viewModel.albums.isEmpty && !viewModel.isLoading {
                            // Empty State
                            Spacer()
                            Image(systemName: "opticaldisc")
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
                        } else if !viewModel.albums.isEmpty {
                            // Search Bar
                            searchBar
                                .padding(.horizontal, layout.horizontalPadding)
                                .padding(.top, 10)
                            
                            // Top toolbar with dynamic count
                            AlbumsTopBar(viewModel: viewModel, filteredCount: viewModel.filteredAlbums.count) { key in
                                viewModel.currentSort = key
                                viewModel.sortAlbums(by: key)
                            }

                            ScrollView {
                                LazyVGrid(columns: columns, spacing: layout.gridSpacing) {
                                    ForEach(viewModel.filteredAlbums) { album in
                                        NavigationLink {
                                            AlbumDetailsView(
                                                title: album.name,
                                                artwork: album.artworkImage,
                                                songs: album.songs
                                            )
                                        } label: {
                                            AlbumCellView(album: album, imageSize: layout.cardImageSize)
                                        }
                                    }
                                }
                                .padding(.horizontal, layout.horizontalPadding)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .navigationTitle("Albums")
                .onAppear {
                    viewModel.loadAlbums()
                }
                .sheet(isPresented: $showingOnboarding) {
                    OnboardingView()
                }
            }
        }
    }
}

struct AlbumCellView: View {
    let album: Album
    let imageSize: CGFloat
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let artwork = album.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "opticaldisc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize * 0.75, height: imageSize * 0.75)
                        .padding()
                        .foregroundColor(.gray.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(width: imageSize, height: imageSize)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 6)
                
                Text("\(album.songs.count) song\(album.songs.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
            }
        }
    }
}



#Preview {
    AlbumsView()
}
