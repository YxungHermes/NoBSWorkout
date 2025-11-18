//
//  HistoryView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)],
        predicate: NSPredicate(format: "endTime != nil"),
        animation: .default
    )
    private var workouts: FetchedResults<WorkoutSession>
    
    var body: some View {
        NavigationStack {
            ZStack {
                if workouts.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutCard(workout: workout)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Workouts Yet")
                .font(.title2.bold())
            
            Text("Your workout history will appear here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct WorkoutCard: View {
    let workout: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.wrappedWorkoutType)
                    .font(.headline)
                
                Spacer()
                
                Text(workout.wrappedDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                Label("\(workout.exerciseCount)", systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label(formatDuration(workout.duration), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(workout.setsArray.count)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if workout.setsArray.contains(where: { $0.isPR }) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("PR Achieved!")
                        .font(.caption.bold())
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

#Preview {
    HistoryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
