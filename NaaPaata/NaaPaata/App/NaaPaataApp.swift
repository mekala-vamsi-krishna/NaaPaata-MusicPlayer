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
    @StateObject var playlistsViewModel =  PlaylistsViewModel()
    @ObservedObject var tabState = TabState()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
  
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(musicPlayerManager)
                    .environmentObject(playlistsViewModel)
                    .environmentObject(tabState)
            } else {
                OnboardingView()
                    .environmentObject(musicPlayerManager)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Save playback state when app goes to background
                musicPlayerManager.saveCurrentPlaybackState()
            } else if newPhase == .active {
                // Restore playback state when app becomes active
                musicPlayerManager.restoreLastPlaybackState()
            }
        }
    }
    
    @Environment(\.scenePhase) private var scenePhase
}
