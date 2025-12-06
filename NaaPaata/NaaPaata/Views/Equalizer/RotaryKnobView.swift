//
//  RotaryKnobView.swift
//  NaaPaata
//
//  Created by Mekala Vamsi Krishna on 11/29/25.
//

import SwiftUI

struct RotaryKnobView: View {
    let title: String
    @Binding var value: Double // -12.0 to 12.0
    @Binding var isEnabled: Bool
    var range: ClosedRange<Double> = -12...12
    
    @Environment(\.colorScheme) var colorScheme
    
    // Constants
    private let knobSize: CGFloat = 70 // Reduced from 80 to fit screen
    private let trackWidth: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 16) { // Reduced spacing
            // Title
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textSecondary)
            
            // Gauge
            ZStack {
                // Background Track (Semi-circle)
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(
                        Color.gray.opacity(0.2),
                        style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                    )
                    .frame(width: knobSize, height: knobSize)
                    .rotationEffect(.degrees(180))
                
                // Active Track
                Circle()
                    .trim(from: 0.0, to: CGFloat(mapValueToProgress(value)) * 0.5)
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                    )
                    .frame(width: knobSize, height: knobSize)
                    .rotationEffect(.degrees(180))
                    .opacity(isEnabled ? 1 : 0.3)
                
                // Bob (Thumb Indicator)
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14) // Slightly smaller bob
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .offset(x: knobSize / 2) // Move to edge
                    .rotationEffect(.degrees(180 + mapValueToProgress(value) * 180)) // Rotate to position
                    .opacity(isEnabled ? 1 : 0.3)
                
                // Value Text (Centered)
                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textSecondary)
                    
                    Text("dB")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .offset(y: 5) // Adjusted offset to prevent overlap
            }
            .frame(height: knobSize / 2 + 10, alignment: .top) // Add height for bob/shadow
            // Removed .clipped() to allow bob and shadow to overflow naturally
            .padding(.horizontal, 8) // Reduced padding
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard isEnabled else { return }
                        handleDrag(gesture)
                    }
            )
            
            // Percentage / Value Display Below
            Text("\(Int(mapValueToPercentage(value)))%")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                )
            
            // Toggle Switch
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(AppColors.primary)
                .scaleEffect(0.6) // Smaller switch
        }
        .padding(8) // Reduced outer padding from 12
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    colorScheme == .dark
                    ? Color(hex: "#252535")
                    : Color.white
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func handleDrag(_ gesture: DragGesture.Value) {
        // Simple horizontal drag for value change
        let sensitivity = 0.2
        let delta = gesture.translation.width * sensitivity
        
        // We need a state to hold the initial value on drag start to make this relative
        // For now, let's just increment based on drag. 
        // A better UX for a gauge is to tap/drag along the arc, but horizontal drag is easier to implement robustly without complex geometry math for the semi-circle.
        
        // Let's use the location to determine value if we want absolute positioning
        // Center of the gauge is at (width/2, height).
        // Let's stick to relative drag for smoother control.
        // Since we don't have previous value state here easily without `@State`, 
        // we can use the `value` binding directly but it might jump if we don't track start.
        
        // Let's try a simple approach: 
        // Map the x position of the drag relative to the view width.
        // But `gesture.location` is local to the view.
        
        let width = knobSize
        let x = min(max(0, gesture.location.x), width)
        let percentage = x / width
        let newValue = range.lowerBound + percentage * (range.upperBound - range.lowerBound)
        
        self.value = newValue
    }
    
    private func mapValueToProgress(_ value: Double) -> Double {
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private func mapValueToPercentage(_ value: Double) -> Double {
        // Map -12...12 to 0...100
        return ((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * 100
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RotaryKnobView(title: "Bass", value: .constant(5.0), isEnabled: .constant(true))
    }
}
