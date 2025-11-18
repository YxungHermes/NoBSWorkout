//
//  NumberInputField.swift
//  NoBSWorkout
//
//  Reusable number input field optimized for workout logging
//

import SwiftUI

struct NumberInputField: View {

    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .decimalPad
    var unit: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingXS) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(height: 60)
                    .background(AppColors.backgroundSecondary)
                    .cornerRadius(UIConstants.cornerRadiusM)

                if let unit = unit {
                    Text(unit)
                        .font(.headline)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 50)
                }
            }
        }
    }
}

// MARK: - Preview

struct NumberInputField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: UIConstants.spacingL) {
            NumberInputField(
                label: "WEIGHT",
                placeholder: "0",
                text: .constant("135"),
                keyboardType: .decimalPad,
                unit: "lbs"
            )

            NumberInputField(
                label: "REPS",
                placeholder: "0",
                text: .constant("10"),
                keyboardType: .numberPad,
                unit: "reps"
            )
        }
        .padding()
    }
}
