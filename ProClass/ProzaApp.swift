//
//  ProzaApp.swift
//  Proza
//
//  Created by Alluri santosh Varma on 2/10/25.
//

import SwiftUI
import SwiftData

@main
struct ProClassApp: App {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if !hasSeenWelcome {
                WelcomeScreen(hasSeenWelcome: $hasSeenWelcome)
            } else {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
