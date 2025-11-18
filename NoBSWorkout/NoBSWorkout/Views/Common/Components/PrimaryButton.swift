//
//  PrimaryButton.swift
//  NoBSWorkout
//
//  Reusable primary button component
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    let icon: String?
    let action: () -> Void
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case success

        var backgroundColor: Color {
            switch self {
            case .primary: return AppColors.primary
            case .secondary: return AppColors.backgroundSecondary
            case .destructive: return AppColors.error
            case .success: return AppColors.success
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive, .success: return .white
            case .secondary: return AppColors.primary
            }
        }
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: UIConstants.spacingS) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIConstants.buttonHeightMedium)
            .background(isDisabled ? Color.gray.opacity(0.3) : style.backgroundColor)
            .foregroundColor(isDisabled ? Color.gray : style.foregroundColor)
            .cornerRadius(UIConstants.cornerRadiusM)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: UIConstants.spacingM) {
            PrimaryButton("Start Workout", icon: "play.fill") {
                print("Tapped")
            }

            PrimaryButton("Cancel", style: .secondary) {
                print("Tapped")
            }

            PrimaryButton("Delete", icon: "trash", style: .destructive) {
                print("Tapped")
            }

            PrimaryButton("Save", icon: "checkmark", style: .success) {
                print("Tapped")
            }

            PrimaryButton("Disabled", isDisabled: true) {
                print("Won't be called")
            }
        }
        .padding()
    }
}
