//
//  SetRowView.swift
//  NoBSWorkout
//
//  Row component for displaying a logged set
//

import SwiftUI

struct SetRowView: View {

    let setEntry: SetEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: UIConstants.spacingM) {
            // Set number
            Text("\(setEntry.setNumber)")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 30)

            // Weight and reps
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(setEntry.weightFormatted)
                        .font(.body)
                        .fontWeight(.semibold)

                    Text("×")
                        .foregroundColor(AppColors.textSecondary)

                    Text("\(setEntry.reps)")
                        .font(.body)
                        .fontWeight(.semibold)
                }

                if let rpe = setEntry.rpe {
                    Text("RPE \(String(format: "%.1f", rpe))")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            // PR badge
            if setEntry.isPR {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.prGold)
                    Text("PR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.prGold)
                }
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.error)
            }
        }
        .padding()
        .background(AppColors.backgroundSecondary)
        .cornerRadius(UIConstants.cornerRadiusM)
    }
}

// MARK: - Preview

struct SetRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: UIConstants.spacingS) {
            SetRowView(
                setEntry: {
                    let context = PersistenceController.preview.viewContext
                    let set = SetEntry(context: context)
                    set.setNumber = 1
                    set.weight = 135
                    set.reps = 10
                    set.isPR = false
                    return set
                }(),
                onDelete: {}
            )

            SetRowView(
                setEntry: {
                    let context = PersistenceController.preview.viewContext
                    let set = SetEntry(context: context)
                    set.setNumber = 2
                    set.weight = 145
                    set.reps = 8
                    set.rpe = 8.5
                    set.isPR = true
                    return set
                }(),
                onDelete: {}
            )
        }
        .padding()
    }
}
