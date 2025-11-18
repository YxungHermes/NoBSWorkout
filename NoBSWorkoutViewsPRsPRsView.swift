//
//  PRsView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI
import CoreData

struct PRsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PersonalRecord.dateAchieved, ascending: false)],
        animation: .default
    )
    private var allPRs: FetchedResults<PersonalRecord>
    
    var prsByExercise: [(ExerciseTemplate, [PersonalRecord])] {
        let grouped = Dictionary(grouping: allPRs) { $0.exercise }
        return grouped.compactMap { exercise, prs in
            guard let ex = exercise else { return nil }
            return (ex, prs.sorted { $0.wrappedDateAchieved > $1.wrappedDateAchieved })
        }.sorted { $0.0.wrappedName < $1.0.wrappedName }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if allPRs.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(prsByExercise, id: \.0.id) { exercise, prs in
                            PRExerciseRow(exercise: exercise, prs: prs)
                        }
                    }
                }
            }
            .navigationTitle("Personal Records")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
            
            Text("No PRs Yet")
                .font(.title2.bold())
            
            Text("Complete workouts to set your first personal records!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct PRExerciseRow: View {
    let exercise: ExerciseTemplate
    let prs: [PersonalRecord]
    
    var maxWeightPR: PersonalRecord? {
        prs.first { $0.wrappedRecordType == "max_weight" }
    }
    
    var oneRMPR: PersonalRecord? {
        prs.first { $0.wrappedRecordType == "estimated_1rm" }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Name
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.wrappedName)
                        .font(.headline)
                    Text(exercise.wrappedMuscleGroup)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
            }
            
            Divider()
            
            // PR Stats
            HStack(spacing: 20) {
                if let maxWeight = maxWeightPR {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Weight")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 4) {
                            Text("\(String(format: "%.1f", maxWeight.value))")
                                .font(.title3.bold())
                            Text("lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(maxWeight.wrappedDateAchieved, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let oneRM = oneRMPR {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Est. 1RM")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 4) {
                            Text("\(String(format: "%.1f", oneRM.value))")
                                .font(.title3.bold())
                            Text("lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(oneRM.wrappedDateAchieved, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    PRsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
