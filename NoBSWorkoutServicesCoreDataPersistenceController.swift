//
//  PersistenceController.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NoBSWorkout")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Seed initial data if needed
        seedDefaultExercisesIfNeeded()
    }
    
    // Preview helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample data for previews
        let pushWorkout = WorkoutSession(context: context)
        pushWorkout.id = UUID()
        pushWorkout.date = Date()
        pushWorkout.workoutType = "Push"
        pushWorkout.startTime = Date().addingTimeInterval(-3600)
        pushWorkout.endTime = Date()
        
        let benchPress = ExerciseTemplate(context: context)
        benchPress.id = UUID()
        benchPress.name = "Barbell Bench Press"
        benchPress.muscleGroup = "Chest"
        benchPress.category = "Push"
        benchPress.isCustom = false
        benchPress.isFavorite = true
        benchPress.createdDate = Date()
        
        let set1 = SetEntry(context: context)
        set1.id = UUID()
        set1.setNumber = 1
        set1.weight = 135.0
        set1.reps = 8
        set1.timestamp = Date()
        set1.isPR = false
        set1.workoutSession = pushWorkout
        set1.exercise = benchPress
        
        try? context.save()
        return controller
    }()
    
    private func seedDefaultExercisesIfNeeded() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // Seed default exercises
                let defaultExercises: [(String, String, String)] = [
                    // Push
                    ("Barbell Bench Press", "Chest", "Push"),
                    ("Incline Barbell Bench Press", "Chest", "Push"),
                    ("Dumbbell Bench Press", "Chest", "Push"),
                    ("Barbell Overhead Press", "Shoulders", "Push"),
                    ("Dumbbell Shoulder Press", "Shoulders", "Push"),
                    ("Dips", "Chest", "Push"),
                    ("Tricep Pushdown", "Triceps", "Push"),
                    ("Overhead Tricep Extension", "Triceps", "Push"),
                    
                    // Pull
                    ("Barbell Deadlift", "Back", "Pull"),
                    ("Barbell Row", "Back", "Pull"),
                    ("Dumbbell Row", "Back", "Pull"),
                    ("Pull-ups", "Back", "Pull"),
                    ("Lat Pulldown", "Back", "Pull"),
                    ("Face Pulls", "Rear Delts", "Pull"),
                    ("Barbell Curl", "Biceps", "Pull"),
                    ("Hammer Curl", "Biceps", "Pull"),
                    
                    // Legs
                    ("Barbell Squat", "Quads", "Legs"),
                    ("Front Squat", "Quads", "Legs"),
                    ("Romanian Deadlift", "Hamstrings", "Legs"),
                    ("Leg Press", "Quads", "Legs"),
                    ("Leg Curl", "Hamstrings", "Legs"),
                    ("Leg Extension", "Quads", "Legs"),
                    ("Calf Raise", "Calves", "Legs"),
                    ("Bulgarian Split Squat", "Quads", "Legs"),
                ]
                
                for (name, muscleGroup, category) in defaultExercises {
                    let exercise = ExerciseTemplate(context: context)
                    exercise.id = UUID()
                    exercise.name = name
                    exercise.muscleGroup = muscleGroup
                    exercise.category = category
                    exercise.isCustom = false
                    exercise.isFavorite = false
                    exercise.createdDate = Date()
                }
                
                try context.save()
                print("✅ Seeded \(defaultExercises.count) default exercises")
            }
        } catch {
            print("❌ Error seeding exercises: \(error)")
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Error saving context: \(error)")
            }
        }
    }
}
