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
    @StateObject var songsViewModel = SongsViewModel() // Initialize here
    @ObservedObject var tabState = TabState()
    @StateObject private var storeKitManager = StoreManager()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
  
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(musicPlayerManager)
                    .environmentObject(playlistsViewModel)
                    .environmentObject(songsViewModel) // Inject into environment
                    .environmentObject(tabState)
                    .environmentObject(storeKitManager)
                    .onAppear {
                        songsViewModel.loadSongs() // Load songs on app launch
                    }
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
                /// whenver app comes on forground after reaminings for long in background fetched the refresh status whether user has taken a subscription plan or not.
               await storeKitManager.loadProducts()
               await storeKitManager.updateSubscriptionStatus()
                
            }
        }
    }
    
    @Environment(\.scenePhase) private var scenePhase
}
