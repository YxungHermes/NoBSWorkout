//
//  WorkoutLoggingView.swift
//  NoBSWorkout
//
//  Main workout logging screen - optimized for speed and one-handed use
//

import SwiftUI

struct WorkoutLoggingView: View {

    @StateObject private var viewModel: WorkoutLoggingViewModel
    @StateObject private var timerService = TimerService()
    @State private var showingTimer = false
    @State private var showingFinishConfirmation = false
    @Environment(\.dismiss) private var dismiss

    init(workoutSession: WorkoutSession) {
        _viewModel = StateObject(wrappedValue: WorkoutLoggingViewModel(workoutSession: workoutSession))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                headerView

                Divider()

                // Main content
                ScrollView {
                    VStack(spacing: UIConstants.spacingM) {
                        // Exercise selector button
                        exerciseSelectorButton

                        // Logged sets for current exercise
                        if !viewModel.setsForCurrentExercise.isEmpty {
                            loggedSetsSection
                        }

                        // Info message if no exercise selected
                        if viewModel.currentExercise == nil {
                            emptyStateView
                        }

                        Spacer(minLength: 300) // Space for input view
                    }
                    .padding()
                }

                // Quick input view (always visible at bottom)
                if viewModel.currentExercise != nil {
                    QuickInputView(
                        weightInput: $viewModel.weightInput,
                        repsInput: $viewModel.repsInput,
                        rpeInput: $viewModel.rpeInput,
                        includeRPE: $viewModel.includeRPE,
                        canLog: viewModel.canLogSet,
                        onLog: {
                            viewModel.logSet()
                        },
                        onCopyLast: {
                            viewModel.copyLastSet()
                        },
                        hasLastSet: viewModel.lastSet != nil
                    )
                    .transition(.move(edge: .bottom))
                }
            }

            // PR celebration overlay
            if viewModel.showingPRCelebration {
                PRCelebrationView(message: viewModel.prMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle(viewModel.currentWorkoutSession.workoutType ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingTimer = true }) {
                        Label("Timer", systemImage: "timer")
                    }

                    Button(action: { showingFinishConfirmation = true }) {
                        Label("Finish Workout", systemImage: "checkmark.circle")
                    }
                    .disabled(!viewModel.canFinishWorkout)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showingExerciseSelector) {
            ExerciseSelectorView(
                searchText: $viewModel.searchText,
                exercises: viewModel.filteredExercises,
                suggestedExercises: viewModel.suggestedExercises,
                favoriteExercises: viewModel.favoriteExercises,
                onSelect: { exercise in
                    viewModel.selectExercise(exercise)
                },
                onCreate: { name, muscleGroup, category in
                    viewModel.createCustomExercise(name: name, muscleGroup: muscleGroup, category: category)
                }
            )
        }
        .sheet(isPresented: $showingTimer) {
            TimerView()
                .environmentObject(timerService)
        }
        .alert("Finish Workout?", isPresented: $showingFinishConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                viewModel.finishWorkout()
                dismiss()
            }
        } message: {
            Text(viewModel.workoutSummary)
        }
        .animation(.spring(), value: viewModel.showingPRCelebration)
    }

    // MARK: - View Components

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let exercise = viewModel.currentExercise {
                    Text(exercise.name ?? "Unknown")
                        .font(.headline)
                    Text("Set \(viewModel.setNumber)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                } else {
                    Text("Select an exercise to begin")
                        .font(.headline)
                }
            }

            Spacer()

            // Elapsed time
            Text(viewModel.elapsedTime)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.backgroundSecondary)
    }

    private var exerciseSelectorButton: some View {
        Button(action: {
            viewModel.showingExerciseSelector = true
        }) {
            HStack {
                Image(systemName: viewModel.currentExercise == nil ? "plus.circle.fill" : "rectangle.stack.fill")
                    .foregroundColor(AppColors.primary)

                Text(viewModel.currentExercise == nil ? "Select Exercise" : "Change Exercise")
                    .foregroundColor(AppColors.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding()
            .cardStyle()
        }
    }

    private var loggedSetsSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            Text("Logged Sets")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textSecondary)

            ForEach(viewModel.setsForCurrentExercise) { set in
                SetRowView(setEntry: set) {
                    viewModel.deleteSet(set)
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: UIConstants.spacingM) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("Select an exercise to start logging")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.vertical, UIConstants.spacingXL)
    }
}

// MARK: - PR Celebration View

struct PRCelebrationView: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: UIConstants.spacingM) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.prGold)

                Text("New PR!")
                    .font(.title)
                    .fontWeight(.bold)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(UIConstants.spacingXL)
            .background(AppColors.backgroundPrimary)
            .cornerRadius(UIConstants.cornerRadiusL)
            .shadow(radius: 20)
            .padding(UIConstants.spacingXL)
        }
    }
}

// MARK: - Preview

struct WorkoutLoggingView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.viewContext
        let session = WorkoutSession(context: context)
        session.id = UUID()
        session.workoutType = "Push"
        session.date = Date()
        session.startTime = Date()

        return NavigationView {
            WorkoutLoggingView(workoutSession: session)
        }
        .environment(\.managedObjectContext, context)
    }
}
