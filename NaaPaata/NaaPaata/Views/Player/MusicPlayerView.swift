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
    @State private var rotationAngle: Double = 0
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground(isPlaying: musicPlayerManager.isPlaying)
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
                                .fill(.ultraThinMaterial)
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
                                .fill(.ultraThinMaterial)
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
                
                // Vinyl-style artwork
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [AppColors.primary.opacity(0.4), .clear], center: .center, startRadius: 140, endRadius: 200))
                        .frame(width: 400, height: 400)
                        .blur(radius: 30)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color(white: 0.1), Color(white: 0.15), Color(white: 0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 300, height: 300)
                        .overlay(
                            Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        )
                    
                    // Grooves
                    ForEach(0..<8) { i in
                        Circle().stroke(Color.white.opacity(0.03), lineWidth: 1)
                            .frame(width: CGFloat(280 - i * 30), height: CGFloat(280 - i * 30))
                    }
                    
                    // Center artwork
                    if let artwork = musicPlayerManager.currentSongArtwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3))
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.white)
                    }
                }
                .rotationEffect(.degrees(rotationAngle))
                .frame(height: 320)
                
                // Song info
                VStack(spacing: 8) {
                    Text(musicPlayerManager.currentSong?.title ?? "Unknown Title")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(musicPlayerManager.currentSong?.artist ?? "Unknown Artist")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 40)
                
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
                
                // Playback controls
                HStack(spacing: 50) {
                    Button(action: { musicPlayerManager.playPrevious() }) {
                        Image(systemName: "backward.fill").font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    
                    Button(action: { musicPlayerManager.togglePlayPause() }) {
                        Image(systemName: musicPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 85, height: 85)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { musicPlayerManager.playNext() }) {
                        Image(systemName: "forward.fill").font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            startRotationAnimation()
            startPulseAnimation()
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
    
    private func startRotationAnimation() {
        guard musicPlayerManager.isPlaying else { return }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseAnimation = true
        }
    }
}

// MARK: - Supporting Views

struct AnimatedGradientBackground: View {
    let isPlaying: Bool
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color(red: 0.15, green: 0.1, blue: 0.3),
                Color(red: 0.08, green: 0.03, blue: 0.15)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

struct ControlButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
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
                    .fill(.ultraThinMaterial)
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
                    .fill(.ultraThinMaterial)
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
