//
//  WorkoutSession+Extensions.swift
//  NoBSWorkout
//
//  Extensions and computed properties for WorkoutSession entity
//

import CoreData
import Foundation

extension WorkoutSession {

    /// Computed property to get all sets, sorted by timestamp
    var sortedSets: [SetEntry] {
        let setArray = sets?.allObjects as? [SetEntry] ?? []
        return setArray.sorted { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }
    }

    /// Get unique exercises in this workout
    var exercises: [ExerciseTemplate] {
        let setArray = sets?.allObjects as? [SetEntry] ?? []
        let exerciseSet = Set(setArray.compactMap { $0.exercise })
        return Array(exerciseSet).sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    /// Count of distinct exercises in this workout
    var exerciseCount: Int {
        return exercises.count
    }

    /// Total number of sets in this workout
    var setCount: Int {
        return sets?.count ?? 0
    }

    /// Calculate workout duration in seconds
    var duration: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }

    /// Formatted duration string (e.g., "1h 23m")
    var durationFormatted: String {
        guard let duration = duration else { return "In progress" }

        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    /// Total volume for this workout (sum of weight × reps for all sets)
    var totalVolume: Double {
        sortedSets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }

    /// Formatted volume string (e.g., "12,500 lbs")
    var volumeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalVolume)) ?? "0"
    }

    /// Count of PRs achieved in this workout
    var prCount: Int {
        sortedSets.filter { $0.isPR }.count
    }

    /// Check if workout is currently in progress
    var isInProgress: Bool {
        return endTime == nil
    }

    /// Formatted date string (e.g., "Today", "Yesterday", "Jan 15")
    var dateFormatted: String {
        guard let date = date else { return "Unknown" }

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day of week
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    /// Get sets grouped by exercise
    func setsByExercise() -> [(exercise: ExerciseTemplate, sets: [SetEntry])] {
        var grouped: [ExerciseTemplate: [SetEntry]] = [:]

        for set in sortedSets {
            guard let exercise = set.exercise else { continue }
            grouped[exercise, default: []].append(set)
        }

        return grouped
            .map { (exercise: $0.key, sets: $0.value.sorted { $0.setNumber < $1.setNumber }) }
            .sorted { ($0.exercise.name ?? "") < ($1.exercise.name ?? "") }
    }
}

// MARK: - Identifiable conformance
extension WorkoutSession: Identifiable {
    // id is already defined in Core Data model as UUID
}
