//
//  ContentView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 9/13/25.
//

import SwiftUI
import AVFoundation

struct SongsView: View {
    @State private var showDocumentPicker = false
    @State private var mp3Files: [URL] = []

    var body: some View {
        NavigationView {
            VStack {
                if mp3Files.isEmpty {
                    Spacer()
                    
                    Image(systemName: "music.note.list")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(AppColors.primary).opacity(0.7)
                        .padding(.top, 50)
                    
                    Text("Upload your local MP3 music files to enjoy playback anytime.")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                } else {
                    // List of uploaded files
                    List(mp3Files, id: \.self) { fileURL in
                        MP3FileCell(fileURL: fileURL)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Music")
            .navigationBarItems(trailing: smallUploadIconButton)
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { urls in
                    for url in urls {
                        saveFileToAppDirectory(from: url)
                    }
                    mp3Files.append(contentsOf: urls)
                    showDocumentPicker = false
                }
            }
        }
    }
    
    // MARK: - Sub Views
    
    // Small Purple Icon Upload Button in Navigation Bar
    private var smallUploadIconButton: some View {
        Button(action: { showDocumentPicker = true }) {
            Image(systemName: "tray.and.arrow.up.fill")
                .font(.title2)
                .foregroundColor(AppColors.primary)
        }
    }

    // MARK: - Functions
    private func saveFileToAppDirectory(from sourceURL: URL) {
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destURL = documentsDir.appendingPathComponent(sourceURL.lastPathComponent)
        
        do {
            if fileManager.fileExists(atPath: destURL.path) {
                try fileManager.removeItem(at: destURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destURL)
            print("Saved: \(destURL.lastPathComponent)")
        } catch {
            print("Error copying file: \(error)")
        }
    }
}

#Preview {
    SongsView()
}
