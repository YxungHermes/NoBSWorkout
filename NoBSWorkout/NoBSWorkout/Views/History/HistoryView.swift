//
//  HistoryView.swift
//  NoBSWorkout
//
//  View for browsing workout history
//

import SwiftUI

struct HistoryView: View {

    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingFilterSheet = false

    var body: some View {
        Group {
            if viewModel.workoutSessions.isEmpty {
                emptyStateView
            } else {
                workoutListView
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingFilterSheet = true
                }) {
                    Image(systemName: viewModel.selectedWorkoutType == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(
                selectedType: $viewModel.selectedWorkoutType,
                availableTypes: viewModel.availableWorkoutTypes
            )
        }
        .onAppear {
            viewModel.loadWorkouts()
        }
    }

    // MARK: - View Components

    private var workoutListView: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacingL) {
                // Stats header
                statsHeaderView

                // Grouped workouts
                ForEach(viewModel.groupedWorkouts, id: \.0) { group in
                    VStack(alignment: .leading, spacing: UIConstants.spacingS) {
                        Text(group.0)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)

                        ForEach(group.1) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutCard(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteWorkout(workout)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private var statsHeaderView: some View {
        VStack(spacing: UIConstants.spacingS) {
            HStack(spacing: UIConstants.spacingL) {
                StatBox(
                    value: "\(viewModel.totalWorkouts)",
                    label: "Total Workouts",
                    icon: "checkmark.circle.fill",
                    color: AppColors.success
                )

                StatBox(
                    value: String(format: "%.1f", viewModel.averageWorkoutsPerWeek),
                    label: "Per Week",
                    icon: "calendar",
                    color: AppColors.primary
                )
            }

            if let selectedType = viewModel.selectedWorkoutType {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(AppColors.primary)
                    Text("Filtered: \(selectedType)")
                        .font(.caption)
                    Spacer()
                    Button("Clear") {
                        viewModel.clearFilter()
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(AppColors.backgroundSecondary)
                .cornerRadius(UIConstants.cornerRadiusM)
            }
        }
        .padding(.horizontal)
    }

    private var emptyStateView: some View {
        VStack(spacing: UIConstants.spacingM) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("No workouts yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Start your first workout from the home screen")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Stat Box Component

struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: UIConstants.spacingS) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.backgroundSecondary)
        .cornerRadius(UIConstants.cornerRadiusM)
    }
}

// MARK: - Filter Sheet

struct FilterSheetView: View {
    @Binding var selectedType: String?
    let availableTypes: [String]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        selectedType = nil
                        dismiss()
                    }) {
                        HStack {
                            Text("All Workouts")
                            Spacer()
                            if selectedType == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }

                Section("Workout Types") {
                    ForEach(availableTypes, id: \.self) { type in
                        Button(action: {
                            selectedType = type
                            dismiss()
                        }) {
                            HStack {
                                Text(type)
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
