//
//  Constants.swift
//  NoBSWorkout
//
//  App-wide constants for colors, sizes, and configuration
//

import SwiftUI

// MARK: - Workout Types

enum WorkoutType: String, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case upper = "Upper"
    case lower = "Lower"
    case fullBody = "Full Body"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .push: return "figure.strengthtraining.traditional"
        case .pull: return "figure.climbing"
        case .legs: return "figure.run"
        case .upper: return "figure.arms.open"
        case .lower: return "figure.walk"
        case .fullBody: return "figure.mixed.cardio"
        case .custom: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .push: return .red
        case .pull: return .blue
        case .legs: return .green
        case .upper: return .orange
        case .lower: return .purple
        case .fullBody: return .pink
        case .custom: return .gray
        }
    }
}

// MARK: - Muscle Groups

enum MuscleGroup: String, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case quads = "Quads"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case abs = "Abs"
    case forearms = "Forearms"
}

// MARK: - UI Constants

struct UIConstants {

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20

    // MARK: - Button Sizes

    static let buttonHeightSmall: CGFloat = 44
    static let buttonHeightMedium: CGFloat = 50
    static let buttonHeightLarge: CGFloat = 60

    // MARK: - Icon Sizes

    static let iconSizeSmall: CGFloat = 16
    static let iconSizeMedium: CGFloat = 24
    static let iconSizeLarge: CGFloat = 32
    static let iconSizeXL: CGFloat = 48

    // MARK: - Font Sizes

    static let fontSizeCaption: CGFloat = 12
    static let fontSizeBody: CGFloat = 16
    static let fontSizeTitle: CGFloat = 20
    static let fontSizeHeading: CGFloat = 28
    static let fontSizeLarge: CGFloat = 34

    // MARK: - Animation Durations

    static let animationFast: Double = 0.2
    static let animationMedium: Double = 0.3
    static let animationSlow: Double = 0.5
}

// MARK: - App Colors

struct AppColors {
    static let primary = Color.blue
    static let secondary = Color.gray
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let prGold = Color.yellow

    // Background colors
    static let backgroundPrimary = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)

    // Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
}

// MARK: - Timer Presets

struct TimerPresets {
    static let durations = [30, 60, 90, 120, 180] // in seconds

    static func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(remainingSeconds)s"
            }
        }
    }
}

// MARK: - PR Types

enum PRType: String {
    case maxWeight = "max_weight"
    case estimated1RM = "estimated_1rm"
    case maxReps = "max_reps"
    case maxVolume = "max_volume"

    var displayName: String {
        switch self {
        case .maxWeight: return "Max Weight"
        case .estimated1RM: return "Estimated 1RM"
        case .maxReps: return "Max Reps"
        case .maxVolume: return "Max Volume"
        }
    }
}

// MARK: - App Info

struct AppInfo {
    static let appName = "NoBSWorkout"
    static let version = "1.0.0"
    static let buildNumber = "1"
}
