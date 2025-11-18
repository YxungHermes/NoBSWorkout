//
//  SetEntry+Extensions.swift
//  NoBSWorkout
//
//  Extensions and computed properties for SetEntry entity
//

import CoreData
import Foundation

extension SetEntry {

    /// Calculate estimated 1RM using Epley formula
    /// Formula: weight × (1 + reps/30)
    var estimated1RM: Double {
        return weight * (1.0 + Double(reps) / 30.0)
    }

    /// Formatted weight string (e.g., "135 lbs")
    var weightFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let weightStr = formatter.string(from: NSNumber(value: weight)) ?? "0"
        return "\(weightStr) lbs"
    }

    /// Formatted reps string (e.g., "10 reps")
    var repsFormatted: String {
        return reps == 1 ? "1 rep" : "\(reps) reps"
    }

    /// Complete set description (e.g., "135 lbs × 10 reps")
    var setDescription: String {
        return "\(weightFormatted) × \(reps)"
    }

    /// Formatted RPE string (e.g., "RPE 8")
    var rpeFormatted: String? {
        guard let rpe = rpe else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return "RPE \(formatter.string(from: NSNumber(value: rpe)) ?? "0")"
    }

    /// Calculate the volume for this set (weight × reps)
    var volume: Double {
        return weight * Double(reps)
    }

    /// Formatted volume string
    var volumeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: volume)) ?? "0"
    }

    /// Get the time elapsed since this set was performed
    var timeAgo: String {
        guard let timestamp = timestamp else { return "Unknown" }

        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: now)
    }

    /// Check if this set was performed today
    var isFromToday: Bool {
        guard let timestamp = timestamp else { return false }
        return Calendar.current.isDateInToday(timestamp)
    }
}

// MARK: - Identifiable conformance
extension SetEntry: Identifiable {
    // id is already defined in Core Data model as UUID
}

// MARK: - Comparable conformance (for sorting)
extension SetEntry: Comparable {
    public static func < (lhs: SetEntry, rhs: SetEntry) -> Bool {
        let lhsTime = lhs.timestamp ?? Date.distantPast
        let rhsTime = rhs.timestamp ?? Date.distantPast
        return lhsTime < rhsTime
    }
}
