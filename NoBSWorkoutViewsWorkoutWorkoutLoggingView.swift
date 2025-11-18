//
//  WorkoutLoggingView.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

struct WorkoutLoggingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: WorkoutLoggingViewModel
    @State private var showingExerciseSelector = false
    @State private var showingFinishConfirmation = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps
    }
    
    init(workoutType: String) {
        _viewModel = StateObject(wrappedValue: WorkoutLoggingViewModel(
            context: PersistenceController.shared.container.viewContext,
            workoutType: workoutType
        ))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Exercise Selector
                        exerciseSelectorButton
                        
                        // Current Exercise Info
                        if viewModel.currentExercise != nil {
                            // Logged Sets
                            loggedSetsSection
                            
                            // Input Section
                            inputSection
                            
                            // Action Buttons
                            actionButtons
                        } else {
                            emptyExerciseState
                        }
                    }
                    .padding()
                }
            }
            
            // PR Animation Overlay
            if viewModel.showingPRAnimation {
                PRAnimationView(message: viewModel.lastPRMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    showingFinishConfirmation = true
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish") {
                    showingFinishConfirmation = true
                }
                .font(.headline)
            }
        }
        .sheet(isPresented: $showingExerciseSelector) {
            ExerciseSelectorView(
                exercises: viewModel.exercises,
                selectedExercise: viewModel.currentExercise
            ) { exercise in
                viewModel.selectExercise(exercise)
                showingExerciseSelector = false
            }
        }
        .alert("Finish Workout?", isPresented: $showingFinishConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Finish") {
                viewModel.finishWorkout()
                dismiss()
            }
        } message: {
            Text("Your workout will be saved with \(viewModel.loggedSets.count) sets logged.")
        }
        .onAppear {
            // Auto-focus weight input
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .weight
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.workoutType)
                        .font(.title2.bold())
                    
                    if let exercise = viewModel.currentExercise {
                        Text(exercise.wrappedName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(viewModel.formattedDuration)
                        .font(.title3.bold())
                        .foregroundStyle(.blue)
                    
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Exercise Selector
    
    private var exerciseSelectorButton: some View {
        Button {
            showingExerciseSelector = true
        } label: {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading) {
                    Text("Exercise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.currentExercise?.wrappedName ?? "Select Exercise")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Logged Sets Section
    
    private var loggedSetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sets (\(viewModel.loggedSets.count))")
                    .font(.headline)
                
                Spacer()
                
                if !viewModel.loggedSets.isEmpty {
                    Button {
                        viewModel.copyLastSet()
                    } label: {
                        Label("Copy Last", systemImage: "doc.on.doc.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            if viewModel.loggedSets.isEmpty {
                Text("No sets logged yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.loggedSets) { set in
                        SetRowView(set: set)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            Text("Log New Set")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // Weight Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("0", text: $viewModel.weightInput)
                        .keyboardType(.decimalPad)
                        .font(.title2.bold())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($focusedField, equals: .weight)
                }
                
                // Reps Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("0", text: $viewModel.repsInput)
                        .keyboardType(.numberPad)
                        .font(.title2.bold())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .focused($focusedField, equals: .reps)
                }
            }
            
            // RPE Slider (Optional)
            Toggle("Show RPE", isOn: $viewModel.showRPE)
                .font(.subheadline)
            
            if viewModel.showRPE {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("RPE: \(String(format: "%.1f", viewModel.rpeValue))")
                            .font(.subheadline.bold())
                        
                        Spacer()
                        
                        Text("Rate of Perceived Exertion")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $viewModel.rpeValue, in: 1...10, step: 0.5)
                        .tint(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.logSet()
                focusedField = .weight
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Log Set")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.canLogSet ? 
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canLogSet)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyExerciseState: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Select an exercise to begin")
                .font(.headline)
            
            Button {
                showingExerciseSelector = true
            } label: {
                Text("Choose Exercise")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Set Row View

struct SetRowView: View {
    let set: SetEntry
    
    var body: some View {
        HStack {
            // Set number
            Text("\(set.setNumber)")
                .font(.headline)
                .frame(width: 30)
            
            Divider()
            
            // Weight
            HStack(spacing: 4) {
                Text("\(String(format: "%.1f", set.weight))")
                    .font(.body.bold())
                Text("lbs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Reps
            HStack(spacing: 4) {
                Text("\(set.reps)")
                    .font(.body.bold())
                Text("reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // PR Badge
            if set.isPR {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - PR Animation View

struct PRAnimationView: View {
    let message: String
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text(message)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .yellow.opacity(0.5), radius: 20)
        )
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutLoggingView(workoutType: "Push")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
