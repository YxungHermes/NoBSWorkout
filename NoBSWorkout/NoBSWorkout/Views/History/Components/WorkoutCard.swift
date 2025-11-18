//
//  WorkoutCard.swift
//  NoBSWorkout
//
//  Card component for displaying workout in history list
//

import SwiftUI

struct WorkoutCard: View {

    let workout: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.workoutType ?? "Workout")
                        .font(.headline)
                        .fontWeight(.bold)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(workout.dateFormatted)
                            .font(.caption)
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                // PR badge
                if workout.prCount > 0 {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppColors.prGold)
                            Text("\(workout.prCount)")
                                .fontWeight(.bold)
                        }
                        .font(.caption)

                        Text("PR\(workout.prCount > 1 ? "s" : "")")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            // Stats row
            HStack(spacing: UIConstants.spacingL) {
                Label("\(workout.exerciseCount)", systemImage: "list.bullet")
                Label("\(workout.setCount)", systemImage: "chart.bar.fill")
                if let duration = workout.duration {
                    Label(workout.durationFormatted, systemImage: "clock.fill")
                }
            }
            .font(.caption)
            .foregroundColor(AppColors.textSecondary)

            // Exercises preview
            if !workout.exercises.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(workout.exercises.prefix(2)) { exercise in
                        Text("• \(exercise.name ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if workout.exerciseCount > 2 {
                        Text("+ \(workout.exerciseCount - 2) more")
                            .font(.caption2)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Preview

struct WorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: UIConstants.spacingM) {
            WorkoutCard(
                workout: PersistenceController.preview.viewContext.registeredObjects
                    .compactMap { $0 as? WorkoutSession }
                    .first!
            )
        }
        .padding()
    }
}
