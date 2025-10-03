# 🎵 Naa Paata

<img width="473" height="434" alt="Screenshot 2025-09-14 at 2 49 44 AM" src="https://github.com/user-attachments/assets/3edf4256-82dd-4782-b344-f15b19a713a6" />

> **Naa Paata** means *My Song(s)* in Telugu.  
> A sleek and modern iOS music player app that empowers users to upload, organize, and play their local MP3 music files effortlessly.

## 🚀 Main Idea

The goal of **Naa Paata** is to provide a seamless experience for managing and enjoying local music by:
- 📥 Uploading MP3 files via document picker.
- 🎼 Automatically organizing music into albums by extracting metadata.
- 🎧 Managing custom playlists with ease.
- 🎹 Offering a clean, intuitive player interface with smooth playback controls.
- 🌟 Featuring a floating mini-player inspired by Apple Music.
- 🎨 A fresh, shiny color theme for a modern look.

---

## 🎯 Key Features

- ✅ Upload local MP3 files from device storage.
- ✅ Auto-extract metadata: Title, Album, Artwork.
- ✅ View music organized by Albums (with album artwork).
- ✅ Create and manage custom Playlists dynamically.
- ✅ Smooth playback: Play, Pause, Previous, Next.
- ✅ Floating mini-player UI that remains accessible.
- ✅ Supports dark & light themes with consistent design.

---

## 📸 Screenshots
| Albums                                                                                                  | Playlists                                                                                               | Songs                                                                                                   | Album Details View                                                                                            | Music Player                                                                                      |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/7f23ed54-4812-4bc9-84e6-e82afe4d5e56" width="120"> | <img src="https://github.com/user-attachments/assets/a58abba0-8b95-4945-9358-72cbaaf7b85c" width="120"> | <img src="https://github.com/user-attachments/assets/fab5dd70-49c3-4658-9ba1-d96a83890969" width="120"> | <img src="https://github.com/user-attachments/assets/44463aca-48b8-490a-a547-dd3286347931" width="120"> | <img src="https://github.com/user-attachments/assets/097f7c2d-1e5a-42bd-b4af-8ee87e8abc69" width="120"> |


---

## 🎨 Design Theme

- **Primary Color**: Purple (#8A56AC) → Fresh, vibrant, brand-new look.
- **Secondary Colors**:  
    - Light gray backgrounds  
    - White text  
    - Card-style backgrounds with subtle shadows  
- ✨ Rounded corners and consistent padding across the app for a modern aesthetic.

---

## 🏗 Tech Stack

- ✅ SwiftUI – Clean, declarative UI framework.
- ✅ AVFoundation – Audio playback & metadata extraction.
- ✅ Local File System – Store & manage uploaded MP3 files.
- ✅ Combine (Timer) – Track and update playback progress.

---

## 🧱 Project Structure

```plaintext
Naa Paata
├── ContentView.swift
├── MusicPlayerView.swift
├── AlbumsView.swift
├── PlayListsView.swift
├── DocumentPicker.swift
├── Assets.xcassets
├── LaunchScreen.storyboard
└── Info.plist
