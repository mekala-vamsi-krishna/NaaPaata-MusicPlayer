//
//  MainTabView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
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
        .accentColor(AppColors.primary) // Use your primary purple color
    }
}

#Preview {
    MainTabView()
}
