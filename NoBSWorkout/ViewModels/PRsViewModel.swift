//
//  PRsViewModel.swift
//  NoBSWorkout
//
//  ViewModel for the Personal Records screen
//

import Foundation
import Combine

class PRsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var exercisesWithPRs: [ExerciseTemplate] = []
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .name
    @Published var isLoading: Bool = false

    // MARK: - Dependencies

    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Sort Options

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case recentPR = "Recent PR"
        case maxWeight = "Max Weight"
    }

    // MARK: - Computed Properties

    var filteredAndSortedExercises: [ExerciseTemplate] {
        var exercises = exercisesWithPRs

        // Filter by search text
        if !searchText.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }

        // Sort
        switch sortOption {
        case .name:
            exercises.sort { ($0.name ?? "") < ($1.name ?? "") }

        case .recentPR:
            exercises.sort { exercise1, exercise2 in
                let date1 = exercise1.personalRecords?.allObjects
                    .compactMap { ($0 as? PersonalRecord)?.dateAchieved }
                    .max() ?? Date.distantPast
                let date2 = exercise2.personalRecords?.allObjects
                    .compactMap { ($0 as? PersonalRecord)?.dateAchieved }
                    .max() ?? Date.distantPast
                return date1 > date2
            }

        case .maxWeight:
            exercises.sort { exercise1, exercise2 in
                let weight1 = exercise1.maxWeightPR?.value ?? 0
                let weight2 = exercise2.maxWeightPR?.value ?? 0
                return weight1 > weight2
            }
        }

        return exercises
    }

    // MARK: - Initialization

    init(dataService: DataService = DataService()) {
        self.dataService = dataService
        loadPRs()
    }

    // MARK: - Data Loading

    func loadPRs() {
        isLoading = true
        exercisesWithPRs = dataService.fetchExercisesWithPRs()
        isLoading = false
    }

    // MARK: - Helper Methods

    func getPRSummary(for exercise: ExerciseTemplate) -> String {
        var parts: [String] = []

        if let maxWeight = exercise.maxWeightPR?.value {
            parts.append("Max: \(maxWeight.asWeight)")
        }

        if let est1RM = exercise.estimated1RMPR?.value {
            parts.append("Est 1RM: \(est1RM.asWeight)")
        }

        return parts.joined(separator: " • ")
    }

    func getLastPRDate(for exercise: ExerciseTemplate) -> String {
        let records = exercise.personalRecords?.allObjects as? [PersonalRecord] ?? []
        guard let mostRecent = records.max(by: { $0.dateAchieved ?? Date.distantPast < $1.dateAchieved ?? Date.distantPast }),
              let date = mostRecent.dateAchieved else {
            return "Unknown"
        }

        return date.smartFormatted
    }

    // MARK: - Stats

    var totalPRs: Int {
        return exercisesWithPRs.reduce(0) { total, exercise in
            total + (exercise.personalRecords?.count ?? 0)
        }
    }

    var recentPRs: [PersonalRecord] {
        let allPRs = exercisesWithPRs.flatMap { exercise -> [PersonalRecord] in
            exercise.personalRecords?.allObjects as? [PersonalRecord] ?? []
        }

        return allPRs
            .sorted { $0.dateAchieved ?? Date.distantPast > $1.dateAchieved ?? Date.distantPast }
            .prefix(5)
            .map { $0 }
    }
}
