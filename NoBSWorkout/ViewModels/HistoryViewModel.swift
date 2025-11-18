//
//  HistoryViewModel.swift
//  NoBSWorkout
//
//  ViewModel for the workout history screen
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var workoutSessions: [WorkoutSession] = []
    @Published var selectedWorkoutType: String? = nil
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var groupedWorkouts: [(String, [WorkoutSession])] {
        let calendar = Calendar.current
        let now = Date()

        var grouped: [String: [WorkoutSession]] = [:]

        for workout in filteredWorkouts {
            guard let date = workout.date else { continue }

            let groupKey: String
            if calendar.isDateInToday(date) {
                groupKey = "Today"
            } else if calendar.isDateInYesterday(date) {
                groupKey = "Yesterday"
            } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                groupKey = "This Week"
            } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                groupKey = "This Month"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                groupKey = formatter.string(from: date)
            }

            grouped[groupKey, default: []].append(workout)
        }

        // Sort groups chronologically (most recent first)
        let sortOrder = ["Today", "Yesterday", "This Week", "This Month"]
        return grouped.sorted { group1, group2 in
            if let index1 = sortOrder.firstIndex(of: group1.key),
               let index2 = sortOrder.firstIndex(of: group2.key) {
                return index1 < index2
            } else if sortOrder.contains(group1.key) {
                return true
            } else if sortOrder.contains(group2.key) {
                return false
            } else {
                return group1.key > group2.key
            }
        }
    }

    var filteredWorkouts: [WorkoutSession] {
        if let selectedType = selectedWorkoutType {
            return workoutSessions.filter { $0.workoutType == selectedType }
        }
        return workoutSessions
    }

    var availableWorkoutTypes: [String] {
        let types = Set(workoutSessions.compactMap { $0.workoutType })
        return Array(types).sorted()
    }

    // MARK: - Initialization

    init(dataService: DataService = DataService()) {
        self.dataService = dataService
        loadWorkouts()
    }

    // MARK: - Data Loading

    func loadWorkouts() {
        isLoading = true
        workoutSessions = dataService.fetchWorkoutSessions()
        isLoading = false
    }

    // MARK: - Filtering

    func filterByWorkoutType(_ type: String?) {
        selectedWorkoutType = type
    }

    func clearFilter() {
        selectedWorkoutType = nil
    }

    // MARK: - Actions

    func deleteWorkout(_ workout: WorkoutSession) {
        dataService.deleteWorkoutSession(workout)
        loadWorkouts()
        HapticManager.shared.deleted()
    }

    // MARK: - Stats

    var totalWorkouts: Int {
        return workoutSessions.count
    }

    var totalVolume: Double {
        return workoutSessions.reduce(0) { $0 + $1.totalVolume }
    }

    var averageWorkoutsPerWeek: Double {
        guard let firstWorkout = workoutSessions.last,
              let firstDate = firstWorkout.date else {
            return 0
        }

        let now = Date()
        let weeks = now.timeIntervalSince(firstDate) / (7 * 24 * 60 * 60)

        guard weeks > 0 else { return 0 }

        return Double(workoutSessions.count) / weeks
    }

    var statsText: String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1

        let avgPerWeek = formatter.string(from: NSNumber(value: averageWorkoutsPerWeek)) ?? "0"
        return "\(totalWorkouts) total workouts • \(avgPerWeek) per week"
    }
}
