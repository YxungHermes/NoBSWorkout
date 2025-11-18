//
//  WorkoutSession+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created by Core Data Code Generation
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

extension WorkoutSession : Identifiable {

}
