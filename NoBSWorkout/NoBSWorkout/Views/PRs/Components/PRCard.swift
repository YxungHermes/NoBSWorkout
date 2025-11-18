//
//  PRCard.swift
//  NoBSWorkout
//
//  Card component for displaying exercise PRs
//

import SwiftUI

struct PRCard: View {

    let exercise: ExerciseTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                // Exercise name and muscle group
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    if let muscleGroup = exercise.muscleGroup {
                        Text(muscleGroup)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Divider()

                // PR stats
                VStack(spacing: UIConstants.spacingXS) {
                    if let maxWeightPR = exercise.maxWeightPR {
                        HStack {
                            Label("Max Weight", systemImage: "scalemass.fill")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(maxWeightPR.value.asWeight)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }

                    if let est1RM = exercise.estimated1RMPR {
                        HStack {
                            Label("Est. 1RM", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(est1RM.value.asWeight)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }

                // Last PR date
                if let lastPerformed = exercise.lastPerformedDate {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text(lastPerformed.timeAgoShort)
                            .font(.caption2)
                    }
                    .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct PRCard_Previews: PreviewProvider {
    static var previews: some View {
        PRCard(
            exercise: {
                let context = PersistenceController.preview.viewContext
                let exercises = context.registeredObjects.compactMap { $0 as? ExerciseTemplate }
                return exercises.first!
            }(),
            onTap: {}
        )
        .padding()
    }
}
