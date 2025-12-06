//
//  SongModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct Song: Identifiable, Hashable, Codable, Equatable {
    let id: UUID
    let url: URL
    var title: String
    var artist: String
    var duration: TimeInterval
    var artworkData: Data? // instead of UIImage
    var dateAdded: Date?
    
    // Security scoped bookmark for file access persistence
    var bookmarkData: Data?

    init(id: UUID = UUID(),
         url: URL,
         title: String,
         artist: String,
         duration: TimeInterval,
         artworkImage: UIImage? = nil,
         dateAdded: Date? = nil) {
        self.id = id
        self.url = url
        self.title = title
        self.artist = artist
        self.duration = duration
        self.artworkData = artworkImage?.jpegData(compressionQuality: 0.9)
        self.dateAdded = dateAdded
        
        // Create security scoped bookmark for the file
        self.bookmarkData = try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    var artworkImage: UIImage? {
        guard let data = artworkData else { return nil }
        return UIImage(data: data)
    }
    
    // Get the actual file URL, resolving from bookmark if needed
    var resolvedURL: URL? {
        if let bookmarkData = bookmarkData {
            var isStale = false
            if let resolvedURL = try? URL(resolvingBookmarkData: bookmarkData, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale) {
                return resolvedURL
            }
        }
        // Fallback to original URL
        return url
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
