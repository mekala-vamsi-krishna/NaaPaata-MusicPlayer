//
//  MP3FileCell.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MP3FileCell: View {
    let song: Song
    @EnvironmentObject var musicManager: MusicPlayerManager
    @EnvironmentObject var playlistsVM: PlaylistsViewModel

    // Create Playlist
    @State private var showCreatePlaylistSheet = false
    @State private var newPlaylistName = ""
    @State private var newPlaylistDescription = ""
    
    // Song Info
    @State private var showSongInfoSheet = false
    
    // Share Properties
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    // Delete Alert
    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 15) {
            // Artwork
            Image(uiImage: musicManager.getArtwork(for: song) ?? song.artworkImage ?? UIImage(systemName: "music.note")!)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Song details
            VStack(alignment: .leading, spacing: 4) {
                Text(song.displayName)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Now Playing Indicator
            if musicManager.currentSong == song {
                EqualizerBars()
                    .frame(width: 20, height: 20)
            }

            // Ellipsis menu
            Menu {
                Button {
                    musicManager.addToQueueNext(song)
                } label: {
                    Label("Play Next", systemImage: "text.insert")
                }

                Button {
                    showSongInfoSheet = true
                } label: {
                    Label("Info", systemImage: "info.circle")
                }

                Button {
                    shareItems = [song.url]
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Divider()

                // Add to playlist options
                ForEach(playlistsVM.playlists) { playlist in
                    Button {
                        var updatedPlaylist = playlist
                        updatedPlaylist.songs.append(song)
                        playlistsVM.updatePlaylist(updatedPlaylist)
                        playlistsVM.playlistManager.addSongToPlaylist(songURL: song.url, playlistName: updatedPlaylist.name)
                    } label: {
                        Label(playlist.name, systemImage: "music.note.list")
                    }
                }

                Divider()

                // Create new playlist
                Button {
                    showCreatePlaylistSheet = true
                } label: {
                    Label("Create New Playlist", systemImage: "plus.circle")
                }

                Divider()

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }

            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 4)
        // Sheet to create playlist and immediately add the song
        .sheet(isPresented: $showCreatePlaylistSheet) {
            CreatePlaylistSheet(
                name: $newPlaylistName,
                description: $newPlaylistDescription,
                onCreate: {
                    playlistsVM.addPlaylist(name: newPlaylistName, description: newPlaylistDescription)
                    if let newPlayList = playlistsVM.playlists.first {
                        var updatedPlaylist = newPlayList
                        updatedPlaylist.songs.append(song)
                        playlistsVM.updatePlaylist(newPlayList)
                        playlistsVM.playlistManager.addSongToPlaylist(songURL: song.url, playlistName: newPlayList.name)
                    }
                    newPlaylistName = ""
                    newPlaylistDescription = ""
                    showCreatePlaylistSheet = false
                }
            )
        }
        // Song Info Sheet
        .sheet(isPresented: $showSongInfoSheet) {
            NavigationStack {
                SongInfoView(song: song)
            }
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
        // Share Sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: shareItems)
                .presentationDetents([.fraction(0.4)])
        }
        // Delete Alert
        .alert("Delete Song?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                musicManager.delete(song: song)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(song.displayName)\" from your device?")
        }
    }
}


struct EqualizerBars: View {
    @State private var heights: [CGFloat] = [5, 10, 7]
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<heights.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.purple)
                    .frame(width: 3, height: heights[i])
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.25)) {
                heights = heights.map { _ in CGFloat(Int.random(in: 5...15)) }
            }
        }
    }
}





