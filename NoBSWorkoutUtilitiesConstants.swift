//
//  Constants.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import Foundation
import SwiftUI

enum WorkoutTypes {
    static let all = ["Push", "Pull", "Legs", "Upper", "Lower", "Full Body"]
}

enum RestTimerPresets {
    static let short = 60    // 1 minute
    static let medium = 90   // 1.5 minutes
    static let long = 120    // 2 minutes
    static let extended = 180 // 3 minutes
}

extension Color {
    static let appBlue = Color.blue
    static let appPurple = Color.purple
    static let appOrange = Color.orange
}

enum HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}
