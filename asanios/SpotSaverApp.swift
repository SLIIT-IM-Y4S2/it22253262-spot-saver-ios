//
//  SpotSaverApp.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//  SE4041 MADD – Assignment 02, Part A
//

import SwiftUI
import SwiftData

@main
struct SpotSaverApp: App {
    @State private var locationManager = LocationManager()
    private let container: ModelContainer

    init() {
        // UI tests launch with an empty, in-memory store so every run starts clean.
        let config = ModelConfiguration(isStoredInMemoryOnly: AppEnvironment.isUITesting)
        do {
            container = try ModelContainer(for: Spot.self, configurations: config)
        } catch {
            fatalError("Could not create the Spot Saver data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(locationManager)
        }
        .modelContainer(container)
    }
}

enum AppEnvironment {
    static let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
}
