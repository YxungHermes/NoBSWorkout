//
//  RecentWorkoutCard.swift
//  NoBSWorkout
//
//  Card component displaying recent workout summary
//

import SwiftUI

struct RecentWorkoutCard: View {

    let workout: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingM) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.workoutType ?? "Workout")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(workout.dateFormatted)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                if workout.prCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppColors.prGold)
                        Text("\(workout.prCount)")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                }
            }

            Divider()

            // Stats
            HStack(spacing: UIConstants.spacingL) {
                StatItem(
                    icon: "list.bullet",
                    value: "\(workout.exerciseCount)",
                    label: "Exercises"
                )

                StatItem(
                    icon: "chart.bar.fill",
                    value: "\(workout.setCount)",
                    label: "Sets"
                )

                if let duration = workout.duration {
                    StatItem(
                        icon: "clock.fill",
                        value: workout.durationFormatted,
                        label: "Duration"
                    )
                }
            }

            // Exercises list
            if !workout.exercises.isEmpty {
                VStack(alignment: .leading, spacing: UIConstants.spacingXS) {
                    Text("Exercises")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)

                    ForEach(workout.exercises.prefix(3)) { exercise in
                        Text("• \(exercise.name ?? "Unknown")")
                            .font(.subheadline)
                    }

                    if workout.exerciseCount > 3 {
                        Text("+ \(workout.exerciseCount - 3) more")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Stat Item Component

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .fontWeight(.bold)
            }
            .foregroundColor(AppColors.primary)

            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct RecentWorkoutCard_Previews: PreviewProvider {
    static var previews: some View {
        RecentWorkoutCard(
            workout: PersistenceController.preview.viewContext.registeredObjects
                .compactMap { $0 as? WorkoutSession }
                .first!
        )
        .padding()
    }
}
