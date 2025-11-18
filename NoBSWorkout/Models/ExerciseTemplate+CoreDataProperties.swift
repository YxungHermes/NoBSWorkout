//
//  ExerciseTemplate+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created by Core Data Code Generation
//

import Foundation
import CoreData

extension ExerciseTemplate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseTemplate> {
        return NSFetchRequest<ExerciseTemplate>(entityName: "ExerciseTemplate")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var muscleGroup: String?
    @NSManaged public var category: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isCustom: Bool
    @NSManaged public var notes: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var sets: NSSet?
    @NSManaged public var personalRecords: NSSet?

}

// MARK: Generated accessors for sets
extension ExerciseTemplate {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: SetEntry)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: SetEntry)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}

// MARK: Generated accessors for personalRecords
extension ExerciseTemplate {

    @objc(addPersonalRecordsObject:)
    @NSManaged public func addToPersonalRecords(_ value: PersonalRecord)

    @objc(removePersonalRecordsObject:)
    @NSManaged public func removeFromPersonalRecords(_ value: PersonalRecord)

    @objc(addPersonalRecords:)
    @NSManaged public func addToPersonalRecords(_ values: NSSet)

    @objc(removePersonalRecords:)
    @NSManaged public func removeFromPersonalRecords(_ values: NSSet)

}

extension ExerciseTemplate : Identifiable {

}
