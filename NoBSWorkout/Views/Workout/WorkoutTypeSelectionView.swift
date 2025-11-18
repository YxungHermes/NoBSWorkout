//
//  WorkoutTypeSelectionView.swift
//  NoBSWorkout
//
//  Sheet for selecting workout type when starting a new workout
//

import SwiftUI

struct WorkoutTypeSelectionView: View {

    let suggestedType: WorkoutType
    let onSelect: (WorkoutType) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: UIConstants.spacingL) {
                    // Suggested workout highlight
                    VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                        Text("Suggested")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textSecondary)

                        WorkoutTypeCard(
                            type: suggestedType,
                            isHighlighted: true,
                            onTap: {
                                onSelect(suggestedType)
                            }
                        )
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // All workout types
                    Text("All Workout Types")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: UIConstants.spacingM) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            WorkoutTypeCard(
                                type: type,
                                isHighlighted: false,
                                onTap: {
                                    onSelect(type)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Select Workout Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Workout Type Card

struct WorkoutTypeCard: View {
    let type: WorkoutType
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: UIConstants.spacingS) {
                Image(systemName: type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [type.color, type.color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)

                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isHighlighted ?
                    AnyView(
                        LinearGradient(
                            gradient: Gradient(colors: [type.color.opacity(0.2), type.color.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) :
                    AnyView(AppColors.backgroundSecondary)
            )
            .cornerRadius(UIConstants.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.cornerRadiusM)
                    .stroke(isHighlighted ? type.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview

struct WorkoutTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTypeSelectionView(
            suggestedType: .push,
            onSelect: { type in
                print("Selected: \(type)")
            }
        )
    }
}
