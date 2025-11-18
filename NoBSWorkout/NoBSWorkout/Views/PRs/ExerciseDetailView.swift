//
//  ExerciseDetailView.swift
//  NoBSWorkout
//
//  Detailed view of a single exercise with history, PRs, and progress charts
//

import SwiftUI

struct ExerciseDetailView: View {

    @StateObject private var viewModel: ExerciseDetailViewModel

    init(exercise: ExerciseTemplate) {
        _viewModel = StateObject(wrappedValue: ExerciseDetailViewModel(exercise: exercise))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: UIConstants.spacingL) {
                // Exercise info header
                exerciseInfoSection

                // Time range selector
                timeRangeSelector

                // Stats grid
                statsSection

                Divider()
                    .padding(.horizontal)

                // Charts section
                chartsSection

                Divider()
                    .padding(.horizontal)

                // Recent workouts
                recentWorkoutsSection
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.exercise.name ?? "Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - View Components

    private var exerciseInfoSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let muscleGroup = viewModel.exercise.muscleGroup {
                        Text(muscleGroup)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if let category = viewModel.exercise.category {
                        Text(category)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.2))
                            .foregroundColor(AppColors.primary)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                if viewModel.exercise.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.prGold)
                }
            }
        }
        .padding(.horizontal)
    }

    private var timeRangeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: UIConstants.spacingS) {
                ForEach(ExerciseDetailViewModel.TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        viewModel.selectedTimeRange = range
                    }) {
                        Text(range.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedTimeRange == range ? .white : AppColors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedTimeRange == range ? AppColors.primary : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.primary, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: UIConstants.spacingM) {
            StatCard(
                icon: "scalemass.fill",
                label: "Max Weight",
                value: viewModel.maxWeightFormatted
            )

            StatCard(
                icon: "chart.bar.fill",
                label: "Total Sets",
                value: "\(viewModel.totalSets)"
            )

            StatCard(
                icon: "number",
                label: "Avg Reps",
                value: viewModel.averageRepsFormatted
            )

            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                label: "Total Volume",
                value: viewModel.totalVolumeFormatted
            )
        }
        .padding(.horizontal)
    }

    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingL) {
            // Current PRs
            VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                Text("Personal Records")
                    .font(.headline)
                    .padding(.horizontal)

                HStack(spacing: UIConstants.spacingM) {
                    PRStatBox(
                        label: "Max Weight",
                        value: viewModel.currentMaxWeightPR,
                        icon: "scalemass.fill"
                    )

                    PRStatBox(
                        label: "Est. 1RM",
                        value: viewModel.currentEstimated1RM,
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }
                .padding(.horizontal)

                if let improvementRate = viewModel.prImprovementRate {
                    HStack {
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(AppColors.success)
                        Text("Improving at \(improvementRate)")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal)
                }
            }

            // Note about charts
            // In a real implementation, you would use Swift Charts (iOS 16+) or a third-party library
            // For now, we'll show a placeholder
            VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                Text("Progress Charts")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: UIConstants.spacingXS) {
                    Text("📊 Weight Progression")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text("📈 Volume Over Time")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Text("💪 1RM Progression")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.backgroundSecondary)
                .cornerRadius(UIConstants.cornerRadiusM)
                .padding(.horizontal)
            }
        }
    }

    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            Text("Recent Workouts")
                .font(.headline)
                .padding(.horizontal)

            if viewModel.recentSetsGroupedByWorkout.isEmpty {
                Text("No data for selected time range")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.recentSetsGroupedByWorkout, id: \.workout.id) { item in
                    WorkoutSetsCard(workout: item.workout, sets: item.sets)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - PR Stat Box

struct PRStatBox: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: UIConstants.spacingS) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.prGold)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.prGold.opacity(0.15), AppColors.prGold.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(UIConstants.cornerRadiusM)
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadiusM)
                .stroke(AppColors.prGold.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Workout Sets Card

struct WorkoutSetsCard: View {
    let workout: WorkoutSession
    let sets: [SetEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.dateFormatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(workout.workoutType ?? "")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text("\(sets.count) sets")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            // Sets list
            ForEach(sets) { set in
                HStack {
                    Text("\(set.setNumber)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 30)

                    Text(set.weightFormatted)
                        .font(.body)

                    Text("×")
                        .foregroundColor(AppColors.textSecondary)

                    Text("\(set.reps)")
                        .font(.body)

                    Spacer()

                    if set.isPR {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppColors.prGold)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Preview

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseDetailView(
                exercise: PersistenceController.preview.viewContext.registeredObjects
                    .compactMap { $0 as? ExerciseTemplate }
                    .first!
            )
        }
    }
}
