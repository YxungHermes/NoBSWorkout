//
//  HapticManager.swift
//  NoBSWorkout
//
//  Centralized manager for haptic feedback throughout the app
//

import UIKit

/// Manager for providing consistent haptic feedback across the app
class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Custom Feedback Patterns

    /// Haptic for logging a set
    func setLogged() {
        medium()
    }

    /// Haptic for achieving a PR
    func prAchieved() {
        success()
        // Double tap for extra celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavy()
        }
    }

    /// Haptic for timer completion
    func timerComplete() {
        success()
    }

    /// Haptic for starting a workout
    func workoutStarted() {
        heavy()
    }

    /// Haptic for finishing a workout
    func workoutFinished() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.success()
        }
    }

    /// Haptic for deleting an item
    func deleted() {
        warning()
    }

    /// Haptic for button tap
    func buttonTap() {
        light()
    }
}
