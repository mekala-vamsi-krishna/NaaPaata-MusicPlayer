//
//  OnboardingView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/1/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Naa Paata",
            description: "Your personal music player. Add your own MP3 files to start listening to your music collection.",
            image: "music.note.house",
            color: AppColors.primary
        ),
        OnboardingPage(
            title: "Get MP3 Files",
            description: "Download MP3 files from music stores, streaming services (where permitted), or transfer from your computer. Make sure they are in .mp3 format.",
            image: "arrow.down.circle",
            color: Color.green
        ),
        OnboardingPage(
            title: "Add to App Folder",
            description: "Open Files app → On My iPhone → Naa Paata → Music folder. Place your MP3 files here to sync with Naa Paata. The path should be: Files → On My iPhone → Naa Paata → Music",
            image: "folder.badge.gearshape",
            color: Color.orange
        ),
        OnboardingPage(
            title: "Enjoy Your Music",
            description: "Once files are in the Music folder, they'll automatically appear in Naa Paata. Start listening to your personal collection!",
            image: "play.circle",
            color: Color.purple
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppColors.primary.opacity(0.1),
                    AppColors.primary.opacity(0.05),
                    Color.black.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Page indicator
                PageControl(currentPage: $currentPage, numberOfPages: pages.count)
                    .padding(.top, 20)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isCurrentPage: currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation controls
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.black.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .clipShape(Capsule())
                        }
                    } else {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                                .background(AppColors.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let image: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isCurrentPage: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.image)
                    .font(.system(size: 60))
                    .foregroundColor(page.color)
            }
            .scaleEffect(isCurrentPage ? 1.0 : 0.8)
            .opacity(isCurrentPage ? 1.0 : 0.7)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 30)
            
            // Description
            Text(page.description)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
                .lineSpacing(5)
        }
        .padding(.horizontal, 30)
        .opacity(isCurrentPage ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: isCurrentPage)
    }
}

struct PageControl: View {
    @Binding var currentPage: Int
    let numberOfPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? AppColors.primary : Color.gray.opacity(0.3))
                    .frame(width: currentPage == index ? 25 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }
}

