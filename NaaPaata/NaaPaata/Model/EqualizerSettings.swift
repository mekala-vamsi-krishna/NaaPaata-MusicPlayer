//
//  EqualizerSettings.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/29/25.
//

import Foundation

struct EqualizerSettings: Codable {
    var isEnabled: Bool = true
    var preAmpValue: Double = 0.0
    var bassValue: Double = 0.0
    var trebleValue: Double = 0.0
    var bands: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var selectedPreset: String = "Custom"
    
    // Individual knob toggles
    var isPreAmpEnabled: Bool = true
    var isBassEnabled: Bool = true
    var isTrebleEnabled: Bool = true
    
    static let defaultSettings = EqualizerSettings()
}
