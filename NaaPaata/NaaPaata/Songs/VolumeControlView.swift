//
//  VolumeControlView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/9/25.
//

import SwiftUI
import MediaPlayer
import AVFoundation

struct VolumeControlView: View {
    @State private var volume: Float = 0.5 // Volume range: 0.0 to 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            // Decrease Volume Button
            Button(action: {
                volume = max(volume - 0.1, 0) // Decrease by 10%
                setSystemVolume(to: volume)
            }) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Volume Progress Bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 140, height: 6)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.6)], // Replace with AppColors.primary
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: CGFloat(volume) * 140, height: 6)
            }
            
            // Increase Volume Button
            Button(action: {
                volume = min(volume + 0.1, 1.0) // Increase by 10%
                setSystemVolume(to: volume)
            }) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    // Optional: Set system audio volume using AVAudioSession
    func setSystemVolume(to value: Float) {
        let volumeView = MPVolumeView() // This is from Media Player module
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.value = value
        }
    }
}
