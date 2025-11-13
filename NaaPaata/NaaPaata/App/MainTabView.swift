//
//  MainTabView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

class TabState: ObservableObject {
    @AppStorage("selectedTab") var selectedTab: Int = 0
}

struct MainTabView: View {
    @EnvironmentObject var tabState: TabState
    @StateObject private var musicPlayerManager = MusicPlayerManager.shared
    @StateObject private var playlistsViewModel = PlaylistsViewModel()
    
    @State private var showFullPlayer = false
    @State private var showBuyMeCoffeeSheet = false

    var body: some View {
        ZStack {
            // MARK: - Main Tabs
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
                
                // MARK: - Custom Buy Me a Coffee Tab
                Color.clear
                    .tabItem {
                        Image("BuyMeCoffee")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(6)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
                    }
                    .tag(3)
            }
            .accentColor(AppColors.primary)
            .onChange(of: tabState.selectedTab) { newValue in
                if newValue == 3 {
                    tabState.selectedTab = 0
                    showBuyMeCoffeeSheet = true
                }
            }
            .sheet(isPresented: $showBuyMeCoffeeSheet) {
                if let url = URL(string: "https://buymeacoffee.com/mekalavamsikrishna") {
                    SafariView(url: url)
                        .presentationDetents([.large]) // makes it appear as a large bottom sheet
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            
            // MARK: - Mini Player above Tab Bar
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
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(TabState())
}
