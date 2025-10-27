//
//  SongModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct Song: Identifiable, Hashable, Codable {
    let id: UUID
    let url: URL
    var title: String
    var artist: String
    var duration: TimeInterval
    var artworkData: Data? // instead of UIImage
    var dateAdded: Date?

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
    }

    var artworkImage: UIImage? {
        guard let data = artworkData else { return nil }
        return UIImage(data: data)
    }
}




