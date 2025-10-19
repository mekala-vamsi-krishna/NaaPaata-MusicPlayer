//
//  SongModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct Song: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    var title: String
    var artist: String
    var duration: TimeInterval
    var artworkImage: UIImage? = nil // optional UIImage
    var dateAdded: Date?
    
    var displayName: String {
        title.isEmpty ? url.lastPathComponent : title
    }
    
    // Helper to get SwiftUI Image
    var artwork: Image {
        if let uiImage = artworkImage {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "music.note")
        }
    }
}



