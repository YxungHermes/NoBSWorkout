//
//  PersistenceController.swift
//  NoBSWorkout
//
//  Core Data stack manager following singleton pattern.
//  Handles persistent store setup, preview instances, and seeding initial data.
//

import CoreData
import Foundation

/// Manages the Core Data stack for the app.
/// Uses NSPersistentContainer for simple local-only storage (can be upgraded to NSPersistentCloudKitContainer for iCloud sync).
class PersistenceController {

    // MARK: - Singleton

    /// Shared instance for app-wide use
    static let shared = PersistenceController()

    /// Preview instance with in-memory store for SwiftUI previews and testing
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Create sample data for previews
        // Sample exercises
        let bench = ExerciseTemplate(context: viewContext)
        bench.id = UUID()
        bench.name = "Barbell Bench Press"
        bench.muscleGroup = "Chest"
        bench.category = "Push"
        bench.isFavorite = true
        bench.isCustom = false
        bench.createdDate = Date()

        let squat = ExerciseTemplate(context: viewContext)
        squat.id = UUID()
        squat.name = "Barbell Squat"
        squat.muscleGroup = "Legs"
        squat.category = "Legs"
        squat.isFavorite = true
        squat.isCustom = false
        squat.createdDate = Date()

        // Sample workout session
        let workout = WorkoutSession(context: viewContext)
        workout.id = UUID()
        workout.date = Date()
        workout.workoutType = "Push"
        workout.startTime = Date().addingTimeInterval(-3600) // 1 hour ago
        workout.endTime = Date()

        // Sample sets
        for i in 1...3 {
            let set = SetEntry(context: viewContext)
            set.id = UUID()
            set.setNumber = Int32(i)
            set.weight = 135.0 + Double(i * 10)
            set.reps = Int32(10 - i)
            set.timestamp = Date().addingTimeInterval(-3600 + Double(i * 300))
            set.isPR = i == 3
            set.exercise = bench
            set.workoutSession = workout
        }

        // Sample PR
        let pr = PersonalRecord(context: viewContext)
        pr.id = UUID()
        pr.recordType = "max_weight"
        pr.value = 155.0
        pr.reps = 7
        pr.dateAchieved = Date()
        pr.exercise = bench

        do {
            try viewContext.save()
        } catch {
            fatalError("Preview data creation failed: \(error)")
        }

        return controller
    }()

    // MARK: - Properties

    /// The persistent container for the app's Core Data stack
    let container: NSPersistentContainer

    /// Convenience access to the main view context
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Initialization

    /// Initialize the persistence controller
    /// - Parameter inMemory: If true, uses in-memory store (for testing/previews). If false, uses SQLite store.
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NoBSWorkout")

        if inMemory {
            // Use in-memory store for testing
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this error more gracefully (e.g., alert user, attempt recovery)
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        // Configure view context for better performance and UI updates
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Seed initial data if this is first launch
        if !inMemory {
            seedInitialDataIfNeeded()
        }
    }

    // MARK: - Data Seeding

    /// Check if initial data has been seeded, and seed if needed
    private func seedInitialDataIfNeeded() {
        let defaults = UserDefaults.standard
        let hasSeededKey = "hasSeededInitialExercises"

        guard !defaults.bool(forKey: hasSeededKey) else {
            return
        }

        print("First launch detected. Seeding initial exercise data...")
        seedDefaultExercises()
        defaults.set(true, forKey: hasSeededKey)
    }

    /// Seed the database with common exercises
    private func seedDefaultExercises() {
        let context = container.viewContext

        let defaultExercises: [(name: String, muscleGroup: String, category: String)] = [
            // Push exercises
            ("Barbell Bench Press", "Chest", "Push"),
            ("Incline Barbell Bench Press", "Chest", "Push"),
            ("Dumbbell Bench Press", "Chest", "Push"),
            ("Overhead Press", "Shoulders", "Push"),
            ("Dumbbell Shoulder Press", "Shoulders", "Push"),
            ("Dips", "Chest", "Push"),
            ("Tricep Pushdown", "Triceps", "Push"),
            ("Overhead Tricep Extension", "Triceps", "Push"),

            // Pull exercises
            ("Barbell Row", "Back", "Pull"),
            ("Dumbbell Row", "Back", "Pull"),
            ("Pull-ups", "Back", "Pull"),
            ("Lat Pulldown", "Back", "Pull"),
            ("Deadlift", "Back", "Pull"),
            ("Romanian Deadlift", "Hamstrings", "Pull"),
            ("Face Pulls", "Rear Delts", "Pull"),
            ("Barbell Curl", "Biceps", "Pull"),
            ("Hammer Curl", "Biceps", "Pull"),

            // Leg exercises
            ("Barbell Squat", "Quads", "Legs"),
            ("Front Squat", "Quads", "Legs"),
            ("Leg Press", "Quads", "Legs"),
            ("Bulgarian Split Squat", "Quads", "Legs"),
            ("Leg Extension", "Quads", "Legs"),
            ("Leg Curl", "Hamstrings", "Legs"),
            ("Calf Raise", "Calves", "Legs"),
        ]

        for (name, muscleGroup, category) in defaultExercises {
            let exercise = ExerciseTemplate(context: context)
            exercise.id = UUID()
            exercise.name = name
            exercise.muscleGroup = muscleGroup
            exercise.category = category
            exercise.isFavorite = false
            exercise.isCustom = false
            exercise.createdDate = Date()
        }

        do {
            try context.save()
            print("Successfully seeded \(defaultExercises.count) exercises")
        } catch {
            print("Failed to seed exercises: \(error)")
        }
    }

    // MARK: - Helper Methods

    /// Save changes to the main context
    func save() {
        let context = container.viewContext

        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
            // In production, handle this more gracefully
        }
    }

    /// Create a new background context for heavy operations
    /// Use this for imports, batch updates, etc. to avoid blocking the UI
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
