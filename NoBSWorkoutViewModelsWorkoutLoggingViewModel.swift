//
//  WorkoutLoggingViewModel.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import Foundation
import CoreData
import Combine

@MainActor
class WorkoutLoggingViewModel: ObservableObject {
    @Published var currentSession: WorkoutSession?
    @Published var currentExercise: ExerciseTemplate?
    @Published var loggedSets: [SetEntry] = []
    @Published var weightInput: String = ""
    @Published var repsInput: String = ""
    @Published var rpeValue: Double = 7.0
    @Published var showRPE: Bool = false
    @Published var exercises: [ExerciseTemplate] = []
    @Published var sessionDuration: TimeInterval = 0
    @Published var showingPRAnimation = false
    @Published var lastPRMessage = ""
    
    private let context: NSManagedObjectContext
    private var timer: Timer?
    
    var workoutType: String
    
    init(context: NSManagedObjectContext, workoutType: String) {
        self.context = context
        self.workoutType = workoutType
        
        startNewSession()
        fetchExercises()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let session = self.currentSession else { return }
            Task { @MainActor in
                self.sessionDuration = Date().timeIntervalSince(session.wrappedStartTime)
            }
        }
    }
    
    func startNewSession() {
        let session = WorkoutSession(context: context)
        session.id = UUID()
        session.date = Date()
        session.workoutType = workoutType
        session.startTime = Date()
        
        currentSession = session
        saveContext()
    }
    
    func fetchExercises() {
        let request: NSFetchRequest<ExerciseTemplate> = ExerciseTemplate.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExerciseTemplate.isFavorite, ascending: false),
            NSSortDescriptor(keyPath: \ExerciseTemplate.name, ascending: true)
        ]
        
        // Filter by category if possible
        if workoutType != "Full Body" {
            request.predicate = NSPredicate(format: "category == %@", workoutType)
        }
        
        do {
            exercises = try context.fetch(request)
            
            // Auto-select first exercise if available
            if currentExercise == nil, let first = exercises.first {
                selectExercise(first)
            }
        } catch {
            print("❌ Error fetching exercises: \(error)")
        }
    }
    
    func selectExercise(_ exercise: ExerciseTemplate) {
        currentExercise = exercise
        loadSetsForCurrentExercise()
        
        // Auto-fill with last set if available
        if let lastSet = loggedSets.last {
            weightInput = String(format: "%.1f", lastSet.weight)
            repsInput = "\(lastSet.reps)"
        }
    }
    
    func loadSetsForCurrentExercise() {
        guard let session = currentSession, let exercise = currentExercise else {
            loggedSets = []
            return
        }
        
        let allSets = session.setsArray
        loggedSets = allSets.filter { $0.exercise?.id == exercise.id }
    }
    
    func copyLastSet() {
        guard let lastSet = loggedSets.last else { return }
        weightInput = String(format: "%.1f", lastSet.weight)
        repsInput = "\(lastSet.reps)"
        rpeValue = lastSet.rpe
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func logSet() {
        guard let session = currentSession,
              let exercise = currentExercise,
              let weight = Double(weightInput),
              let reps = Int(repsInput),
              weight > 0,
              reps > 0 else {
            return
        }
        
        let setEntry = SetEntry(context: context)
        setEntry.id = UUID()
        setEntry.setNumber = Int16(loggedSets.count + 1)
        setEntry.weight = weight
        setEntry.reps = Int16(reps)
        setEntry.rpe = showRPE ? rpeValue : 0
        setEntry.timestamp = Date()
        setEntry.workoutSession = session
        setEntry.exercise = exercise
        
        // Check for PR
        let isPR = checkForPR(exercise: exercise, weight: weight, reps: reps, setEntry: setEntry)
        setEntry.isPR = isPR
        
        if isPR {
            showPRAnimation(for: exercise, weight: weight, reps: reps)
        }
        
        saveContext()
        loadSetsForCurrentExercise()
        
        // Clear inputs (or keep for next set)
        // Keeping them makes logging faster
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func checkForPR(exercise: ExerciseTemplate, weight: Double, reps: Int, setEntry: SetEntry) -> Bool {
        // Fetch existing PRs
        let request: NSFetchRequest<PersonalRecord> = PersonalRecord.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        
        do {
            let existingPRs = try context.fetch(request)
            
            // Check max weight PR
            let maxWeightPRs = existingPRs.filter { $0.wrappedRecordType == "max_weight" }
            let currentMaxWeight = maxWeightPRs.first?.value ?? 0
            
            if weight > currentMaxWeight {
                createPR(type: "max_weight", value: weight, reps: reps, exercise: exercise, setEntryId: setEntry.id)
                return true
            }
            
            // Check estimated 1RM
            let estimated1RM = calculateEstimated1RM(weight: weight, reps: reps)
            let oneRMPRs = existingPRs.filter { $0.wrappedRecordType == "estimated_1rm" }
            let currentBest1RM = oneRMPRs.first?.value ?? 0
            
            if estimated1RM > currentBest1RM {
                createPR(type: "estimated_1rm", value: estimated1RM, reps: reps, exercise: exercise, setEntryId: setEntry.id)
                return true
            }
            
            return false
        } catch {
            print("❌ Error checking for PR: \(error)")
            return false
        }
    }
    
    private func createPR(type: String, value: Double, reps: Int, exercise: ExerciseTemplate, setEntryId: UUID?) {
        let pr = PersonalRecord(context: context)
        pr.id = UUID()
        pr.recordType = type
        pr.value = value
        pr.reps = Int16(reps)
        pr.dateAchieved = Date()
        pr.setEntryId = setEntryId
        pr.exercise = exercise
    }
    
    private func calculateEstimated1RM(weight: Double, reps: Int) -> Double {
        // Epley formula: weight × (1 + reps / 30)
        return weight * (1 + Double(reps) / 30.0)
    }
    
    private func showPRAnimation(for exercise: ExerciseTemplate, weight: Double, reps: Int) {
        lastPRMessage = "🎉 New PR: \(exercise.wrappedName)\n\(String(format: "%.1f", weight)) lbs × \(reps) reps"
        showingPRAnimation = true
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingPRAnimation = false
        }
    }
    
    func finishWorkout() {
        guard let session = currentSession else { return }
        session.endTime = Date()
        saveContext()
        timer?.invalidate()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Error saving context: \(error)")
        }
    }
    
    var formattedDuration: String {
        let hours = Int(sessionDuration) / 3600
        let minutes = (Int(sessionDuration) % 3600) / 60
        let seconds = Int(sessionDuration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var canLogSet: Bool {
        guard let weight = Double(weightInput),
              let reps = Int(repsInput) else {
            return false
        }
        return weight > 0 && reps > 0 && currentExercise != nil
    }
}
