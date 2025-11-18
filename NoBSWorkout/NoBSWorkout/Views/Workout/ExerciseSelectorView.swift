//
//  ExerciseSelectorView.swift
//  NoBSWorkout
//
//  Sheet for selecting or creating exercises during a workout
//

import SwiftUI

struct ExerciseSelectorView: View {

    @Binding var searchText: String
    let exercises: [ExerciseTemplate]
    let suggestedExercises: [ExerciseTemplate]
    let favoriteExercises: [ExerciseTemplate]
    let onSelect: (ExerciseTemplate) -> Void
    let onCreate: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateExercise = false

    var body: some View {
        NavigationView {
            List {
                // Favorites section
                if !favoriteExercises.isEmpty && searchText.isEmpty {
                    Section("Favorites") {
                        ForEach(favoriteExercises) { exercise in
                            ExerciseRow(exercise: exercise) {
                                onSelect(exercise)
                                dismiss()
                            }
                        }
                    }
                }

                // Suggested section
                if !suggestedExercises.isEmpty && searchText.isEmpty {
                    Section("Suggested for this Workout") {
                        ForEach(suggestedExercises.prefix(5)) { exercise in
                            ExerciseRow(exercise: exercise) {
                                onSelect(exercise)
                                dismiss()
                            }
                        }
                    }
                }

                // All exercises
                Section(searchText.isEmpty ? "All Exercises" : "Search Results") {
                    ForEach(exercises) { exercise in
                        ExerciseRow(exercise: exercise) {
                            onSelect(exercise)
                            dismiss()
                        }
                    }
                }

                // Create new exercise option
                if !searchText.isEmpty {
                    Button(action: {
                        showingCreateExercise = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppColors.primary)
                            Text("Create '\(searchText)'")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCreateExercise) {
                CreateExerciseView(
                    defaultName: searchText,
                    onCreate: { name, muscleGroup, category in
                        onCreate(name, muscleGroup, category)
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: ExerciseTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name ?? "Unknown")
                        .font(.body)
                        .foregroundColor(AppColors.textPrimary)

                    if let muscleGroup = exercise.muscleGroup {
                        Text(muscleGroup)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                if exercise.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.prGold)
                        .font(.caption)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
}

// MARK: - Create Exercise View

struct CreateExerciseView: View {
    let defaultName: String
    let onCreate: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedMuscleGroup: String = MuscleGroup.chest.rawValue
    @State private var selectedCategory: String = WorkoutType.push.rawValue

    init(defaultName: String, onCreate: @escaping (String, String, String) -> Void) {
        self.defaultName = defaultName
        self.onCreate = onCreate
        _name = State(initialValue: defaultName)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Exercise Details") {
                    TextField("Name", text: $name)

                    Picker("Muscle Group", selection: $selectedMuscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.rawValue).tag(group.rawValue)
                        }
                    }

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(WorkoutType.allCases.filter { $0 != .custom }, id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Create Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate(name, selectedMuscleGroup, selectedCategory)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

struct ExerciseSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSelectorView(
            searchText: .constant(""),
            exercises: [],
            suggestedExercises: [],
            favoriteExercises: [],
            onSelect: { _ in },
            onCreate: { _, _, _ in }
        )
    }
}
