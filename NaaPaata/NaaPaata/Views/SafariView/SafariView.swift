//
//  SafariView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/13/25.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredControlTintColor = UIColor.systemPurple // To match purple theme
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
