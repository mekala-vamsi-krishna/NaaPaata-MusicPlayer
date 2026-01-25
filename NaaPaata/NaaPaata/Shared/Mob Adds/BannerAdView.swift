//
//  Ad.swift
//  NaaPaata
//
//  Created by User on 25/01/26.
//

import Foundation
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    var adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        
        // Modern way to find Root View Controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootVC
        }
        
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
