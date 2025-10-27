//
//  MainTabView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

class TabState: ObservableObject {
    @Published var selectedTab: Int = 0
}

struct MainTabView: View {
    @EnvironmentObject var tabState: TabState
    @StateObject private var musicPlayerManager = MusicPlayerManager.shared
    @StateObject private var playlistsViewModel = PlaylistsViewModel()
    
    @State private var showFullPlayer = false

    var body: some View {
        ZStack {
            TabView(selection: $tabState.selectedTab) {
                SongsView()
                    .tabItem {
                        Image(systemName: "music.quarternote.3")
                        Text("Songs")
                    }
                    .tag(0)
                
                AlbumsView()
                    .tabItem {
                        Image(systemName: "rectangle.stack.badge.play")
                        Text("Albums")
                    }
                    .tag(1)
                
                PlayListsView()
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("Lists")
                    }
                    .tag(2)
            }
            .accentColor(AppColors.primary)

            // Mini player above tab bar
            VStack {
                Spacer()
                if musicPlayerManager.currentSong != nil {
                    MiniPlayerView()
                        .onTapGesture {
                            showFullPlayer.toggle()
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 48) // tab bar height
                }
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            MusicPlayerView()
                .environmentObject(musicPlayerManager)
                .environmentObject(playlistsViewModel)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(TabState())
}
