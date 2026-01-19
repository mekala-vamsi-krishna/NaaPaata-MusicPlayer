//
//  EqualizerView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/29/25.
//

import SwiftUI

extension EqualizerView {
    private var LockedView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 54))
                .foregroundColor(AppColors.primary)

            Text("Unlock Equalizer")
                .font(.title.bold())
                .foregroundColor(AppColors.textPrimary)

            Text("Subscribe to enable the Equalizer and enjoy enhanced audio quality.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 26)

            Button(action: { showPaywall = true }) {
                Text("Get Premium")
                    .font(.headline)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 26)

            Button("Restore Purchases") {
                Task { await store.restorePurchases() }
            }
            .padding(.top, 4)
            .font(.subheadline)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

extension EqualizerView {
    private var PremiumEqualizerContent: some View {
        NavigationStack {
            ZStack {
                // Background
                if colorScheme == .dark {
                    LinearGradient(
                        colors: [
                            AppColors.background,
                            Color(hex: "#1A1A2E"), // Deep dark blue/purple
                            AppColors.primary.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                } else {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    // Header / Toggle
                    HStack {
                        Text("Equalizer")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.textPrimary, AppColors.primary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isEnabled)
                            .labelsHidden()
                            .tint(AppColors.primary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            
                            // 1. Presets (Top)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.presets, id: \.self) { preset in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.selectPreset(preset)
                                            }
                                        }) {
                                            Text(preset)
                                                .font(.system(size: 14, weight: viewModel.selectedPreset == preset ? .bold : .medium))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    Capsule()
                                                        .fill(
                                                            viewModel.selectedPreset == preset
                                                            ? AppColors.primary
                                                            : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
                                                        )
                                                )
                                                .foregroundColor(
                                                    viewModel.selectedPreset == preset
                                                    ? .white
                                                    : (colorScheme == .dark ? .white : .black)
                                                )
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(
                                                            viewModel.selectedPreset == preset
                                                            ? AppColors.primary
                                                            : (colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1)),
                                                            lineWidth: viewModel.selectedPreset == preset ? 2 : 1
                                                        )
                                                )
                                                .shadow(
                                                    color: viewModel.selectedPreset == preset
                                                    ? AppColors.primary.opacity(0.3)
                                                    : Color.clear,
                                                    radius: 4,
                                                    x: 0,
                                                    y: 2
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // 2. Rotary Knobs (Middle)
                            HStack(spacing: 30) {
                                RotaryKnobView(title: "Pre-Amp", value: $viewModel.preAmpValue, isEnabled: $viewModel.isPreAmpEnabled)
                                RotaryKnobView(title: "Bass", value: $viewModel.bassValue, isEnabled: $viewModel.isBassEnabled)
                                RotaryKnobView(title: "Treble", value: $viewModel.trebleValue, isEnabled: $viewModel.isTrebleEnabled)
                            }
                            .padding(.horizontal)
                            .opacity(viewModel.isEnabled ? 1 : 0.5)
                            .disabled(!viewModel.isEnabled)
                            
                            // 3. Frequency Sliders (In Container)
                            VStack(spacing: 8) {
                                Text("Frequency Bands")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    ForEach(0..<viewModel.bands.count, id: \.self) { index in
                                        VStack(spacing: 16) {
                                            // dB Label Top
                                            Text("+12")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(AppColors.textSecondary.opacity(0.7))
                                            
                                            ZStack(alignment: .bottom) {
                                                // Track
                                                Capsule()
                                                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                                                    .frame(width: 4, height: 160)
                                                
                                                // Fill (Glowing)
                                                Capsule()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [AppColors.primary, AppColors.secondary],
                                                            startPoint: .bottom,
                                                            endPoint: .top
                                                        )
                                                    )
                                                    .frame(width: 4, height: 80 + (CGFloat(viewModel.bands[index]) * 6.6))
                                                    .shadow(color: AppColors.primary.opacity(0.5), radius: 4, x: 0, y: 0)
                                                
                                                // Thumb (Minimalist)
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 12, height: 12)
                                                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                                    .offset(y: -(80 + (CGFloat(viewModel.bands[index]) * 6.6)))
                                                    .padding(.bottom, 0)
                                            }
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        let height = 160.0
                                                        let y = min(max(0, 160 - value.location.y), height)
                                                        let normalized = (y / height) * 24 - 12 // -12 to +12 range
                                                        viewModel.bandChanged(index: index, value: Double(normalized))
                                                    }
                                            )
                                            
                                            // Frequency Label
                                            Text(viewModel.frequencies[index])
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(AppColors.textSecondary)
                                                .rotationEffect(.degrees(-90))
                                                .frame(height: 30)
                                        }
                                        .frame(minWidth: 30)
                                    }
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                            )
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .opacity(viewModel.isEnabled ? 1 : 0.5)
                            .disabled(!viewModel.isEnabled)
                            
                            // 4. Volume Control
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "speaker.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    Text("Volume")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(viewModel.volume * 100))%")
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "speaker.wave.1.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                                    
                                    Slider(value: $viewModel.volume, in: 0...1)
                                        .tint(AppColors.primary)
                                    
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textSecondary.opacity(0.7))
                                }
                                .padding(.horizontal)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                            )
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct EqualizerView: View {
    @StateObject private var viewModel = EqualizerViewModel()
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var store = StoreManager()
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if store.isPremimumUser {
                PremiumEqualizerContent
//            } else {
//                LockedView
//            }
        }
        .onAppear {
            Task { await store.updateSubscriptionStatus() }
        }
        .sheet(isPresented: $showPaywall) {
            SubscriptionsView()
                .environmentObject(store)
        }
        .animation(.easeInOut, value: store.isPremimumUser)
    }
}

#Preview {
    EqualizerView()
}
