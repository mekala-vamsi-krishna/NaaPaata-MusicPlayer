//
//  SubscriptionsView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/30/25.
//

import SwiftUI
import StoreKit

struct SubscriptionsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var store: StoreManager
    
    @State private var selectedProductID: String = "Naa_Paata_12M"
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            // Animated Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.3),
                    AppColors.primary.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating particles effect
            GeometryReader { geometry in
                ForEach(0..<15) { index in
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 10)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        // Close Button
                        HStack {
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // Premium Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 10)
                        }
                        .padding(.top, 20)
                        
                        Text("Unlock Premium")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Get unlimited access to all premium features")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                    
                    // Features List
                    VStack(spacing: 16) {
                        FeatureRow(icon: "waveform", title: "Advanced Equalizer", description: "10-band EQ with custom presets")
                        FeatureRow(icon: "speaker.wave.3.fill", title: "Enhanced Audio", description: "Premium sound processing")
                        FeatureRow(icon: "music.note.list", title: "Unlimited Songs & Playlists", description: "Create as many as you want")
                        FeatureRow(icon: "sparkles", title: "Ad-Free Experience", description: "No interruptions, ever")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Subscription Plans
                    VStack(spacing: 16) {
                        Text("Choose Your Plan")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                        
                        if store.subscriptions.isEmpty {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(40)
                        } else {
                            ForEach(store.subscriptions, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProductID == product.id,
                                    onTap: { selectedProductID = product.id }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // Subscribe Button
                    Button(action: {
                        guard let selectedProduct = store.subscriptions.first(where: { $0.id == selectedProductID }) else { return }
                        isProcessing = true
                        Task {
                            await store.purchase(selectedProduct)
                            isProcessing = false
                            if store.isPremimumUser {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    .disabled(isProcessing || store.subscriptions.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Restore Purchases
                    Button(action: {
                        Task {
                            await store.restorePurchases()
                            if store.isPremimumUser {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.bottom, 20)
                    
                    // Terms & Privacy
                    HStack(spacing: 16) {
                        Button("Terms of Service") { }
                        Text("•")
                        Button("Privacy Policy") { }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 30)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert(item: $store.purchaseError) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Success!", isPresented: .constant(store.purchaseSuccessMessage != nil)) {
            Button("OK") {
                store.purchaseSuccessMessage = nil
            }
        } message: {
            Text(store.purchaseSuccessMessage ?? "")
        }
        .alert("Restore Purchases", isPresented: $store.showRestoredAlert) {
            Button("OK") {
                store.showRestoredAlert = false
            }
        } message: {
            Text(store.restoredMessage)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.green)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var badge: String? {
        switch product.id {
        case "Naa_Paata_6M":
            return "POPULAR"
        case "Naa_Paata_12M":
            return "BEST VALUE"
        default:
            return nil
        }
    }
    
    var savings: String? {
        switch product.id {
        case "Naa_Paata_6M":
            return "Save 17%"
        case "Naa_Paata_12M":
            return "Save 33%"
        default:
            return nil
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Badge
                if let badge = badge {
                    HStack {
                        Spacer()
                        Text(badge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8, corners: [.topRight, .bottomLeft])
                        Spacer()
                    }
                    .offset(y: -1)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(product.displayPrice)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(isSelected ? AppColors.primary : .white)
                            
                            Text(subscriptionPeriod(for: product))
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection Indicator
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? AppColors.primary : Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 28, height: 28)
                        
                        if isSelected {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected
                        ? LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? AppColors.primary : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.primary.opacity(0.3) : Color.clear,
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func subscriptionPeriod(for product: Product) -> String {
        if let subscription = product.subscription {
            switch subscription.subscriptionPeriod.unit {
            case .month:
                let count = subscription.subscriptionPeriod.value
                return count == 1 ? "per month" : "every \(count) months"
            case .year:
                return "per year"
            default:
                return ""
            }
        }
        return ""
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    SubscriptionsView()
        .environmentObject(StoreManager())
}
