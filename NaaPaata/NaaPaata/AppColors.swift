//
//  AppColors.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // Skip #
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

struct AppColors {
    static let primary = Color(hex: "#AF52DE")        // Electric Purple
    static let secondary = Color(hex: "#D8B4FE")      // Soft lavender for gradients
    static let background = Color(hex: "#F2F2F7")     // Light Gray
    static let textPrimary = Color(hex: "#1C1C1E")    // Dark Gray
    static let textSecondary = Color(hex: "#636366")  // Gray
    static let error = Color(hex: "#FF453A")          // Bright Red
    static let cardBackground = Color(white: 0.95)    // Light gray
}
