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
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Blurred artwork background
            ZStack {
                // Background based on artwork
                if let artwork = musicPlayerManager.currentSongArtwork {
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
                    
                    Button(action: { }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Simple artwork display
                ZStack {
                    if let artwork = musicPlayerManager.currentSongArtwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 300, height: 300)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 80))
                                    .foregroundColor(AppColors.primary)
                            )
                    }
                }
                
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
                    Button(action: {
                        // Shuffle all songs
                        if let currentSong = musicPlayerManager.currentSong {
                            // This will shuffle all songs and start with the current one
                            musicPlayerManager.shufflePlay(playlist: musicPlayerManager.allSongs)
                        } else {
                            // If no current song, shuffle all available songs
                            musicPlayerManager.shufflePlay(playlist: musicPlayerManager.allSongs)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "shuffle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        // Play all songs (from the beginning)
                        if !musicPlayerManager.allSongs.isEmpty {
                            musicPlayerManager.playFromAllSongs(musicPlayerManager.allSongs)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        // Toggle repeat mode
                        musicPlayerManager.toggleRepeatMode()
                    }) {
                        ZStack {
                            Circle()
                                .fill(musicPlayerManager.currentRepeatMode != .none ? AppColors.primary : Color.black.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Group {
                                switch musicPlayerManager.currentRepeatMode {
                                case .none:
                                    Image(systemName: "repeat")
                                case .single:
                                    Image(systemName: "repeat.1")
                                case .all:
                                    Image(systemName: "repeat")
                                }
                            }
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(musicPlayerManager.currentRepeatMode != .none ? .white : .white)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Playback controls
                HStack(spacing: 50) {
                    Button(action: { musicPlayerManager.playPrevious() }) {
                        Image(systemName: "backward.fill").font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    
                    PlayPauseButton(isPlaying: musicPlayerManager.isPlaying) {
                        musicPlayerManager.togglePlayPause()
                    }
                    
                    Button(action: { musicPlayerManager.playNext() }) {
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
                            if value.translation.height > 120 {
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

// MARK: - Supporting Views



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

// MARK: - Preview
struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
            .environmentObject(MusicPlayerManager.shared)
    }
}

#Preview {
    MusicPlayerView()
}

struct PlayPauseButton: View {
    let isPlaying: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animateIcon = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                action()
                animateIcon.toggle()
            }
        } label: {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(LinearGradient(
                        colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 110, height: 110)
                
                // Main button
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                            center: .center,
                            startRadius: 5,
                            endRadius: 45
                        )
                    )
                    .frame(width: 95, height: 95)
                    .shadow(color: AppColors.primary.opacity(0.5), radius: 15, x: 0, y: 5)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeOut(duration: 0.1), value: isPressed)
                
                // Inner highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.4), .clear],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 90, height: 90)
                
                // Play/Pause icon
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 45, height: 45)
                    .scaleEffect(isPressed ? 1.1 : 1.0)
                    .rotationEffect(.degrees(animateIcon ? 180 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateIcon)

            }
        }
        .buttonStyle(PlayPauseButtonStyle())
    }
}

struct PlayPauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .rotationEffect(.degrees(configuration.isPressed ? 5 : 0)) // Add rotation for extra feedback
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
                
                // Draggable circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .offset(x: circleXPosition(geometry: geometry), y: 0) // -4 to center vertically
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
