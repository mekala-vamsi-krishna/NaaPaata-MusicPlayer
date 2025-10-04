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
        let fileManager = FileManager.default
        guard let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let musicFolder = docsURL.appendingPathComponent("Music", isDirectory: true)
        
        // Create folder if not exists
        if !fileManager.fileExists(atPath: musicFolder.path) {
            do {
                try fileManager.createDirectory(at: musicFolder, withIntermediateDirectories: true, attributes: nil)
                print("Created MyAppFiles folder at \(musicFolder.path)")
            } catch {
                print("Error creating folder: \(error)")
                return
            }
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: musicFolder,
                                                            includingPropertiesForKeys: nil,
                                                            options: [.skipsHiddenFiles])
                .filter { $0.pathExtension.lowercased() == "mp3" }
            
            self.mp3Files = files
            musicPlayerManager.playFromAllSongs(files)
        } catch {
            print("Error reading mp3 files: \(error)")
            self.mp3Files = []
        }
    }

}


#Preview {
    SongsView()
}
