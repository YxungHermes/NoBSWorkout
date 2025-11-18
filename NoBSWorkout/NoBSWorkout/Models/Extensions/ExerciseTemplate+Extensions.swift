//
//  ExerciseTemplate+Extensions.swift
//  NoBSWorkout
//
//  Extensions and computed properties for ExerciseTemplate entity
//

import CoreData
import Foundation

extension ExerciseTemplate {

    /// Computed property to get all sets for this exercise, sorted by timestamp
    var sortedSets: [SetEntry] {
        let setArray = sets?.allObjects as? [SetEntry] ?? []
        return setArray.sorted { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }
    }

    /// Get the most recent N sets for this exercise
    func recentSets(limit: Int = 10) -> [SetEntry] {
        return Array(sortedSets.suffix(limit))
    }

    /// Get the current max weight PR for this exercise (if any)
    var maxWeightPR: PersonalRecord? {
        let records = personalRecords?.allObjects as? [PersonalRecord] ?? []
        return records
            .filter { $0.recordType == "max_weight" }
            .max { $0.value < $1.value }
    }

    /// Get the current estimated 1RM PR for this exercise (if any)
    var estimated1RMPR: PersonalRecord? {
        let records = personalRecords?.allObjects as? [PersonalRecord] ?? []
        return records
            .filter { $0.recordType == "estimated_1rm" }
            .max { $0.value < $1.value }
    }

    /// Check if this exercise has any PRs
    var hasPRs: Bool {
        let records = personalRecords?.allObjects as? [PersonalRecord] ?? []
        return !records.isEmpty
    }

    /// Get display name with muscle group
    var displayName: String {
        if let muscleGroup = muscleGroup, !muscleGroup.isEmpty {
            return "\(name ?? "Unknown") (\(muscleGroup))"
        }
        return name ?? "Unknown"
    }

    /// Calculate total volume for this exercise across all time
    var totalVolume: Double {
        sortedSets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }

    /// Get the date of the last time this exercise was performed
    var lastPerformedDate: Date? {
        return sortedSets.last?.timestamp
    }
}

// MARK: - Identifiable conformance
extension ExerciseTemplate: Identifiable {
    // id is already defined in Core Data model as UUID
}
