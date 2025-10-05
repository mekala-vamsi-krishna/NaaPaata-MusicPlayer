//
//  SongModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/5/25.
//

import Foundation

struct Song: Identifiable, Hashable, Codable {
    let id = UUID()
    let title: String
    let artist: String
    let duration: TimeInterval
    let artworkImage: String // Use UIImage in real app
    var dateAdded: Date
}
