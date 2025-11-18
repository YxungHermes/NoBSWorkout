//
//  PRsView.swift
//  NoBSWorkout
//
//  View for browsing personal records across all exercises
//

import SwiftUI

struct PRsView: View {

    @StateObject private var viewModel = PRsViewModel()

    var body: some View {
        Group {
            if viewModel.exercisesWithPRs.isEmpty {
                emptyStateView
            } else {
                prListView
            }
        }
        .navigationTitle("Personal Records")
        .searchable(text: $viewModel.searchText, prompt: "Search exercises")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("Sort By", selection: $viewModel.sortOption) {
                        ForEach(PRsViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            }
        }
        .onAppear {
            viewModel.loadPRs()
        }
    }

    // MARK: - View Components

    private var prListView: some View {
        ScrollView {
            VStack(spacing: UIConstants.spacingL) {
                // Stats header
                statsHeader

                // Recent PRs section
                if !viewModel.recentPRs.isEmpty {
                    recentPRsSection
                }

                Divider()
                    .padding(.horizontal)

                // All exercises with PRs
                LazyVStack(spacing: UIConstants.spacingM) {
                    ForEach(viewModel.filteredAndSortedExercises) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            PRCard(exercise: exercise) {}
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var statsHeader: some View {
        HStack(spacing: UIConstants.spacingL) {
            VStack(spacing: 4) {
                Text("\(viewModel.exercisesWithPRs.count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)

                Text("Exercises")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.backgroundSecondary)
            .cornerRadius(UIConstants.cornerRadiusM)

            VStack(spacing: 4) {
                Text("\(viewModel.totalPRs)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.prGold)

                Text("Total PRs")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.backgroundSecondary)
            .cornerRadius(UIConstants.cornerRadiusM)
        }
        .padding(.horizontal)
    }

    private var recentPRsSection: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            Text("Recent PRs")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: UIConstants.spacingM) {
                    ForEach(viewModel.recentPRs, id: \.id) { pr in
                        RecentPRCard(pr: pr)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: UIConstants.spacingM) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)

            Text("No PRs yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Start logging workouts to track your progress")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Recent PR Card

struct RecentPRCard: View {
    let pr: PersonalRecord

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.spacingS) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(AppColors.prGold)
                    .font(.title3)

                Spacer()

                if let date = pr.dateAchieved {
                    Text(date.timeAgoShort)
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Text(pr.exercise?.name ?? "Unknown")
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            HStack {
                Text(pr.value.asWeight)
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if pr.reps > 0 {
                    Text("\(pr.reps) reps")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Text(PRType(rawValue: pr.recordType ?? "")?.displayName ?? pr.recordType ?? "")
                .font(.caption2)
                .foregroundColor(AppColors.textTertiary)
        }
        .padding()
        .frame(width: 160)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.prGold.opacity(0.2), AppColors.prGold.opacity(0.05)]),
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

// MARK: - Preview

struct PRsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PRsView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
