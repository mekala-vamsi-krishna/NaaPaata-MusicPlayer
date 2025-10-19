//
//  PlayListModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import SwiftUI

struct Playlist: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var songs: [Song]
    var coverImage: UIImage? = nil
    var description: String
    var isPrivate: Bool
    var dateCreated: Date
    var folderName: String
    
    init(
        name: String,
        songs: [Song] = [],
        coverImage: UIImage? = nil,
        description: String = "",
        isPrivate: Bool = false,
        dateCreated: Date = Date()
    ) {
        self.name = name
        self.songs = songs
        self.coverImage = coverImage
        self.description = description
        self.isPrivate = isPrivate
        self.dateCreated = dateCreated
        self.folderName = name
    }
}

enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case title = "Title"
    case artist = "Artist"
    case duration = "Duration"
}

