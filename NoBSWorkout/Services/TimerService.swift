//
//  TimerService.swift
//  NoBSWorkout
//
//  Service for managing the rest timer with background support and notifications.
//

import Foundation
import Combine
import UserNotifications

/// Service that manages rest timer functionality
class TimerService: ObservableObject {

    // MARK: - Published Properties

    /// Current time remaining in seconds
    @Published var timeRemaining: Int = 0

    /// Whether the timer is currently running
    @Published var isRunning: Bool = false

    /// The initial duration set for the timer
    @Published var initialDuration: Int = 0

    // MARK: - Private Properties

    private var timer: AnyCancellable?
    private var endDate: Date?

    // MARK: - Preset Durations

    static let presetDurations = [30, 60, 90, 120, 180] // in seconds

    // MARK: - Initialization

    init() {
        // Request notification permissions on init
        requestNotificationPermissions()
    }

    // MARK: - Timer Control

    /// Start the timer with a given duration
    /// - Parameter duration: Duration in seconds
    func startTimer(duration: Int) {
        initialDuration = duration
        timeRemaining = duration
        endDate = Date().addingTimeInterval(TimeInterval(duration))
        isRunning = true

        // Schedule notification
        scheduleNotification(for: duration)

        // Start the timer
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    /// Pause the timer
    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil

        // Cancel notification
        cancelNotification()
    }

    /// Resume the timer
    func resumeTimer() {
        guard !isRunning else { return }

        isRunning = true
        endDate = Date().addingTimeInterval(TimeInterval(timeRemaining))

        // Reschedule notification for remaining time
        scheduleNotification(for: timeRemaining)

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    /// Reset the timer to initial duration
    func resetTimer() {
        timer?.cancel()
        timer = nil
        timeRemaining = initialDuration
        isRunning = false
        endDate = nil

        // Cancel notification
        cancelNotification()
    }

    /// Stop the timer completely
    func stopTimer() {
        timer?.cancel()
        timer = nil
        timeRemaining = 0
        initialDuration = 0
        isRunning = false
        endDate = nil

        // Cancel notification
        cancelNotification()
    }

    /// Add time to the running timer
    func addTime(seconds: Int) {
        timeRemaining += seconds
        initialDuration += seconds

        if isRunning {
            endDate = endDate?.addingTimeInterval(TimeInterval(seconds))

            // Cancel and reschedule notification with new time
            cancelNotification()
            scheduleNotification(for: timeRemaining)
        }
    }

    // MARK: - Private Methods

    /// Called every second to update the timer
    private func tick() {
        guard let endDate = endDate else {
            pauseTimer()
            return
        }

        let now = Date()
        let remaining = Int(endDate.timeIntervalSince(now))

        if remaining <= 0 {
            // Timer finished
            timeRemaining = 0
            isRunning = false
            timer?.cancel()
            timer = nil
            self.endDate = nil

            // Play haptic feedback
            playTimerCompletionHaptic()
        } else {
            timeRemaining = remaining
        }
    }

    // MARK: - Notifications

    /// Request permission to send notifications
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            if granted {
                print("Notification permissions granted")
            }
        }
    }

    /// Schedule a local notification for when the timer completes
    private func scheduleNotification(for duration: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Rest Timer Complete"
        content.body = "Time to hit the next set!"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: false)
        let request = UNNotificationRequest(
            identifier: "restTimerComplete",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    /// Cancel any scheduled notifications
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["restTimerComplete"])
    }

    /// Clear notification badges
    func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    // MARK: - Haptic Feedback

    /// Play haptic feedback when timer completes
    private func playTimerCompletionHaptic() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    // MARK: - Formatting

    /// Format time remaining as MM:SS
    var timeRemainingFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Calculate progress (0.0 to 1.0)
    var progress: Double {
        guard initialDuration > 0 else { return 0.0 }
        return Double(initialDuration - timeRemaining) / Double(initialDuration)
    }
}
