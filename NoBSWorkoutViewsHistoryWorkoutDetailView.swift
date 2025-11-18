//
//  WorkoutDetailView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutSession
    
    var exerciseGroups: [(ExerciseTemplate, [SetEntry])] {
        let sets = workout.setsArray
        let grouped = Dictionary(grouping: sets) { $0.exercise }
        return grouped.compactMap { exercise, sets in
            guard let ex = exercise else { return nil }
            return (ex, sets.sorted { $0.setNumber < $1.setNumber })
        }.sorted { $0.1.first?.timestamp ?? Date() < $1.1.first?.timestamp ?? Date() }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workout.wrappedWorkoutType)
                                .font(.title.bold())
                            Text(workout.wrappedDate, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        workoutTypeIcon(workout.wrappedWorkoutType)
                            .font(.system(size: 50))
                            .foregroundStyle(.blue.opacity(0.3))
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        StatItem(
                            icon: "clock",
                            value: formatDuration(workout.duration),
                            label: "Duration"
                        )
                        
                        StatItem(
                            icon: "dumbbell.fill",
                            value: "\(workout.exerciseCount)",
                            label: "Exercises"
                        )
                        
                        StatItem(
                            icon: "list.bullet",
                            value: "\(workout.setsArray.count)",
                            label: "Sets"
                        )
                        
                        StatItem(
                            icon: "chart.bar.fill",
                            value: formatVolume(workout.totalVolume),
                            label: "Volume"
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Exercises
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercises")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    ForEach(exerciseGroups, id: \.0.id) { exercise, sets in
                        ExerciseDetailCard(exercise: exercise, sets: sets)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func workoutTypeIcon(_ type: String) -> Image {
        let iconName: String
        switch type {
        case "Push": iconName = "arrow.up.circle.fill"
        case "Pull": iconName = "arrow.down.circle.fill"
        case "Legs": iconName = "figure.walk"
        case "Upper": iconName = "figure.arms.open"
        case "Lower": iconName = "figure.walk"
        case "Full Body": iconName = "figure.mixed.cardio"
        default: iconName = "dumbbell.fill"
        }
        return Image(systemName: iconName)
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
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
}

struct ExerciseDetailCard: View {
    let exercise: ExerciseTemplate
    let sets: [SetEntry]
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.wrappedName)
                        .font(.headline)
                    Text(exercise.wrappedMuscleGroup)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if sets.contains(where: { $0.isPR }) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                }
            }
            
            // Sets Table
            VStack(spacing: 8) {
                ForEach(sets) { set in
                    HStack {
                        Text("\(set.setNumber)")
                            .font(.caption.bold())
                            .frame(width: 25)
                        
                        Divider()
                        
                        HStack(spacing: 4) {
                            Text("\(String(format: "%.1f", set.weight))")
                                .font(.subheadline.bold())
                            Text("lbs")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 4) {
                            Text("\(set.reps)")
                                .font(.subheadline.bold())
                            Text("reps")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if set.isPR {
                            Text("PR")
                                .font(.caption2.bold())
                                .foregroundStyle(.yellow)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            }
            
            // Summary
            Text("Volume: \(String(format: "%.0f", totalVolume)) lbs")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        if let workout = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is WorkoutSession }) as? WorkoutSession {
            WorkoutDetailView(workout: workout)
        }
    }
}
