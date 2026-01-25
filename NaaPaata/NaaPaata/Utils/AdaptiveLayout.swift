//
//  AdaptiveLayout.swift
//  NaaPaata
//
//  Created for adaptive layouts across devices
//

import SwiftUI

struct AdaptiveLayout {
    let horizontalSizeClass: UserInterfaceSizeClass?
    let screenWidth: CGFloat
    
    // MARK: - Grid Columns
    /// Returns adaptive number of columns based on screen width
    /// - iPhone: 2 columns
    /// - iPad Portrait / Small iPad: 3 columns  
    /// - iPad Landscape / Small macOS: 4 columns
    /// - Large macOS displays: 6 columns
    var gridColumns: Int {
        if screenWidth > 1200 { return 6 }  // Large displays
        if screenWidth > 900 { return 4 }   // iPad landscape / macOS
        if screenWidth > 600 { return 3 }   // iPad portrait
        return 2                             // iPhone
    }
    
    // MARK: - Card Sizing
    /// Calculates adaptive card image size based on available space
    /// Returns size that fits within grid, capped at 200pt
    var cardImageSize: CGFloat {
        let availableWidth = screenWidth - (horizontalPadding * 2) - (CGFloat(gridColumns - 1) * gridSpacing)
        let cardWidth = availableWidth / CGFloat(gridColumns)
        return min(cardWidth * 0.85, 200)  // Cap at 200 to prevent overly large cards
    }
    
    /// Height for playlist cards (slightly shorter than width for better aspect ratio)
    var playlistCardHeight: CGFloat {
        return min(cardImageSize * 0.9, 160)
    }
    
    // MARK: - Spacing & Padding
    /// Spacing between grid items
    var gridSpacing: CGFloat {
        screenWidth > 900 ? 24 : 16
    }
    
    /// Horizontal padding for content
    var horizontalPadding: CGFloat {
        screenWidth > 900 ? 40 : 20
    }
    
    /// Vertical spacing between elements
    var verticalSpacing: CGFloat {
        screenWidth > 900 ? 16 : 10
    }
    
    /// Padding for mini player from bottom (tab bar height varies)
    var miniPlayerBottomPadding: CGFloat {
        screenWidth > 600 ? 60 : 48
    }
    
    /// Horizontal padding for mini player
    var miniPlayerHorizontalPadding: CGFloat {
        screenWidth > 900 ? 20 : 8
    }
    
    // MARK: - Music Player Sizing
    /// Album artwork size in full music player view
    var albumArtSize: CGFloat {
        if horizontalSizeClass == .regular && screenWidth > 600 {
            return min(screenWidth * 0.6, 500)  // iPad: 60% of width, max 500
        }
        return min(screenWidth * 0.85, 350)  // iPhone: 85% of width, max 350
    }
    
    /// Size for control buttons in music player
    var controlButtonSize: CGFloat {
        horizontalSizeClass == .regular ? 60 : 50
    }
    
    /// Size for play/pause button (larger than other controls)
    var playButtonSize: CGFloat {
        horizontalSizeClass == .regular ? 80 : 70
    }
    
    // MARK: - Detail View Sizing
    /// Album/Playlist artwork in detail views
    var detailArtworkSize: CGFloat {
        if horizontalSizeClass == .regular && screenWidth > 600 {
            return 280  // iPad
        }
        return 200  // iPhone
    }
    
    // MARK: - Font Scaling
    /// Scale factor for titles based on screen size
    var titleFontScale: CGFloat {
        screenWidth > 900 ? 1.2 : 1.0
    }
    
    /// Scale factor for body text
    var bodyFontScale: CGFloat {
        screenWidth > 900 ? 1.1 : 1.0
    }
}

// MARK: - Environment Extension
extension EnvironmentValues {
    var adaptiveLayout: AdaptiveLayout {
        AdaptiveLayout(
            horizontalSizeClass: self.horizontalSizeClass,
            screenWidth: UIScreen.main.bounds.width
        )
    }
}
