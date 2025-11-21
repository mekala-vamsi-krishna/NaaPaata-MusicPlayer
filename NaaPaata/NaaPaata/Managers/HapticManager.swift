//
//  HapticManager.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/16/25.
//

import Foundation
import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
