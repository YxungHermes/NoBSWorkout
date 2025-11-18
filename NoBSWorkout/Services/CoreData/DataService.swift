//
//  DataService.swift
//  NoBSWorkout
//
//  Centralized service for all Core Data operations.
//  Provides a clean API for ViewModels to interact with the database.
//

import CoreData
import Combine
import Foundation

/// Service class that handles all Core Data operations
/// This provides a layer of abstraction between ViewModels and Core Data,
/// making it easier to test and modify persistence logic.
class DataService: ObservableObject {

    // MARK: - Properties

    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // MARK: - Initialization

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // MARK: - Exercise Operations

    /// Fetch all exercises, optionally filtered by search term and/or category
    func fetchExercises(
        searchTerm: String? = nil,
        category: String? = nil,
        favoritesOnly: Bool = false
    ) -> [ExerciseTemplate] {
        let request: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
        var predicates: [NSPredicate] = []

        // Filter by search term (searches in name)
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchTerm))
        }

        // Filter by category
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }

        // Filter favorites
        if favoritesOnly {
            predicates.append(NSPredicate(format: "isFavorite == YES"))
        }

        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        // Sort by name
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch exercises: \(error)")
            return []
        }
    }

    /// Fetch a single exercise by ID
    func fetchExercise(id: UUID) -> ExerciseTemplate? {
        let request: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Failed to fetch exercise: \(error)")
            return nil
        }
    }

    /// Create a new exercise
    @discardableResult
    func createExercise(
        name: String,
        muscleGroup: String,
        category: String,
        isFavorite: Bool = false
    ) -> ExerciseTemplate {
        let exercise = ExerciseTemplate(context: viewContext)
        exercise.id = UUID()
        exercise.name = name
        exercise.muscleGroup = muscleGroup
        exercise.category = category
        exercise.isFavorite = isFavorite
        exercise.isCustom = true // User-created exercises are marked as custom
        exercise.createdDate = Date()

        save()
        return exercise
    }

    /// Update an existing exercise
    func updateExercise(
        _ exercise: ExerciseTemplate,
        name: String? = nil,
        muscleGroup: String? = nil,
        category: String? = nil,
        isFavorite: Bool? = nil,
        notes: String? = nil
    ) {
        if let name = name {
            exercise.name = name
        }
        if let muscleGroup = muscleGroup {
            exercise.muscleGroup = muscleGroup
        }
        if let category = category {
            exercise.category = category
        }
        if let isFavorite = isFavorite {
            exercise.isFavorite = isFavorite
        }
        if let notes = notes {
            exercise.notes = notes
        }

        save()
    }

    /// Delete an exercise
    func deleteExercise(_ exercise: ExerciseTemplate) {
        viewContext.delete(exercise)
        save()
    }

    // MARK: - Workout Session Operations

    /// Fetch all workout sessions, optionally filtered by workout type
    /// - Parameters:
    ///   - limit: Maximum number of sessions to return (nil = all)
    ///   - workoutType: Filter by workout type (nil = all types)
    func fetchWorkoutSessions(limit: Int? = nil, workoutType: String? = nil) -> [WorkoutSession] {
        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()

        if let workoutType = workoutType {
            request.predicate = NSPredicate(format: "workoutType == %@", workoutType)
        }

        // Sort by date descending (most recent first)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)]

        if let limit = limit {
            request.fetchLimit = limit
        }

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch workout sessions: \(error)")
            return []
        }
    }

    /// Fetch the most recent workout session
    func fetchMostRecentWorkout() -> WorkoutSession? {
        return fetchWorkoutSessions(limit: 1).first
    }

    /// Fetch a single workout session by ID
    func fetchWorkoutSession(id: UUID) -> WorkoutSession? {
        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Failed to fetch workout session: \(error)")
            return nil
        }
    }

    /// Create a new workout session
    @discardableResult
    func createWorkoutSession(workoutType: String, notes: String? = nil) -> WorkoutSession {
        let session = WorkoutSession(context: viewContext)
        session.id = UUID()
        session.date = Date()
        session.workoutType = workoutType
        session.startTime = Date()
        session.notes = notes

        save()
        return session
    }

    /// Finish a workout session (sets end time)
    func finishWorkoutSession(_ session: WorkoutSession) {
        session.endTime = Date()
        save()
    }

    /// Update a workout session
    func updateWorkoutSession(
        _ session: WorkoutSession,
        workoutType: String? = nil,
        notes: String? = nil
    ) {
        if let workoutType = workoutType {
            session.workoutType = workoutType
        }
        if let notes = notes {
            session.notes = notes
        }

        save()
    }

    /// Delete a workout session
    func deleteWorkoutSession(_ session: WorkoutSession) {
        viewContext.delete(session)
        save()
    }

    // MARK: - Set Entry Operations

    /// Log a new set
    /// - Returns: The created SetEntry and a flag indicating if it's a new PR
    @discardableResult
    func logSet(
        session: WorkoutSession,
        exercise: ExerciseTemplate,
        weight: Double,
        reps: Int,
        rpe: Double? = nil
    ) -> (set: SetEntry, isNewPR: Bool) {
        // Calculate set number (next in sequence for this exercise in this session)
        let existingSets = (session.sets?.allObjects as? [SetEntry] ?? [])
            .filter { $0.exercise?.id == exercise.id }
        let setNumber = Int32(existingSets.count + 1)

        // Create the set
        let setEntry = SetEntry(context: viewContext)
        setEntry.id = UUID()
        setEntry.setNumber = setNumber
        setEntry.weight = weight
        setEntry.reps = Int32(reps)
        setEntry.rpe = rpe
        setEntry.timestamp = Date()
        setEntry.exercise = exercise
        setEntry.workoutSession = session

        // Check for PR
        let prService = PRCalculatorService(dataService: self)
        let prResult = prService.checkForPR(exercise: exercise, weight: weight, reps: reps)
        setEntry.isPR = prResult.isNewPR

        // Update PRs if needed
        if prResult.isNewPR {
            prService.updatePRs(for: setEntry, prTypes: prResult.prTypes)
        }

        save()
        return (setEntry, prResult.isNewPR)
    }

    /// Fetch recent sets for a specific exercise
    func fetchRecentSets(for exercise: ExerciseTemplate, limit: Int = 10) -> [SetEntry] {
        let request: NSFetchRequest<SetEntry> = SetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SetEntry.timestamp, ascending: false)]
        request.fetchLimit = limit

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch recent sets: \(error)")
            return []
        }
    }

    /// Get the last set logged for a specific exercise
    func fetchLastSet(for exercise: ExerciseTemplate) -> SetEntry? {
        return fetchRecentSets(for: exercise, limit: 1).first
    }

    /// Delete a set entry
    func deleteSet(_ set: SetEntry) {
        viewContext.delete(set)
        save()
    }

    // MARK: - Personal Record Operations

    /// Fetch all PRs for a specific exercise
    func fetchPRs(for exercise: ExerciseTemplate) -> [PersonalRecord] {
        let request: NSFetchRequest<PersonalRecord> = PersonalRecord.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PersonalRecord.dateAchieved, ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch PRs: \(error)")
            return []
        }
    }

    /// Fetch all PRs of a specific type for an exercise
    func fetchPR(for exercise: ExerciseTemplate, type: String) -> PersonalRecord? {
        let request: NSFetchRequest<PersonalRecord> = PersonalRecord.fetchRequest()
        request.predicate = NSPredicate(
            format: "exercise == %@ AND recordType == %@",
            exercise,
            type
        )
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PersonalRecord.dateAchieved, ascending: false)]
        request.fetchLimit = 1

        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Failed to fetch PR: \(error)")
            return nil
        }
    }

    /// Create a new personal record
    @discardableResult
    func createPR(
        exercise: ExerciseTemplate,
        type: String,
        value: Double,
        reps: Int? = nil,
        setEntryId: UUID? = nil
    ) -> PersonalRecord {
        let pr = PersonalRecord(context: viewContext)
        pr.id = UUID()
        pr.recordType = type
        pr.value = value
        if let reps = reps {
            pr.reps = Int32(reps)
        }
        pr.dateAchieved = Date()
        pr.setEntryId = setEntryId
        pr.exercise = exercise

        save()
        return pr
    }

    /// Fetch all exercises that have PRs (for PRs screen)
    func fetchExercisesWithPRs() -> [ExerciseTemplate] {
        let request: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "personalRecords.@count > 0")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch exercises with PRs: \(error)")
            return []
        }
    }

    // MARK: - Analytics Operations

    /// Get total volume for an exercise over a date range
    func calculateVolume(
        for exercise: ExerciseTemplate,
        from startDate: Date,
        to endDate: Date
    ) -> Double {
        let request: NSFetchRequest<SetEntry> = SetEntry.fetchRequest()
        request.predicate = NSPredicate(
            format: "exercise == %@ AND timestamp >= %@ AND timestamp <= %@",
            exercise,
            startDate as NSDate,
            endDate as NSDate
        )

        do {
            let sets = try viewContext.fetch(request)
            return sets.reduce(0) { total, set in
                total + (set.weight * Double(set.reps))
            }
        } catch {
            print("Failed to calculate volume: \(error)")
            return 0
        }
    }

    /// Get workout frequency (number of workouts per week) over last N weeks
    func calculateWorkoutFrequency(weeks: Int = 4) -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -weeks, to: now) else {
            return 0
        }

        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)

        do {
            let workouts = try viewContext.fetch(request)
            return Double(workouts.count) / Double(weeks)
        } catch {
            print("Failed to calculate workout frequency: \(error)")
            return 0
        }
    }

    // MARK: - Helper Methods

    /// Save the current context
    private func save() {
        persistenceController.save()
    }
}
