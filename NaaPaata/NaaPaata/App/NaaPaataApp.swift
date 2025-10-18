//
//  NaaPaataApp.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

@main
struct NaaPaataApp: App {
    @StateObject var musicPlayerManager = MusicPlayerManager.shared
    @ObservedObject var tabState = TabState()
  
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(musicPlayerManager)
                .environmentObject(tabState)
            
        }
    }
}
