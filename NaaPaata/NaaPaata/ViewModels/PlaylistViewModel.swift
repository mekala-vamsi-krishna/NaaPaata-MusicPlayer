//
//  PlaylistViewModel.swift
//  NaaPaata
//
//  Created by User on 06/10/25.
//

import Foundation
class PlaylistViewModel:ObservableObject {
    @Published  var playlists: [Playlist] = []
    init() {
        self.playlists =  loadStaticPlaylistData()
    }
}


extension PlaylistViewModel {
    func loadStaticPlaylistData() -> [Playlist] {
        let playlist =  [
        Playlist(
            name: "Chill Vibes",
            songs: [
                Song(title: "Midnight Dreams", artist: "Luna Bay", duration: 245, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 5)),
                Song(title: "Ocean Waves", artist: "Coastal Hearts", duration: 198, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 3)),
                Song(title: "Starlight", artist: "Nova Sound", duration: 212, artworkImage: "music.note", dateAdded: Date().addingTimeInterval(-86400 * 2))
            ],
            coverImage: "music.note.list",
            description: "Perfect playlist for relaxing",
            isPrivate: false,
            dateCreated: Date().addingTimeInterval(-86400 * 30)
        ),
        Playlist(
            name: "Workout Mix",
            songs: [
                Song(title: "Thunder Storm", artist: "Weather Sounds", duration: 267, artworkImage: "music.note", dateAdded: Date()),
                Song(title: "Electric Feel", artist: "Neon Pulse", duration: 223, artworkImage: "music.note", dateAdded: Date())
            ],
            coverImage: "music.note.list",
            description: "High energy workout tracks",
            isPrivate: false,
            dateCreated: Date().addingTimeInterval(-86400 * 15)
        )
        
        ]
        return playlist
    }
}
