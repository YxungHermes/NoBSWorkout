//
//  WorkoutLoggingViewModel.swift
//  NoBSWorkout
//
//  ViewModel for the workout logging screen.
//  Handles set logging, exercise selection, and PR detection.
//

import Foundation
import Combine

class WorkoutLoggingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentWorkoutSession: WorkoutSession
    @Published var currentExercise: ExerciseTemplate?
    @Published var exercises: [ExerciseTemplate] = []
    @Published var loggedSets: [SetEntry] = []

    // Current set input
    @Published var weightInput: String = ""
    @Published var repsInput: String = ""
    @Published var rpeInput: Double = 7.0
    @Published var includeRPE: Bool = false

    // UI state
    @Published var showingExerciseSelector: Bool = false
    @Published var showingPRCelebration: Bool = false
    @Published var prMessage: String = ""
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let dataService: DataService
    private let timerService: TimerService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var setsForCurrentExercise: [SetEntry] {
        guard let exercise = currentExercise else { return [] }
        return loggedSets.filter { $0.exercise?.id == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
    }

    var setNumber: Int {
        return setsForCurrentExercise.count + 1
    }

    var canLogSet: Bool {
        guard currentExercise != nil,
              let weight = Double(weightInput),
              let reps = Int(repsInput),
              weight > 0,
              reps > 0 else {
            return false
        }
        return true
    }

    var lastSet: SetEntry? {
        return setsForCurrentExercise.last
    }

    var elapsedTime: String {
        guard let startTime = currentWorkoutSession.startTime else {
            return "0:00"
        }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var filteredExercises: [ExerciseTemplate] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    // MARK: - Initialization

    init(
        workoutSession: WorkoutSession,
        dataService: DataService = DataService(),
        timerService: TimerService = TimerService()
    ) {
        self.currentWorkoutSession = workoutSession
        self.dataService = dataService
        self.timerService = timerService

        loadExercises()
        loadLoggedSets()
        setupBindings()
    }

    // MARK: - Data Loading

    private func loadExercises() {
        isLoading = true
        exercises = dataService.fetchExercises()
        isLoading = false
    }

    private func loadLoggedSets() {
        let sets = currentWorkoutSession.sets?.allObjects as? [SetEntry] ?? []
        loggedSets = sets.sorted { $0.timestamp ?? Date.distantPast < $1.timestamp ?? Date.distantPast }
    }

    private func setupBindings() {
        // Auto-select the most recent exercise if available
        if loggedSets.isEmpty == false {
            currentExercise = loggedSets.last?.exercise
        }
    }

    // MARK: - Exercise Selection

    func selectExercise(_ exercise: ExerciseTemplate) {
        currentExercise = exercise
        showingExerciseSelector = false

        // Auto-populate inputs from last set of this exercise (if any)
        if let lastSetForExercise = dataService.fetchLastSet(for: exercise) {
            weightInput = String(format: "%.1f", lastSetForExercise.weight)
            repsInput = String(lastSetForExercise.reps)
        } else {
            // Clear inputs for new exercise
            weightInput = ""
            repsInput = ""
        }

        HapticManager.shared.selection()
    }

    func createCustomExercise(name: String, muscleGroup: String, category: String) {
        let exercise = dataService.createExercise(
            name: name,
            muscleGroup: muscleGroup,
            category: category
        )
        loadExercises()
        selectExercise(exercise)
    }

    // MARK: - Set Logging

    func logSet() {
        guard canLogSet,
              let exercise = currentExercise,
              let weight = Double(weightInput),
              let reps = Int(repsInput) else {
            return
        }

        let rpe = includeRPE ? rpeInput : nil

        // Log the set
        let result = dataService.logSet(
            session: currentWorkoutSession,
            exercise: exercise,
            weight: weight,
            reps: reps,
            rpe: rpe
        )

        // Add to logged sets
        loggedSets.append(result.set)

        // Check for PR
        if result.isNewPR {
            showPRCelebration(for: result.set)
        } else {
            HapticManager.shared.setLogged()
        }

        // Keep the same inputs for next set (user can adjust if needed)
        // This makes logging faster - just tap "Log Set" for same weight/reps

        // Optionally clear inputs (uncomment if you prefer):
        // clearInputs()
    }

    func copyLastSet() {
        guard let lastSet = lastSet else { return }

        weightInput = String(format: "%.1f", lastSet.weight)
        repsInput = String(lastSet.reps)
        if let rpe = lastSet.rpe {
            rpeInput = rpe
            includeRPE = true
        }

        HapticManager.shared.light()
    }

    func deleteSet(_ set: SetEntry) {
        dataService.deleteSet(set)
        loggedSets.removeAll { $0.id == set.id }
        HapticManager.shared.deleted()
    }

    func clearInputs() {
        weightInput = ""
        repsInput = ""
        rpeInput = 7.0
    }

    // MARK: - PR Celebration

    private func showPRCelebration(for set: SetEntry) {
        guard let exercise = set.exercise else { return }

        HapticManager.shared.prAchieved()

        let prService = PRCalculatorService(dataService: dataService)
        let prResult = prService.checkForPR(
            exercise: exercise,
            weight: set.weight,
            reps: Int(set.reps)
        )

        prMessage = prService.formatPRDescription(
            prResult: prResult,
            weight: set.weight,
            reps: Int(set.reps)
        )

        showingPRCelebration = true

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingPRCelebration = false
        }
    }

    // MARK: - Timer Integration

    func startRestTimer(duration: Int) {
        timerService.startTimer(duration: duration)
        HapticManager.shared.medium()
    }

    // MARK: - Workout Completion

    func finishWorkout() {
        dataService.finishWorkoutSession(currentWorkoutSession)
        HapticManager.shared.workoutFinished()
    }

    var canFinishWorkout: Bool {
        return !loggedSets.isEmpty
    }

    var workoutSummary: String {
        let exerciseCount = Set(loggedSets.compactMap { $0.exercise?.id }).count
        let setCount = loggedSets.count
        let prCount = loggedSets.filter { $0.isPR }.count

        var summary = "\(exerciseCount) exercises, \(setCount) sets"
        if prCount > 0 {
            summary += ", \(prCount) PR\(prCount == 1 ? "" : "s")"
        }
        return summary
    }

    // MARK: - Suggested Exercises

    /// Get suggested exercises based on workout type and recent history
    var suggestedExercises: [ExerciseTemplate] {
        let workoutType = currentWorkoutSession.workoutType ?? ""

        // Filter exercises by category matching workout type
        let filtered = exercises.filter { exercise in
            exercise.category == workoutType
        }

        // Sort by last performed date (most recent last)
        let sorted = filtered.sorted { exercise1, exercise2 in
            let date1 = exercise1.lastPerformedDate ?? Date.distantPast
            let date2 = exercise2.lastPerformedDate ?? Date.distantPast
            return date1 < date2
        }

        // Return first 10
        return Array(sorted.prefix(10))
    }

    /// Get favorite exercises for quick access
    var favoriteExercises: [ExerciseTemplate] {
        return exercises
            .filter { $0.isFavorite }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
