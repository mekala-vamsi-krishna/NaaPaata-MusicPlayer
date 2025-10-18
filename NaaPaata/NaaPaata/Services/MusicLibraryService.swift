//
//  MusicLibraryService.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/17/25.
//

import Foundation

final class MusicLibraryService {
    static let shared = MusicLibraryService()
    private init() {}

    func fetchAllSongs() -> [URL] {
        // Your existing logic from loadSongsFromDocuments()
        let loader = LoadAllSongsFromDocuments()
        return loader.loadSongsFromDocuments()
    }
}
