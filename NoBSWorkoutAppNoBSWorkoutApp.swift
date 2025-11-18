//
//  NoBSWorkoutApp.swift
//  NoBSWorkout
//
//  Created on 11/18/2025.
//

import SwiftUI

@main
struct NoBSWorkoutApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
