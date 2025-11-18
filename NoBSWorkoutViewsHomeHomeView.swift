//
//  HomeView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel
    @State private var showingWorkoutTypeSelection = false
    
    init() {
        // This will be properly initialized with context in the body
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("NoBSWorkout")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            
                            Text("Fast. Simple. Effective.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 32)
                        
                        // Start Workout Button - Primary CTA
                        Button {
                            showingWorkoutTypeSelection = true
                        } label: {
                            HStack {
                                Image(systemName: "figure.run")
                                    .font(.title2)
                                Text("Start Workout")
                                    .font(.title3.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundStyle(.white)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        
                        // Suggested Workout
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Suggested Next Workout", systemImage: "lightbulb.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            
                            HStack {
                                Image(systemName: workoutTypeIcon(viewModel.suggestedWorkoutType))
                                    .font(.title)
                                    .foregroundStyle(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.suggestedWorkoutType)
                                        .font(.title3.bold())
                                    Text("Based on your recent activity")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                        .padding(.horizontal)
                        
                        // Recent Workout Card
                        if let workout = viewModel.recentWorkout {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Last Workout", systemImage: "clock.fill")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(workout.wrappedWorkoutType)
                                                .font(.title3.bold())
                                            Text(viewModel.recentWorkoutDate)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: workoutTypeIcon(workout.wrappedWorkoutType))
                                            .font(.largeTitle)
                                            .foregroundStyle(.blue.opacity(0.3))
                                    }
                                    
                                    Divider()
                                    
                                    HStack(spacing: 20) {
                                        StatItem(
                                            icon: "figure.strengthtraining.traditional",
                                            value: "\(viewModel.recentWorkoutExerciseCount)",
                                            label: "Exercises"
                                        )
                                        
                                        StatItem(
                                            icon: "clock",
                                            value: formatDuration(workout.duration),
                                            label: "Duration"
                                        )
                                        
                                        StatItem(
                                            icon: "chart.bar.fill",
                                            value: formatVolume(workout.totalVolume),
                                            label: "Volume"
                                        )
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "dumbbell")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.secondary)
                                
                                Text("No workouts yet")
                                    .font(.headline)
                                
                                Text("Tap 'Start Workout' to begin your fitness journey!")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 40)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationDestination(isPresented: $showingWorkoutTypeSelection) {
                WorkoutTypeSelectionView()
            }
        }
        .onAppear {
            // Reinitialize with proper context
            viewModel.context = viewContext
            viewModel.fetchRecentWorkout()
            viewModel.calculateSuggestedWorkout()
        }
    }
    
    private func workoutTypeIcon(_ type: String) -> String {
        switch type {
        case "Push": return "arrow.up.circle.fill"
        case "Pull": return "arrow.down.circle.fill"
        case "Legs": return "figure.walk"
        case "Upper": return "figure.arms.open"
        case "Lower": return "figure.walk"
        case "Full Body": return "figure.mixed.cardio"
        default: return "dumbbell.fill"
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
    
    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        } else {
            return String(format: "%.0f", volume)
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
