//
//  ExerciseDetailViewModel.swift
//  NoBSWorkout
//
//  ViewModel for detailed view of a single exercise with history and PRs
//

import Foundation
import Combine

class ExerciseDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var exercise: ExerciseTemplate
    @Published var recentSets: [SetEntry] = []
    @Published var personalRecords: [PersonalRecord] = []
    @Published var selectedTimeRange: TimeRange = .all
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let dataService: DataService
    private let prService: PRCalculatorService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Time Range Options

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case all = "All Time"

        var startDate: Date {
            let calendar = Calendar.current
            let now = Date()

            switch self {
            case .week:
                return calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now) ?? now
            case .threeMonths:
                return calendar.date(byAdding: .month, value: -3, to: now) ?? now
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now) ?? now
            case .all:
                return Date.distantPast
            }
        }
    }

    // MARK: - Computed Properties

    var filteredSets: [SetEntry] {
        let startDate = selectedTimeRange.startDate
        return recentSets.filter { set in
            guard let timestamp = set.timestamp else { return false }
            return timestamp >= startDate
        }
    }

    var maxWeight: Double {
        return filteredSets.map { $0.weight }.max() ?? 0
    }

    var totalVolume: Double {
        return filteredSets.reduce(0) { $0 + $1.volume }
    }

    var averageReps: Double {
        guard !filteredSets.isEmpty else { return 0 }
        let totalReps = filteredSets.reduce(0) { $0 + Int($1.reps) }
        return Double(totalReps) / Double(filteredSets.count)
    }

    var totalSets: Int {
        return filteredSets.count
    }

    /// Data for weight progression chart
    var weightProgressionData: [(date: Date, weight: Double)] {
        let grouped = Dictionary(grouping: filteredSets) { set -> Date in
            let timestamp = set.timestamp ?? Date()
            return Calendar.current.startOfDay(for: timestamp)
        }

        return grouped.map { date, sets in
            let maxWeight = sets.map { $0.weight }.max() ?? 0
            return (date: date, weight: maxWeight)
        }.sorted { $0.date < $1.date }
    }

    /// Data for volume progression chart
    var volumeProgressionData: [(date: Date, volume: Double)] {
        let grouped = Dictionary(grouping: filteredSets) { set -> Date in
            let timestamp = set.timestamp ?? Date()
            return Calendar.current.startOfDay(for: timestamp)
        }

        return grouped.map { date, sets in
            let totalVolume = sets.reduce(0) { $0 + $1.volume }
            return (date: date, volume: totalVolume)
        }.sorted { $0.date < $1.date }
    }

    /// Data for 1RM progression chart
    var oneRMProgressionData: [(date: Date, value: Double)] {
        return prService.getPRHistory(for: exercise, type: "estimated_1rm")
            .filter { $0.date >= selectedTimeRange.startDate }
    }

    // MARK: - Initialization

    init(exercise: ExerciseTemplate, dataService: DataService = DataService()) {
        self.exercise = exercise
        self.dataService = dataService
        self.prService = PRCalculatorService(dataService: dataService)

        loadData()
    }

    // MARK: - Data Loading

    func loadData() {
        isLoading = true

        // Fetch recent sets (last 100 for good history)
        recentSets = dataService.fetchRecentSets(for: exercise, limit: 100)
            .sorted { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }

        // Fetch PRs
        personalRecords = dataService.fetchPRs(for: exercise)
            .sorted { $0.dateAchieved ?? Date.distantPast > $1.dateAchieved ?? Date.distantPast }

        isLoading = false
    }

    // MARK: - Stats Formatting

    var maxWeightFormatted: String {
        return maxWeight.asWeight
    }

    var totalVolumeFormatted: String {
        return totalVolume.asVolume + " lbs"
    }

    var averageRepsFormatted: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: averageReps)) ?? "0"
    }

    var currentMaxWeightPR: String {
        guard let pr = exercise.maxWeightPR else {
            return "No PR"
        }
        return pr.value.asWeight
    }

    var currentEstimated1RM: String {
        guard let pr = exercise.estimated1RMPR else {
            return "No PR"
        }
        return pr.value.asWeight
    }

    // MARK: - PR Improvement

    var prImprovementRate: String? {
        guard let rate = prService.calculatePRImprovementRate(for: exercise) else {
            return nil
        }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1

        let rateStr = formatter.string(from: NSNumber(value: abs(rate))) ?? "0"

        if rate > 0 {
            return "+\(rateStr) lbs/week"
        } else if rate < 0 {
            return "-\(rateStr) lbs/week"
        } else {
            return "No change"
        }
    }

    // MARK: - Recent Sets Grouped by Workout

    var recentSetsGroupedByWorkout: [(workout: WorkoutSession, sets: [SetEntry])] {
        var grouped: [WorkoutSession: [SetEntry]] = [:]

        for set in filteredSets.reversed() { // Most recent first
            guard let workout = set.workoutSession else { continue }
            grouped[workout, default: []].append(set)
        }

        return grouped
            .map { (workout: $0.key, sets: $0.value.sorted { $0.setNumber < $1.setNumber }) }
            .sorted { ($0.workout.date ?? Date.distantPast) > ($1.workout.date ?? Date.distantPast) }
    }
}
