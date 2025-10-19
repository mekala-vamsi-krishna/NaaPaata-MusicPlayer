//
//  MetaDataService.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/17/25.
//

import Foundation
import AVFoundation
import UIKit

final class MetadataService {
    static let shared = MetadataService()
    private init() {}

    func extractMetadata(from url: URL) async -> Song {
        let asset = AVAsset(url: url)
        var title = url.lastPathComponent
        var artist = "Unknown Artist"
        var duration: TimeInterval = 0

        do {
            let metadata = try await asset.load(.commonMetadata)
            for meta in metadata {
                if meta.commonKey?.rawValue == "artist",
                   let artistValue = try? await meta.load(.stringValue) {
                    artist = artistValue
                } else if meta.commonKey?.rawValue == "title",
                          let titleValue = try? await meta.load(.stringValue) {
                    title = titleValue
                }
            }
            let time = try await asset.load(.duration)
            duration = CMTimeGetSeconds(time)
        } catch {
            print("Error loading metadata for \(url): \(error)")
        }

        // Always return Song with string fallback, not UIImage
        return Song(url: url, title: title, artist: artist, duration: duration)
    }
}

