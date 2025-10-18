//
//  EditPlaylistView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct EditPlaylistView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var playlist: Playlist
    @State private var name: String
    @State private var description: String
    @State private var isPrivate: Bool
    
    init(playlist: Binding<Playlist>) {
        _playlist = playlist
        _name = State(initialValue: playlist.wrappedValue.name)
        _description = State(initialValue: playlist.wrappedValue.description)
        _isPrivate = State(initialValue: playlist.wrappedValue.isPrivate)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 160, height: 160)
                                    .overlay(
                                        Group {
                                            if let image = playlist.coverImage {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(12)
                                                    .shadow(radius: 5)
                                            } else {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(LinearGradient(
                                                        colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ))
                                                    .frame(width: 80, height: 80)
                                                    .overlay(
                                                        Image(systemName: "music.note")
                                                            .font(.system(size: 36))
                                                            .foregroundColor(.white)
                                                    )
                                            }
                                        }
                                    )
                            }
                            
                            Button(action: {}) {
                                Text("Change Cover")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Playlist name", text: $name)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Add a description", text: $description, axis: .vertical)
                                    .lineLimit(3...6)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Private Playlist")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("Only you can see this playlist")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isPrivate)
                                    .tint(AppColors.primary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Edit Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        playlist.name = name
                        playlist.description = description
                        playlist.isPrivate = isPrivate
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
