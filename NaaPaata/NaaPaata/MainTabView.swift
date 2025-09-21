//
//  MainTabView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @State private var showFullPlayer = false

    var body: some View {
        ZStack {
            TabView {
                SongsView()
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }

                AlbumsView()
                    .tabItem {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Albums")
                    }

                PlayListsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Lists")
                    }
            }
            .accentColor(AppColors.primary) // purple tint for tab bar

            // ✅ Mini player sits above tab bar with spacing
            VStack {
                Spacer()
                if let _ = musicPlayerManager.currentTrack {
                    VStack(spacing: 0) {
                        Divider() // thin line separator
                        MiniPlayerView()
                            .onTapGesture {
                                showFullPlayer.toggle()
                            }
                            .background(AppColors.cardBackground)
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 48) // leave gap equal to tab bar height
                }
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            MusicPlayerView()
                .environmentObject(musicPlayerManager)
        }
    }
}


#Preview {
    MainTabView()
}
