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
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @State private var showFullPlayer = false

    var body: some View {
        ZStack {
            TabView(selection: $tabState.selectedTab) {
                SongsView()
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Songs")
                    }
                    .tag(0)
                    

                AlbumsView()
                    .tabItem {
                        Image(systemName: "rectangle.stack.fill")
                        Text("Albums")
                    } .tag(1)
                  

                PlayListsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Lists")
                    } .tag(2)
                    
            }
            .accentColor(AppColors.primary) // purple tint for tab bar

            // Mini player sits above tab bar with spacing
            VStack {
                Spacer()
                if let _ = musicPlayerManager.currentTrack {
                    VStack(spacing: 0) {
                        MiniPlayerView()
                            .onTapGesture {
                                showFullPlayer.toggle()
                            }
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
