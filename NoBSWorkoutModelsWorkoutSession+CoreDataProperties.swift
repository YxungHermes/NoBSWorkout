//
//  WorkoutSession+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import Foundation
import CoreData

extension WorkoutSession {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSession> {
        return NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var workoutType: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var notes: String?
    @NSManaged public var sets: NSSet?
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var wrappedWorkoutType: String {
        workoutType ?? "Unknown"
    }
    
    public var wrappedStartTime: Date {
        startTime ?? Date()
    }
    
    public var setsArray: [SetEntry] {
        let set = sets as? Set<SetEntry> ?? []
        return set.sorted { $0.wrappedTimestamp < $1.wrappedTimestamp }
    }
    
    public var duration: TimeInterval {
        guard let start = startTime, let end = endTime else { return 0 }
        return end.timeIntervalSince(start)
    }
    
    public var totalVolume: Double {
        setsArray.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
    
    public var exerciseCount: Int {
        let exercises = Set(setsArray.compactMap { $0.exercise?.id })
        return exercises.count
    }
    
    public var isInProgress: Bool {
        endTime == nil
    }
}

// MARK: Generated accessors for sets
extension WorkoutSession {
    
    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: SetEntry)
    
    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: SetEntry)
    
    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)
    
    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)
}

extension WorkoutSession: Identifiable {
}
