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
    var onSort: ((AlbumsViewModel.SortKey) -> Void)? // callback for sort

    var body: some View {
        HStack {
            // Total albums
            Text("\(viewModel.albums.count) Albums")
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
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var selectedSort: AlbumsViewModel.SortKey = .name

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
                
                VStack(spacing: 0) {
                    // Search Bar (like PlayListsView)
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading Albums...")
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                            .scaleEffect(1.2)
                        Spacer()
                    } else {
                        AlbumsTopBar(viewModel: viewModel) { key in
                            viewModel.currentSort = key
                            viewModel.sortAlbums(by: key)
                        }

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(viewModel.albums) { album in
                                    NavigationLink {
                                        AlbumDetailsView(
                                            title: album.name,
                                            artwork: album.artworkImage,
                                            songs: album.songs
                                        )
                                    } label: {
                                        AlbumCellView(album: album)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Albums")
            .onAppear {
                viewModel.loadAlbums()
            }
        }
    }
}

struct AlbumCellView: View {
    let album: Album
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let artwork = album.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "opticaldisc")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding()
                        .foregroundColor(.gray.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
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
