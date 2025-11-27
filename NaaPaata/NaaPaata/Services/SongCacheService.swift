//
//  SongCacheService.swift
//  NaaPaata
//
//  Created by Agent on 11/26/25.
//

import Foundation

class SongCacheService {
    static let shared = SongCacheService()
    
    private let cacheFileName = "songs_cache.json"
    
    private var cacheFileURL: URL? {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docsURL.appendingPathComponent(cacheFileName)
    }
    
    func saveSongs(_ songs: [Song]) {
        guard let url = cacheFileURL else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(songs)
                try data.write(to: url)
                print("Saved \(songs.count) songs to cache.")
            } catch {
                print("Failed to save songs to cache: \(error)")
            }
        }
    }
    
    func loadSongs() -> [Song]? {
        guard let url = cacheFileURL, FileManager.default.fileExists(atPath: url.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let songs = try JSONDecoder().decode([Song].self, from: data)
            print("Loaded \(songs.count) songs from cache.")
            return songs
        } catch {
            print("Failed to load songs from cache: \(error)")
            return nil
        }
    }
    
    func clearCache() {
        guard let url = cacheFileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
