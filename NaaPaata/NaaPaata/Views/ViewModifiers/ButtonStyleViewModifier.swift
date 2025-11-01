//
//  ButotnStyleViewModifiers.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/1/25.
//

import SwiftUI

struct PlayPauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .rotationEffect(.degrees(configuration.isPressed ? 5 : 0))
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

// MARK: - Supporting Colors (from your neumorphic theme)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
