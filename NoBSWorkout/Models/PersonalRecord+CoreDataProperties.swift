//
//  PersonalRecord+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created by Core Data Code Generation
//

import Foundation
import CoreData

extension PersonalRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalRecord> {
        return NSFetchRequest<PersonalRecord>(entityName: "PersonalRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var recordType: String?
    @NSManaged public var value: Double
    @NSManaged public var reps: Int16
    @NSManaged public var dateAchieved: Date?
    @NSManaged public var setEntryId: UUID?
    @NSManaged public var exercise: ExerciseTemplate?

}

extension PersonalRecord : Identifiable {

}
