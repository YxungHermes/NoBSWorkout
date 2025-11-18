//
//  SetEntry+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import Foundation
import CoreData

extension SetEntry {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SetEntry> {
        return NSFetchRequest<SetEntry>(entityName: "SetEntry")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var setNumber: Int16
    @NSManaged public var weight: Double
    @NSManaged public var reps: Int16
    @NSManaged public var rpe: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var isPR: Bool
    @NSManaged public var workoutSession: WorkoutSession?
    @NSManaged public var exercise: ExerciseTemplate?
    
    public var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
    
    public var volume: Double {
        weight * Double(reps)
    }
}

extension SetEntry: Identifiable {
}
