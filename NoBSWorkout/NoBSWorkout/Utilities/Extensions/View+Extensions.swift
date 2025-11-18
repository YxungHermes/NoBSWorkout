//
//  View+Extensions.swift
//  NoBSWorkout
//
//  Useful view modifiers and extensions
//

import SwiftUI

extension View {

    /// Apply a card style with background and shadow
    func cardStyle(
        backgroundColor: Color = AppColors.backgroundSecondary,
        cornerRadius: CGFloat = UIConstants.cornerRadiusM,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }

    /// Apply a primary button style
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: UIConstants.buttonHeightMedium)
            .background(AppColors.primary)
            .cornerRadius(UIConstants.cornerRadiusM)
    }

    /// Apply a secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: UIConstants.buttonHeightMedium)
            .background(AppColors.backgroundSecondary)
            .cornerRadius(UIConstants.cornerRadiusM)
            .overlay(
                RoundedRectangle(cornerRadius: UIConstants.cornerRadiusM)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
    }

    /// Apply conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Add a dismiss keyboard toolbar button
    func dismissKeyboardToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }

    /// Add haptic feedback on tap
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }
}

// MARK: - Custom View Modifiers

/// Modifier for shaking animation (useful for error states)
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

extension View {
    func shake(animatableData: CGFloat) -> some View {
        self.modifier(Shake(animatableData: animatableData))
    }
}

// MARK: - PR Badge Modifier

struct PRBadge: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppColors.prGold)
                            .font(.system(size: 20))
                            .padding(8)
                        Spacer()
                    }
                }
            )
    }
}

extension View {
    func prBadge() -> some View {
        self.modifier(PRBadge())
    }
}
