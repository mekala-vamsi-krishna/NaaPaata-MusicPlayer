//
//  LoadAllSongsFromDocuments.swift
//  NaaPaata
//
//  Created by User on 05/10/25.
//

import Foundation
/// Single ResponsblityClass whose job is to return all mp3 files urls  if they exist or else  emty
class LoadAllSongsFromDocuments {
    public func loadSongsFromDocuments() -> [URL] {
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        let musicFolder = docsURL.appendingPathComponent("Music", isDirectory: true)
        
        // Create folder if not exists
        if !fileManager.fileExists(atPath: musicFolder.path) {
            do {
                try fileManager.createDirectory(at: musicFolder, withIntermediateDirectories: true, attributes: nil)
                print("Created Music folder at \(musicFolder.path)")
            } catch {
                print("Error creating folder: \(error)")
                return []
            }
        }
        
        guard let enumerator = fileManager.enumerator(at: musicFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return []
        }
        
        let mp3Files = enumerator.compactMap { element -> URL? in
            guard let url = element as? URL, url.pathExtension.lowercased() == "mp3" else { return nil }
            return url
        }
        
        print("Loaded \(mp3Files.count) music files including subfolders.")
        return mp3Files
    }

}
