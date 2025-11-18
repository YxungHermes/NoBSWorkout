//
//  PersonalRecord+CoreDataProperties.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
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
    
    public var wrappedRecordType: String {
        recordType ?? "unknown"
    }
    
    public var wrappedDateAchieved: Date {
        dateAchieved ?? Date()
    }
}

extension PersonalRecord: Identifiable {
}
