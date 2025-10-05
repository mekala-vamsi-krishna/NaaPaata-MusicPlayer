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
                print("Created MyAppFiles folder at \(musicFolder.path)")
            } catch {
                print("Error creating folder: \(error)")
                return []
            }
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: musicFolder,
                                                            includingPropertiesForKeys: nil,
                                                            options: [.skipsHiddenFiles])
                .filter { $0.pathExtension.lowercased() == "mp3" }
            
           // self.mp3Files = files
           // musicPlayerManager.playFromAllSongs(files)
            print("Loaded all  music files. ")
            return files
        } catch {
            print("Error reading mp3 files: \(error)")
           // self.mp3Files = []
            return []
        }
    }
}
