//
//  AlbumModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 10/18/25.
//

import Foundation
import SwiftUI

struct Album: Identifiable {
    let id = UUID()
    let name: String
    var artworkImage: UIImage? = nil
    var songs: [Song]
    
    var artwork: Image {
        if let uiImage = artworkImage {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "opticaldisc")
        }
    }
}

