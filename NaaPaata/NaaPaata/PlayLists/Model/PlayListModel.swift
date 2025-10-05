//
//  PlayListModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import Foundation


struct Playlist: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var songs: [Song]
    var coverImage: String
    var description: String
    var isPrivate: Bool
    var dateCreated: Date
    
    // Default initializer for empty playlists
    init(name: String, songs: [Song] = [], coverImage: String = "music.note.list", description: String = "", isPrivate: Bool = false, dateCreated: Date = Date()) {
        self.name = name
        self.songs = songs
        self.coverImage = coverImage
        self.description = description
        self.isPrivate = isPrivate
        self.dateCreated = dateCreated
    }
}

enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case title = "Title"
    case artist = "Artist"
    case duration = "Duration"
}

