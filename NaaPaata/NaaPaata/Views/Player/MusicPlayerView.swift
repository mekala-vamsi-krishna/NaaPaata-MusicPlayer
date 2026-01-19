//
//  MusicPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct MusicPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @EnvironmentObject var playlistsVM: PlaylistsViewModel
    
    // Create Playlist
    @State private var showCreatePlaylistSheet = false
    @State private var newPlaylistName = ""
    @State private var newPlaylistDescription = ""
    
    // Song Info
    @State private var showSongInfoSheet = false
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Blurred artwork background
            ZStack {
                // Background based on artwork
                if let artwork = musicPlayerManager.artworkImage {
                    GeometryReader { geometry in
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width * 2,
                                height: geometry.size.height * 2
                            )
                            .position(
                                x: geometry.frame(in: .local).midX,
                                y: geometry.frame(in: .local).midY
                            )
                            .blur(radius: 60)
                            .clipped()
                            .opacity(0.9)
                    }
                    .ignoresSafeArea()
                    
                    // Dark overlay for better text contrast
                    Color.black
                        .opacity(0.35)
                        .ignoresSafeArea()
                } else {
                    // Fallback background when no artwork
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.05, blue: 0.2),
                            Color(red: 0.15, green: 0.1, blue: 0.3),
                            Color(red: 0.08, green: 0.03, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dismiss()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Adaptive artwork display
                GeometryReader { geometry in
                    let layout = AdaptiveLayout(
                        horizontalSizeClass: sizeClass,
                        screenWidth: geometry.size.width
                    )
                    
                    VStack {
                        ZStack {
                            if let artwork = musicPlayerManager.artworkImage {
                                Image(uiImage: artwork)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: layout.albumArtSize, height: layout.albumArtSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            } else {
                                Image(systemName: "music.note")
                                    .font(.system(size: layout.albumArtSize * 0.27))
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: layout.albumArtSize, height: layout.albumArtSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: sizeClass == .regular ? 400 : 300)
                
                // Song info with normal text
                VStack(spacing: 8) {
                    Text(musicPlayerManager.currentSong?.title ?? "Unknown Title")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                    
                    Text(musicPlayerManager.currentSong?.artist ?? "Unknown Artist")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Progress bar
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            if let currentSong = musicPlayerManager.currentSong {
                                playlistsVM.toggleFavoriteSong(currentSong)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Group {
                                    if let currentSong = musicPlayerManager.currentSong,
                                       playlistsVM.isSongInFavorites(currentSong) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(AppColors.primary)
                                    } else {
                                        Image(systemName: "heart")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                        
                        Menu {
                            Button {
                                showSongInfoSheet = true
                            } label: {
                                Label("Info", systemImage: "info.circle")
                            }
                            
                            Divider()
                            
                            // Add to playlist options
                            ForEach(playlistsVM.playlists) { playlist in
                                Button {
                                    var updatedPlaylist = playlist
                                    // Avoid duplicates
                                    if !updatedPlaylist.songs.contains(where: { $0.id == musicPlayerManager.currentSong?.id }) {
                                        updatedPlaylist.songs.append(musicPlayerManager.currentSong!)
                                        playlistsVM.updatePlaylist(updatedPlaylist) // update Published array and save JSON
                                    }
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
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .rotationEffect(.degrees(90))
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    DraggableProgressBar(
                        currentTime: $musicPlayerManager.currentTime,
                        duration: musicPlayerManager.duration,
                        onDragChanged: { time in
                            musicPlayerManager.seek(to: time)
                        }
                    )
                    .frame(height: 30)
                    .padding(.horizontal, 32)
                    
                    HStack {
                        Text(formatTime(musicPlayerManager.currentTime))
                        Spacer()
                        Text(formatTime(musicPlayerManager.duration))
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 20)
                
                // Additional controls (Shuffle, Play All, etc.)
                HStack(spacing: 30) {
                    // Shuffle Button
                    Button(action: {
                        // Toggle shuffle mode
                        musicPlayerManager.toggleShuffle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(musicPlayerManager.shuffleIsActive ? AppColors.primary : Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "shuffle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(musicPlayerManager.shuffleIsActive ? .white : .white)
                        }
                    }
                    
                    // Repeat One Button
                    Button(action: {
                        // Toggle repeat one mode
                        musicPlayerManager.toggleRepeatOne()
                    }) {
                        ZStack {
                            Circle()
                                .fill(musicPlayerManager.currentRepeatMode == .one ? AppColors.primary : Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "repeat.1")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(musicPlayerManager.currentRepeatMode == .one ? .white : .white)
                        }
                    }
                    
                    // Repeat All Button  
                    Button(action: {
                        // Toggle repeat all mode
                        musicPlayerManager.toggleRepeatAll()
                    }) {
                        ZStack {
                            Circle()
                                .fill(musicPlayerManager.currentRepeatMode == .all ? AppColors.primary : Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "repeat")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(musicPlayerManager.currentRepeatMode == .all ? .white : .white)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Playback controls
                HStack(spacing: 50) {
                    Button(action: {
                        HapticManager.shared.light()
                        musicPlayerManager.playPrevious()
                    }) {
                        Image(systemName: "backward.fill").font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    
                    PlayPauseButton(isPlaying: musicPlayerManager.isPlaying) {
                        musicPlayerManager.togglePlayPause()
                    }
                    
                    Button(action: {
                        HapticManager.shared.light()
                        musicPlayerManager.playNext()
                    }) {
                        Image(systemName: "forward.fill").font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
            .offset(y: dragOffset) // Apply drag offset for smooth movement
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only drag downwards
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 0 {
                                // Dismiss if dragged enough
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    dismiss()
                                }
                            } else {
                                // Snap back if not dragged enough
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .animation(.easeOut(duration: 0.2), value: dragOffset)
        }
        .preferredColorScheme(.dark)
        // Sheet to create playlist and immediately add the song
        .sheet(isPresented: $showCreatePlaylistSheet) {
            CreatePlaylistSheet(
                name: $newPlaylistName,
                description: $newPlaylistDescription,
                onCreate: {
                    playlistsVM.addPlaylist(name: newPlaylistName, description: newPlaylistDescription)
                    if let newPlayList = playlistsVM.playlists.first {
                        var updatedPlaylist = newPlayList
                        updatedPlaylist.songs.append(musicPlayerManager.currentSong!)
                        playlistsVM.updatePlaylist(updatedPlaylist) // Update the playlist with the added song
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
                SongInfoView(song: musicPlayerManager.currentSong!)
            }
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard musicPlayerManager.duration > 0 else { return 0 }
        return totalWidth * CGFloat(musicPlayerManager.currentTime / musicPlayerManager.duration)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    

}

// MARK: - ControlButton(prev/next)
struct ControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - SmallControlButton(Shuffle/repeat)
struct SmallControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}




// MARK: - PlayPauseButton
struct PlayPauseButton: View {
    let isPlaying: Bool
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.shared.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        } label: {
            ZStack {
                // --- Rounded Squircle Background ---
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 85, height: 85)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .scaleEffect(isPressed ? 0.92 : 1.0)
                
                // --- Play/Pause Icon ---
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.symbolEffect(.replace)) 
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Draggable Progress Bar
struct DraggableProgressBar: View {
    @Binding var currentTime: TimeInterval
    let duration: TimeInterval
    let onDragChanged: (TimeInterval) -> Void
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 8)
                
                // Filled portion
                Capsule()
                    .fill(LinearGradient(colors: [AppColors.primary, AppColors.primary.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: progressWidth(totalWidth: geometry.size.width), height: 8)
                    .animation(.linear(duration: 0.1), value: currentTime)
                
                // Draggable circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: circleXPosition(geometry: geometry), y: 0)
                    .animation(isDragging ? nil : .linear(duration: 0.1), value: currentTime)
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newPosition = max(0, min(geometry.size.width, value.location.x))
                                let progress = newPosition / geometry.size.width
                                let newTime = progress * duration
                                currentTime = newTime
                                
                                // Update the player position as user drags
                                onDragChanged(newTime)
                            }
                            .onEnded { value in
                                isDragging = false
                                let newPosition = max(0, min(geometry.size.width, value.location.x))
                                let progress = newPosition / geometry.size.width
                                let newTime = progress * duration
                                currentTime = newTime
                                
                                // Update the player position when drag ends
                                onDragChanged(newTime)
                            }
                    )
            }
        }
    }
    
    private func progressWidth(totalWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        return totalWidth * CGFloat(currentTime / duration)
    }
    
    private func circleXPosition(geometry: GeometryProxy) -> CGFloat {
        guard duration > 0 else { return 0 }
        return (currentTime / duration) * geometry.size.width - 8 // -8 to center the circle (half of 16 width)
    }
}


#Preview {
    MusicPlayerView()
}
