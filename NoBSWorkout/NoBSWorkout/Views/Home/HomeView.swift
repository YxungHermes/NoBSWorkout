//
//  HomeView.swift
//  NoBSWorkout
//
//  Main home screen with start workout button and recent activity
//

import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel = HomeViewModel()
    @State private var showingWorkoutTypeSelector = false

    var body: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacingL) {
                // Header
                VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                    Text(viewModel.motivationalMessage)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(viewModel.workoutsThisWeekText)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, UIConstants.spacingM)

                // Start Workout Button
                PrimaryButton(
                    "Start Workout",
                    icon: "play.fill",
                    style: .primary
                ) {
                    showingWorkoutTypeSelector = true
                }
                .padding(.horizontal)

                // Suggested Workout
                VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                    Text("Suggested")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal)

                    Button(action: {
                        showingWorkoutTypeSelector = true
                    }) {
                        HStack {
                            Image(systemName: viewModel.suggestedWorkoutType.icon)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(viewModel.suggestedWorkoutType.color)
                                .cornerRadius(10)

                            VStack(alignment: .leading) {
                                Text(viewModel.suggestedWorkoutType.rawValue)
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("Recommended next workout")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .cardStyle()
                    }
                    .padding(.horizontal)
                }

                // Recent Workout
                if let recentWorkout = viewModel.mostRecentWorkout {
                    VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                        Text("Last Workout")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)

                        RecentWorkoutCard(workout: recentWorkout)
                            .padding(.horizontal)
                    }
                } else {
                    // Empty state
                    VStack(spacing: UIConstants.spacingM) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.textTertiary)

                        Text("No workouts yet")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Tap 'Start Workout' to begin")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, UIConstants.spacingXL)
                }

                Spacer()
            }
        }
        .navigationTitle("NoBSWorkout")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWorkoutTypeSelector) {
            WorkoutTypeSelectionView(
                suggestedType: viewModel.suggestedWorkoutType,
                onSelect: { type in
                    let session = viewModel.startWorkout(type: type)
                    showingWorkoutTypeSelector = false
                    // Navigate to workout logging screen
                    // This will be handled by a NavigationLink in the actual implementation
                }
            )
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
