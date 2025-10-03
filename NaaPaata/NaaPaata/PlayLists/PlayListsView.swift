//
//  PlayListsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

struct PlayListsView: View {
    @State private var playlists: [String] = ["My Playlist"]
    @State private var showAddPlaylistAlert = false
    @State private var newPlaylistName = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    // Playlist Items
                    ForEach(playlists, id: \.self) { name in
                        VStack {
                            Rectangle()
                                .fill(AppColors.cardBackground)
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .overlay(
                                    Image(systemName: "music.note.list")
                                        .font(.largeTitle)
                                        .foregroundColor(AppColors.primary.opacity(0.7))
                                )
                            
                            Text(name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .padding(.top, 8)
                        }
                    }
                    
                    // Plus Icon Box
                    VStack {
                        ZStack {
                            Rectangle()
                                .fill(AppColors.cardBackground.opacity(0.8))
                                .frame(width: 150, height: 150)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.primary, lineWidth: 2)
                                )
                            
                            Button(action: {
                                showAddPlaylistAlert = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        
                        Text("Add Playlist")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationTitle("Playlists")
            .alert("New Playlist Name", isPresented: $showAddPlaylistAlert, actions: {
                TextField("Enter name", text: $newPlaylistName)
                Button("Add", action: addNewPlaylist)
                Button("Cancel", role: .cancel, action: { newPlaylistName = "" })
            }, message: {
                Text("Please enter a name for the new playlist.")
            })
        }
    }
    
    private func addNewPlaylist() {
        if !newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty {
            playlists.append(newPlaylistName)
        }
        newPlaylistName = ""
    }
}


#Preview {
    PlayListsView()
}
