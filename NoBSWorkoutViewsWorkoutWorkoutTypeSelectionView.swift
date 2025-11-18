//
//  WorkoutTypeSelectionView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

struct WorkoutTypeSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: String?
    @State private var navigateToLogging = false
    
    let workoutTypes = [
        WorkoutType(name: "Push", icon: "arrow.up.circle.fill", color: .blue, description: "Chest, Shoulders, Triceps"),
        WorkoutType(name: "Pull", icon: "arrow.down.circle.fill", color: .green, description: "Back, Biceps, Rear Delts"),
        WorkoutType(name: "Legs", icon: "figure.walk", color: .orange, description: "Quads, Hamstrings, Calves"),
        WorkoutType(name: "Upper", icon: "figure.arms.open", color: .purple, description: "Full Upper Body"),
        WorkoutType(name: "Lower", icon: "figure.strengthtraining.traditional", color: .red, description: "Full Lower Body"),
        WorkoutType(name: "Full Body", icon: "figure.mixed.cardio", color: .pink, description: "Everything"),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Workout")
                        .font(.largeTitle.bold())
                    
                    Text("Select the type of workout you're doing today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Workout Type Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(workoutTypes) { type in
                        WorkoutTypeCard(type: type, isSelected: selectedType == type.name)
                            .onTapGesture {
                                selectedType = type.name
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                
                                // Navigate after slight delay for visual feedback
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    navigateToLogging = true
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Start Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToLogging) {
            if let type = selectedType {
                WorkoutLoggingView(workoutType: type)
            }
        }
    }
}

struct WorkoutType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let description: String
}

struct WorkoutTypeCard: View {
    let type: WorkoutType
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 44))
                .foregroundStyle(type.color)
                .frame(height: 60)
            
            VStack(spacing: 4) {
                Text(type.name)
                    .font(.headline)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? type.color.opacity(0.3) : .black.opacity(0.05), radius: isSelected ? 10 : 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? type.color : .clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    NavigationStack {
        WorkoutTypeSelectionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
