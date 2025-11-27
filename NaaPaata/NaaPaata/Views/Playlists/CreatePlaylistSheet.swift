//
//  CreatePlaylistSheet.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct CreatePlaylistSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var description: String
    let onCreate: () -> Void
    
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AppColors.primary.opacity(0.2),
                                            AppColors.primary.opacity(0.05)
                                        ],
                                        center: .center,
                                        startRadius: 40,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "music.note.list")
                                        .font(.system(size: 50))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Playlist Name")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Enter playlist name", text: $name)
                                    .focused($isNameFocused)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(AppColors.textPrimary)
                                    .font(.system(size: 16))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description (Optional)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                TextField("Add a description", text: $description, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(AppColors.textPrimary)
                                    .font(.system(size: 16))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Create Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
}
