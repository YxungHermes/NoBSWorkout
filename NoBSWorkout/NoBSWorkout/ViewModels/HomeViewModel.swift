//
//  HomeViewModel.swift
//  NoBSWorkout
//
//  ViewModel for the home screen
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var mostRecentWorkout: WorkoutSession?
    @Published var suggestedWorkoutType: WorkoutType = .push
    @Published var isLoading: Bool = false
    @Published var workoutsThisWeek: Int = 0

    // MARK: - Dependencies

    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(dataService: DataService = DataService()) {
        self.dataService = dataService
        loadData()
    }

    // MARK: - Data Loading

    func loadData() {
        isLoading = true

        // Fetch most recent workout
        mostRecentWorkout = dataService.fetchMostRecentWorkout()

        // Calculate suggested workout based on recent history
        suggestedWorkoutType = calculateSuggestedWorkout()

        // Calculate workouts this week
        calculateWorkoutsThisWeek()

        isLoading = false
    }

    /// Calculate suggested workout type based on recent workout history
    /// Uses a simple rotation: Push → Pull → Legs
    private func calculateSuggestedWorkout() -> WorkoutType {
        guard let lastWorkout = mostRecentWorkout else {
            return .push // Default to push if no history
        }

        let lastType = lastWorkout.workoutType ?? ""

        // Suggest next in rotation
        switch lastType {
        case WorkoutType.push.rawValue:
            return .pull
        case WorkoutType.pull.rawValue:
            return .legs
        case WorkoutType.legs.rawValue:
            return .push
        case WorkoutType.upper.rawValue:
            return .lower
        case WorkoutType.lower.rawValue:
            return .upper
        case WorkoutType.fullBody.rawValue:
            return .fullBody
        default:
            return .push
        }
    }

    /// Calculate number of workouts completed this week
    private func calculateWorkoutsThisWeek() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            workoutsThisWeek = 0
            return
        }

        let sessions = dataService.fetchWorkoutSessions()
        workoutsThisWeek = sessions.filter { session in
            guard let date = session.date else { return false }
            return date >= startOfWeek && date <= now
        }.count
    }

    // MARK: - Actions

    /// Start a new workout with a specific type
    func startWorkout(type: WorkoutType) -> WorkoutSession {
        HapticManager.shared.workoutStarted()
        return dataService.createWorkoutSession(workoutType: type.rawValue)
    }

    // MARK: - Computed Properties

    var hasWorkoutHistory: Bool {
        return mostRecentWorkout != nil
    }

    var motivationalMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good morning! Time to crush it 💪"
        case 12..<17:
            return "Afternoon gains await!"
        case 17..<21:
            return "Evening session? Let's go!"
        default:
            return "Late night grind! Respect."
        }
    }

    var workoutsThisWeekText: String {
        if workoutsThisWeek == 0 {
            return "No workouts this week yet"
        } else if workoutsThisWeek == 1 {
            return "1 workout this week"
        } else {
            return "\(workoutsThisWeek) workouts this week"
        }
    }
}
