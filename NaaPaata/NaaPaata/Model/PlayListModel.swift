//
//  PlayListModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct Playlist: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var songs: [Song]
    var coverImageData: Data? // store cover image data
    var description: String
    var isPrivate: Bool
    var dateCreated: Date
    var folderName: String
    
    init(
        id: UUID = UUID(),
        name: String,
        songs: [Song] = [],
        coverImage: UIImage? = nil,
        description: String = "",
        isPrivate: Bool = false,
        dateCreated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.songs = songs
        self.coverImageData = coverImage?.jpegData(compressionQuality: 0.9)
        self.description = description
        self.isPrivate = isPrivate
        self.dateCreated = dateCreated
        self.folderName = name
    }
    
    var coverImage: UIImage? {
        guard let data = coverImageData else { return nil }
        return UIImage(data: data)
    }
}

enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case title = "Title"
    case artist = "Artist"
    case duration = "Duration"
}

