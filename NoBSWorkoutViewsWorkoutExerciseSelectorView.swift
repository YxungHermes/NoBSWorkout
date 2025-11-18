//
//  ExerciseSelectorView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

struct ExerciseSelectorView: View {
    let exercises: [ExerciseTemplate]
    let selectedExercise: ExerciseTemplate?
    let onSelect: (ExerciseTemplate) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredExercises: [ExerciseTemplate] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { 
                $0.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                $0.wrappedMuscleGroup.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var exercisesByMuscleGroup: [String: [ExerciseTemplate]] {
        Dictionary(grouping: filteredExercises) { $0.wrappedMuscleGroup }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercisesByMuscleGroup.keys.sorted(), id: \.self) { muscleGroup in
                    Section(muscleGroup) {
                        ForEach(exercisesByMuscleGroup[muscleGroup] ?? []) { exercise in
                            Button {
                                onSelect(exercise)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(exercise.wrappedName)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        
                                        if exercise.isCustom {
                                            Text("Custom")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if exercise.isFavorite {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.caption)
                                    }
                                    
                                    if exercise.id == selectedExercise?.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseSelectorView(
        exercises: [],
        selectedExercise: nil
    ) { _ in }
}
