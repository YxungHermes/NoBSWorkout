//
//  WorkoutDetailView.swift
//  NoBSWorkout
//
//  Detailed view of a single workout session
//

import SwiftUI

struct WorkoutDetailView: View {

    let workout: WorkoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UIConstants.spacingL) {
                // Header stats
                statsSection

                Divider()
                    .padding(.horizontal)

                // Exercises and sets
                exercisesSection
            }
            .padding(.vertical)
        }
        .navigationTitle(workout.workoutType ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - View Components

    private var statsSection: some View {
        VStack(spacing: UIConstants.spacingM) {
            // Date and time
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.textSecondary)
                Text(workout.date?.smartFormattedWithTime ?? "Unknown")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UIConstants.spacingM) {
                StatCard(icon: "list.bullet", label: "Exercises", value: "\(workout.exerciseCount)")
                StatCard(icon: "chart.bar.fill", label: "Total Sets", value: "\(workout.setCount)")

                if let duration = workout.duration {
                    StatCard(icon: "clock.fill", label: "Duration", value: workout.durationFormatted)
                }

                StatCard(icon: "scalemass.fill", label: "Volume", value: "\(workout.volumeFormatted) lbs")

                if workout.prCount > 0 {
                    StatCard(icon: "star.fill", label: "PRs", value: "\(workout.prCount)", valueColor: AppColors.prGold)
                }
            }
        }
        .padding(.horizontal)
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingL) {
            ForEach(workout.setsByExercise(), id: \.exercise.id) { item in
                VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                    // Exercise header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.exercise.name ?? "Unknown")
                                .font(.headline)

                            if let muscleGroup = item.exercise.muscleGroup {
                                Text(muscleGroup)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        Spacer()

                        // Exercise PRs
                        if item.sets.contains(where: { $0.isPR }) {
                            Image(systemName: "star.fill")
                                .foregroundColor(AppColors.prGold)
                        }
                    }
                    .padding(.horizontal)

                    // Sets table
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Set")
                                .frame(width: 40, alignment: .leading)
                            Text("Weight")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Reps")
                                .frame(width: 60, alignment: .trailing)
                            Text("")
                                .frame(width: 30)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(AppColors.backgroundTertiary)

                        // Rows
                        ForEach(item.sets) { set in
                            SetDetailRow(set: set)
                            if set != item.sets.last {
                                Divider()
                                    .padding(.leading, UIConstants.spacingM)
                            }
                        }
                    }
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(UIConstants.cornerRadiusM)
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = AppColors.textPrimary

    var body: some View {
        VStack(spacing: UIConstants.spacingS) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(valueColor)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.backgroundSecondary)
        .cornerRadius(UIConstants.cornerRadiusM)
    }
}

// MARK: - Set Detail Row

struct SetDetailRow: View {
    let set: SetEntry

    var body: some View {
        HStack {
            Text("\(set.setNumber)")
                .frame(width: 40, alignment: .leading)
                .foregroundColor(AppColors.textSecondary)

            Text(set.weightFormatted)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(set.reps)")
                .frame(width: 60, alignment: .trailing)

            if set.isPR {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.prGold)
                    .font(.caption)
                    .frame(width: 30)
            } else {
                Text("")
                    .frame(width: 30)
            }
        }
        .font(.body)
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutDetailView(
                workout: PersistenceController.preview.viewContext.registeredObjects
                    .compactMap { $0 as? WorkoutSession }
                    .first!
            )
        }
    }
}
