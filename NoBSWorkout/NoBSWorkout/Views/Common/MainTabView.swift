//
//  MainTabView.swift
//  NoBSWorkout
//
//  Main tab navigation container
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // History Tab
            NavigationView {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "calendar")
            }
            .tag(1)

            // PRs Tab
            NavigationView {
                PRsView()
            }
            .tabItem {
                Label("PRs", systemImage: "star.fill")
            }
            .tag(2)
        }
        .accentColor(AppColors.primary)
    }
}

// MARK: - Preview

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
