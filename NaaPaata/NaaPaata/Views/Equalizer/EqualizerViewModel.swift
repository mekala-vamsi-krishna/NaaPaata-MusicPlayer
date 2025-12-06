//
//  EqualizerViewModel.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/29/25.
//

import SwiftUI
import Combine

class EqualizerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isEnabled: Bool = true {
        didSet { updateEQ() }
    }
    
    @Published var selectedPreset: String = "Custom" {
        didSet {
            if selectedPreset != "Custom" {
                applyPreset(selectedPreset)
            }
            saveSettings()
        }
    }
    
    // Rotary Knobs
    @Published var preAmpValue: Double = 0.0 {
        didSet {
            if !isApplyingPreset && selectedPreset != "Custom" { selectedPreset = "Custom" }
            updateEQ()
        }
    }
    @Published var bassValue: Double = 0.0 {
        didSet {
            if !isApplyingPreset && selectedPreset != "Custom" { selectedPreset = "Custom" }
            updateEQ()
        }
    }
    @Published var trebleValue: Double = 0.0 {
        didSet {
            if !isApplyingPreset && selectedPreset != "Custom" { selectedPreset = "Custom" }
            updateEQ()
        }
    }
    
    // Knob Toggles
    @Published var isPreAmpEnabled: Bool = true { didSet { updateEQ() } }
    @Published var isBassEnabled: Bool = true { didSet { updateEQ() } }
    @Published var isTrebleEnabled: Bool = true { didSet { updateEQ() } }
    
    // Volume Control
    @Published var volume: Double = 0.75 { didSet { updateVolume() } }
    
    // Frequency Bands (7 Bands)
    @Published var bands: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] {
        didSet {
            // Only switch to Custom if the change wasn't triggered by a preset application
            // This is tricky, but for now, any manual slider change makes it Custom
            // We can check if the new values match the current preset, but that's expensive.
            // Simple approach: If user touches slider, it becomes Custom.
            // To avoid loop when applying preset, we can use a flag or check equality.
        }
    }
    
    let frequencies = ["60Hz", "150Hz", "400Hz", "1kHz", "2.4kHz", "15kHz", "20kHz"]
    let presets = ["Custom", "Flat", "Bass Boost", "Bass Reducer", "Treble Boost", "Treble Reducer", "Vocal Booster", "Electronic", "Hip-Hop", "Jazz", "Pop", "Rock"]
    
    private var isApplyingPreset = false
    
    init() {
        loadSettings()
    }
    
    // MARK: - Logic
    
    func selectPreset(_ preset: String) {
        selectedPreset = preset
    }
    
    private func applyPreset(_ name: String) {
        isApplyingPreset = true
        defer { isApplyingPreset = false }
        
        // Reset all knob values first
        preAmpValue = 0
        bassValue = 0
        trebleValue = 0
        
        switch name {
        case "Flat":
            setBands([0, 0, 0, 0, 0, 0, 0])
        case "Bass Boost":
            setBands([5, 4, 2, 0, 0, 0, 0])
            bassValue = 4
        case "Bass Reducer":
            setBands([-5, -4, -2, 0, 0, 0, 0])
            bassValue = -4
        case "Treble Boost":
            setBands([0, 0, 0, 0, 2, 4, 5])
            trebleValue = 4
        case "Treble Reducer":
            setBands([0, 0, 0, 0, -2, -4, -5])
            trebleValue = -4
        case "Vocal Booster":
            setBands([-2, -2, 2, 4, 2, -1, -2])
        case "Electronic":
            setBands([4, 3, 0, -2, 2, 3, 4])
            bassValue = 2
            trebleValue = 2
        case "Hip-Hop":
            setBands([5, 4, 1, -1, 1, 3, 4])
            bassValue = 5
        case "Jazz":
            setBands([3, 2, -1, 2, -1, 2, 3])
        case "Pop":
            setBands([-1, 1, 3, 4, 2, -1, -2])
        case "Rock":
            setBands([4, 3, -1, -2, 1, 3, 4])
        default:
            break
        }
        
        // Force UI update after preset is applied
        updateEQ()
    }
    
    private func setBands(_ values: [Double]) {
        self.bands = values
        updateEQ()
    }
    
    // MARK: - Audio Engine Integration
    
    private func updateEQ() {
        if isApplyingPreset { return }
        
        let settings = EqualizerSettings(
            isEnabled: isEnabled,
            preAmpValue: preAmpValue,
            bassValue: bassValue,
            trebleValue: trebleValue,
            bands: bands,
            selectedPreset: selectedPreset,
            isPreAmpEnabled: isPreAmpEnabled,
            isBassEnabled: isBassEnabled,
            isTrebleEnabled: isTrebleEnabled
        )
        
        MusicPlayerManager.shared.updateEQ(settings: settings)
        saveSettings()
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        let settings = EqualizerSettings(
            isEnabled: isEnabled,
            preAmpValue: preAmpValue,
            bassValue: bassValue,
            trebleValue: trebleValue,
            bands: bands,
            selectedPreset: selectedPreset,
            isPreAmpEnabled: isPreAmpEnabled,
            isBassEnabled: isBassEnabled,
            isTrebleEnabled: isTrebleEnabled
        )
        
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "EqualizerSettings")
        }
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "EqualizerSettings"),
           let settings = try? JSONDecoder().decode(EqualizerSettings.self, from: data) {
            
            self.isApplyingPreset = true // Prevent triggering updateEQ loop during init
            
            self.isEnabled = settings.isEnabled
            self.preAmpValue = settings.preAmpValue
            self.bassValue = settings.bassValue
            self.trebleValue = settings.trebleValue
            self.bands = settings.bands
            self.selectedPreset = settings.selectedPreset
            self.isPreAmpEnabled = settings.isPreAmpEnabled
            self.isBassEnabled = settings.isBassEnabled
            self.isTrebleEnabled = settings.isTrebleEnabled
            
            self.isApplyingPreset = false
            
            // Apply loaded settings to engine
            MusicPlayerManager.shared.updateEQ(settings: settings)
        }
    }
    
    // Helper to handle slider changes manually to set Custom preset
    func bandChanged(index: Int, value: Double) {
        bands[index] = value
        if selectedPreset != "Custom" {
            selectedPreset = "Custom"
        }
        updateEQ()
    }
    
    // Update system volume
    private func updateVolume() {
        MusicPlayerManager.shared.setVolume(volume)
    }
}
