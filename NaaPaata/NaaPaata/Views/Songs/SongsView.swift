//
//  ContentView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

import SwiftUI

struct SongsView: View {
    @EnvironmentObject var musicPlayerManager: MusicPlayerManager
    @EnvironmentObject var tabState: TabState

    @State private var mp3Files: [URL] = []
    @State private var showFullPlayer = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                VStack {
                    if mp3Files.isEmpty {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(AppColors.primary).opacity(0.7)
                            .padding(.top, 50)
                        
                        Text("Add MP3 files to the MyAppFiles folder in the Files app to enjoy playback anytime.")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    } else {
                        List(mp3Files, id: \.self) { fileURL in
                            Button {
                                musicPlayerManager.playFromAllSongs(mp3Files, startAt: fileURL)
                                showFullPlayer = true
                            } label: {
                                MP3FileCell(fileURL: fileURL)
                            }
                            .contextMenu {
                                Button {
                                    /// send user to playlist
                                    tabState.selectedTab = 2
                                    
                                } label: {
                                    HStack {
                                        Text("Add this song to playlist")
                                        Image(systemName: "plus.square.dashed")
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(.purple)
                                    .fontWeight(.semibold)
                                }

                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("My Music")
                .onAppear {
                    loadSongsFromDocuments()
                }
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            MusicPlayerView()
                .environmentObject(musicPlayerManager)
        }
    }
    
    private func loadSongsFromDocuments() {
        let files = LoadAllSongsFromDocuments().loadSongsFromDocuments()
        self.mp3Files = files
        musicPlayerManager.playFromAllSongs(files)
    }

}


#Preview {
    SongsView()
}
