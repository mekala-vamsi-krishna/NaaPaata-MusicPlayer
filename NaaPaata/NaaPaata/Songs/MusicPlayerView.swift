//
//  MusicPlayerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @Environment(\.dismiss) var dismiss
    
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0
    @State private var pulseAnimation = false
    @GestureState private var dragState = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(isPlaying: musicPlayerManager.isPlaying)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
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
                
                // Vinyl-style album art with 3D rotation
                VStack(spacing: 30) {
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppColors.primary.opacity(0.4),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 140,
                                    endRadius: 200
                                )
                            )
                            .frame(width: 400, height: 400)
                            .blur(radius: 30)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        
                        // Vinyl disk
                        ZStack {
                            // Disk shadow
                            Circle()
                                .fill(.black.opacity(0.3))
                                .frame(width: 300, height: 300)
                                .blur(radius: 20)
                                .offset(y: 10)
                            
                            // Main vinyl disk
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(white: 0.1),
                                            Color(white: 0.15),
                                            Color(white: 0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.3), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            
                            // Grooves effect
                            ForEach(0..<8) { i in
                                Circle()
                                    .stroke(Color.white.opacity(0.03), lineWidth: 1)
                                    .frame(width: CGFloat(280 - i * 30), height: CGFloat(280 - i * 30))
                            }
                            
                            // Center album art
                            Image(uiImage: musicPlayerManager.artworkImage ?? UIImage(systemName: "music.note")!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.white.opacity(0.5), .clear],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            // Center hole
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(white: 0.2), Color(white: 0.05)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 20
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .rotation3DEffect(
                            .degrees(isDragging ? 5 : 0),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(isDragging ? 0.95 : 1.0)
                    }
                    .frame(height: 320)
                    
                    // Song info with glassmorphism
                    VStack(spacing: 8) {
                        Text(musicPlayerManager.currentTitle ?? "Unknown Title")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(musicPlayerManager.artistName ?? "Unknown Artist")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Futuristic progress bar
                VStack(spacing: 12) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track with particles
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 8)
                                
                                // Active progress with gradient
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppColors.primary,
                                                AppColors.primary.opacity(0.6)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: progressWidth(totalWidth: geometry.size.width), height: 8)
                                    .shadow(color: AppColors.primary.opacity(0.5), radius: 8, x: 0, y: 0)
                                
                                // Animated shimmer on progress
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                .white.opacity(0.3),
                                                .clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 50, height: 8)
                                    .offset(x: progressWidth(totalWidth: geometry.size.width) - 25)
                                
                                // Draggable thumb
                                Circle()
                                    .fill(.white)
                                    .frame(width: isDragging ? 24 : 18, height: isDragging ? 24 : 18)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        Circle()
                                            .stroke(AppColors.primary.opacity(0.5), lineWidth: 2)
                                            .scaleEffect(isDragging ? 1.5 : 1.0)
                                            .opacity(isDragging ? 0 : 1)
                                    )
                                    .offset(x: progressWidth(totalWidth: geometry.size.width) - (isDragging ? 12 : 9))
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($dragState) { value, state, _ in
                                    state = true
                                }
                                .onChanged { value in
                                    withAnimation(.interactiveSpring()) {
                                        isDragging = true
                                    }
                                    let progress = min(max(0, value.location.x / geometry.size.width), 1)
                                    dragOffset = progress * geometry.size.width
                                }
                                .onEnded { value in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isDragging = false
                                    }
                                    let progress = min(max(0, value.location.x / geometry.size.width), 1)
                                    // Update music position here
                                }
                        )
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 32)
                    
                    // Time labels
                    HStack {
                        Text(formatTime(musicPlayerManager.currentTime))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .monospacedDigit()
                        
                        Spacer()
                        
                        Text(formatTime(musicPlayerManager.duration))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 20)
                
                // Control buttons with glassmorphism
                HStack(spacing: 50) {
                    ControlButton(icon: "backward.fill", size: 28) {
                        musicPlayerManager.playPrevious()
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            musicPlayerManager.togglePlayPause()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 85, height: 85)
                                .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.8), AppColors.primary.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 85, height: 85)
                            
                            Image(systemName: musicPlayerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .offset(x: musicPlayerManager.isPlaying ? 0 : 3)
                        }
                        .scaleEffect(musicPlayerManager.isPlaying ? 1.0 : 1.05)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    ControlButton(icon: "forward.fill", size: 28) {
                        musicPlayerManager.playNext()
                    }
                }
                .padding(.bottom, 30)
                
                // Volume and additional controls
                HStack(spacing: 40) {
                    SmallControlButton(icon: "shuffle") {
                        // ...
                    }
                    
                    HStack(spacing: 16) {
                        Image(systemName: "speaker.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(width: 140, height: 6)
                            .overlay(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 100, height: 6),
                                alignment: .leading
                            )
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    SmallControlButton(icon: "repeat") {
                        // ...
                    }
                }
                .padding(.bottom, 40)
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
        let progress = CGFloat(musicPlayerManager.currentTime / musicPlayerManager.duration)
        return totalWidth * progress
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

//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
//    }
//}

// MARK: - Preview
struct MusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerView()
            .environmentObject(MusicPlayerManager())
    }
}

#Preview {
    MusicPlayerView()
}
