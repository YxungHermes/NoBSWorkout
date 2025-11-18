//
//  Double+Extensions.swift
//  NoBSWorkout
//
//  Extensions for formatting weights and numbers
//

import Foundation

extension Double {

    /// Format as weight (e.g., "135 lbs", "135.5 lbs")
    var asWeight: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
        return "\(formatter.string(from: NSNumber(value: self)) ?? "0") lbs"
    }

    /// Format as weight without unit (e.g., "135", "135.5")
    var asWeightValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    /// Format as volume (e.g., "12,500", "12,500.5")
    var asVolume: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    /// Format as RPE (e.g., "8.0", "9.5")
    var asRPE: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? "0.0"
    }

    /// Round to specified number of decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Int {

    /// Format as reps (e.g., "10 reps", "1 rep")
    var asReps: String {
        return self == 1 ? "1 rep" : "\(self) reps"
    }

    /// Format as ordinal (e.g., "1st", "2nd", "3rd", "4th")
    var asOrdinal: String {
        let suffix: String
        switch self % 10 {
        case 1 where self % 100 != 11:
            suffix = "st"
        case 2 where self % 100 != 12:
            suffix = "nd"
        case 3 where self % 100 != 13:
            suffix = "rd"
        default:
            suffix = "th"
        }
        return "\(self)\(suffix)"
    }
}
