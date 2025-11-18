//
//  HomeViewModel.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import Foundation
import CoreData
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentWorkout: WorkoutSession?
    @Published var suggestedWorkoutType: String = "Push"
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchRecentWorkout()
        calculateSuggestedWorkout()
    }
    
    func fetchRecentWorkout() {
        let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)]
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "endTime != nil")
        
        do {
            let results = try context.fetch(request)
            recentWorkout = results.first
        } catch {
            print("❌ Error fetching recent workout: \(error)")
        }
    }
    
    func calculateSuggestedWorkout() {
        guard let recent = recentWorkout else {
            suggestedWorkoutType = "Push"
            return
        }
        
        // Simple rotation: Push → Pull → Legs → Push
        switch recent.wrappedWorkoutType {
        case "Push":
            suggestedWorkoutType = "Pull"
        case "Pull":
            suggestedWorkoutType = "Legs"
        case "Legs":
            suggestedWorkoutType = "Push"
        default:
            suggestedWorkoutType = "Push"
        }
    }
    
    var recentWorkoutDate: String {
        guard let workout = recentWorkout else { return "No recent workouts" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: workout.wrappedDate, relativeTo: Date())
    }
    
    var recentWorkoutExerciseCount: Int {
        recentWorkout?.exerciseCount ?? 0
    }
}
