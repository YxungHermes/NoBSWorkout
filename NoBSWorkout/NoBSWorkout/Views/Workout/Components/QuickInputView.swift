//
//  QuickInputView.swift
//  NoBSWorkout
//
//  Quick input component for logging sets with weight and reps
//

import SwiftUI

struct QuickInputView: View {

    @Binding var weightInput: String
    @Binding var repsInput: String
    @Binding var rpeInput: Double
    @Binding var includeRPE: Bool

    let canLog: Bool
    let onLog: () -> Void
    let onCopyLast: () -> Void
    let hasLastSet: Bool

    var body: some View {
        VStack(spacing: UIConstants.spacingM) {
            // Weight and Reps inputs
            HStack(spacing: UIConstants.spacingM) {
                NumberInputField(
                    label: "WEIGHT",
                    placeholder: "0",
                    text: $weightInput,
                    keyboardType: .decimalPad,
                    unit: "lbs"
                )

                NumberInputField(
                    label: "REPS",
                    placeholder: "0",
                    text: $repsInput,
                    keyboardType: .numberPad,
                    unit: nil
                )
            }

            // RPE toggle and slider
            VStack(spacing: UIConstants.spacingS) {
                Toggle("Include RPE", isOn: $includeRPE)
                    .font(.caption)

                if includeRPE {
                    VStack(spacing: 4) {
                        HStack {
                            Text("RPE: \(String(format: "%.1f", rpeInput))")
                                .font(.headline)
                            Spacer()
                        }

                        Slider(value: $rpeInput, in: 1...10, step: 0.5)
                            .accentColor(AppColors.primary)
                    }
                }
            }

            // Action buttons
            HStack(spacing: UIConstants.spacingM) {
                if hasLastSet {
                    Button(action: onCopyLast) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Last")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIConstants.buttonHeightSmall)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(UIConstants.cornerRadiusM)
                        .overlay(
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusM)
                                .stroke(AppColors.primary, lineWidth: 1)
                        )
                    }
                }

                Button(action: onLog) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Log Set")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: UIConstants.buttonHeightMedium)
                    .background(canLog ? AppColors.success : Color.gray.opacity(0.3))
                    .cornerRadius(UIConstants.cornerRadiusM)
                }
                .disabled(!canLog)
            }
        }
        .padding()
        .background(AppColors.backgroundPrimary)
        .cornerRadius(UIConstants.cornerRadiusL)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
    }
}

// MARK: - Preview

struct QuickInputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            QuickInputView(
                weightInput: .constant("135"),
                repsInput: .constant("10"),
                rpeInput: .constant(8.0),
                includeRPE: .constant(true),
                canLog: true,
                onLog: {},
                onCopyLast: {},
                hasLastSet: true
            )
        }
        .background(AppColors.backgroundSecondary)
    }
}
