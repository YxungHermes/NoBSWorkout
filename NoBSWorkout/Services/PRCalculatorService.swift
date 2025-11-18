//
//  PRCalculatorService.swift
//  NoBSWorkout
//
//  Service for calculating and checking personal records.
//  Uses the Epley formula for estimating 1RM: weight × (1 + reps/30)
//

import Foundation

/// Result of a PR check
struct PRResult {
    let isNewPR: Bool
    let prTypes: [String] // e.g., ["max_weight", "estimated_1rm"]
    let previousMaxWeight: Double?
    let previousBest1RM: Double?
}

/// Service that handles all PR-related calculations
class PRCalculatorService {

    // MARK: - Properties

    private let dataService: DataService

    // MARK: - Initialization

    init(dataService: DataService) {
        self.dataService = dataService
    }

    // MARK: - PR Calculation

    /// Calculate estimated 1RM using the Epley formula
    /// Formula: weight × (1 + reps/30)
    /// This is one of the most common formulas and works well for reps between 1-10
    ///
    /// - Parameters:
    ///   - weight: Weight lifted (in lbs or kg)
    ///   - reps: Number of reps performed
    /// - Returns: Estimated 1 rep max
    func calculateEstimated1RM(weight: Double, reps: Int) -> Double {
        // For 1 rep, the estimated 1RM is just the weight itself
        if reps == 1 {
            return weight
        }

        // Epley formula
        return weight * (1.0 + Double(reps) / 30.0)
    }

    /// Alternative formulas (for future use)
    /// Uncomment to use different formulas

    /*
    /// Brzycki formula: weight × (36 / (37 - reps))
    func calculateEstimated1RM_Brzycki(weight: Double, reps: Int) -> Double {
        if reps == 1 { return weight }
        return weight * (36.0 / (37.0 - Double(reps)))
    }

    /// Lombardi formula: weight × reps^0.1
    func calculateEstimated1RM_Lombardi(weight: Double, reps: Int) -> Double {
        if reps == 1 { return weight }
        return weight * pow(Double(reps), 0.1)
    }
    */

    // MARK: - PR Checking

    /// Check if a new set represents a personal record
    /// - Parameters:
    ///   - exercise: The exercise being performed
    ///   - weight: Weight lifted
    ///   - reps: Number of reps
    /// - Returns: PRResult indicating if it's a PR and which types
    func checkForPR(exercise: ExerciseTemplate, weight: Double, reps: Int) -> PRResult {
        var prTypes: [String] = []

        // Get existing PRs
        let maxWeightPR = dataService.fetchPR(for: exercise, type: "max_weight")
        let estimated1RMPR = dataService.fetchPR(for: exercise, type: "estimated_1rm")

        let previousMaxWeight = maxWeightPR?.value
        let previousBest1RM = estimated1RMPR?.value

        // Check for max weight PR
        // A max weight PR is when the weight is higher than any previous weight,
        // regardless of rep count
        if let previousMax = previousMaxWeight {
            if weight > previousMax {
                prTypes.append("max_weight")
            }
        } else {
            // First time doing this exercise
            prTypes.append("max_weight")
        }

        // Check for estimated 1RM PR
        let current1RM = calculateEstimated1RM(weight: weight, reps: reps)
        if let previousBest = previousBest1RM {
            if current1RM > previousBest {
                prTypes.append("estimated_1rm")
            }
        } else {
            // First time doing this exercise
            prTypes.append("estimated_1rm")
        }

        return PRResult(
            isNewPR: !prTypes.isEmpty,
            prTypes: prTypes,
            previousMaxWeight: previousMaxWeight,
            previousBest1RM: previousBest1RM
        )
    }

    /// Update PR records after a new PR has been achieved
    /// - Parameters:
    ///   - setEntry: The set that achieved the PR
    ///   - prTypes: Types of PRs achieved (from PRResult)
    func updatePRs(for setEntry: SetEntry, prTypes: [String]) {
        guard let exercise = setEntry.exercise else { return }

        for prType in prTypes {
            switch prType {
            case "max_weight":
                dataService.createPR(
                    exercise: exercise,
                    type: "max_weight",
                    value: setEntry.weight,
                    reps: Int(setEntry.reps),
                    setEntryId: setEntry.id
                )

            case "estimated_1rm":
                let estimated1RM = calculateEstimated1RM(
                    weight: setEntry.weight,
                    reps: Int(setEntry.reps)
                )
                dataService.createPR(
                    exercise: exercise,
                    type: "estimated_1rm",
                    value: estimated1RM,
                    reps: Int(setEntry.reps),
                    setEntryId: setEntry.id
                )

            default:
                break
            }
        }
    }

    // MARK: - PR Formatting

    /// Get a human-readable description of a PR
    /// - Parameters:
    ///   - prResult: The PR result
    ///   - weight: Weight lifted
    ///   - reps: Reps performed
    /// - Returns: Formatted string (e.g., "New max weight PR! Previous: 135 lbs")
    func formatPRDescription(prResult: PRResult, weight: Double, reps: Int) -> String {
        guard prResult.isNewPR else { return "" }

        var descriptions: [String] = []

        if prResult.prTypes.contains("max_weight") {
            if let previous = prResult.previousMaxWeight {
                let improvement = weight - previous
                descriptions.append("Max weight PR! +\(String(format: "%.1f", improvement)) lbs")
            } else {
                descriptions.append("First max weight PR!")
            }
        }

        if prResult.prTypes.contains("estimated_1rm") {
            let current1RM = calculateEstimated1RM(weight: weight, reps: reps)
            if let previous = prResult.previousBest1RM {
                let improvement = current1RM - previous
                descriptions.append("Est. 1RM PR! +\(String(format: "%.1f", improvement)) lbs")
            } else {
                descriptions.append("First 1RM PR!")
            }
        }

        return descriptions.joined(separator: "\n")
    }

    // MARK: - Analytics

    /// Calculate PR improvement rate for an exercise
    /// Returns the average improvement per week over the last N weeks
    func calculatePRImprovementRate(
        for exercise: ExerciseTemplate,
        weeks: Int = 12
    ) -> Double? {
        let prs = dataService.fetchPRs(for: exercise)
            .filter { $0.recordType == "estimated_1rm" }
            .sorted { $0.dateAchieved ?? Date.distantPast < $1.dateAchieved ?? Date.distantPast }

        guard prs.count >= 2,
              let firstPR = prs.first,
              let lastPR = prs.last,
              let firstDate = firstPR.dateAchieved,
              let lastDate = lastPR.dateAchieved else {
            return nil
        }

        let valueImprovement = lastPR.value - firstPR.value
        let timeInterval = lastDate.timeIntervalSince(firstDate)
        let weeksElapsed = timeInterval / (7 * 24 * 60 * 60)

        guard weeksElapsed > 0 else { return nil }

        return valueImprovement / weeksElapsed
    }

    /// Get all PRs grouped by date for charting
    func getPRHistory(for exercise: ExerciseTemplate, type: String = "estimated_1rm") -> [(date: Date, value: Double)] {
        let prs = dataService.fetchPRs(for: exercise)
            .filter { $0.recordType == type }
            .sorted { $0.dateAchieved ?? Date.distantPast < $1.dateAchieved ?? Date.distantPast }

        return prs.compactMap { pr in
            guard let date = pr.dateAchieved else { return nil }
            return (date: date, value: pr.value)
        }
    }
}
