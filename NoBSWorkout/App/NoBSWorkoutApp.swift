//
//  NoBSWorkoutApp.swift
//  NoBSWorkout
//
//  Main app entry point
//

import SwiftUI

@main
struct NoBSWorkoutApp: App {

    // Initialize persistence controller
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
