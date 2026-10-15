//
//  RootView.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI
import CoreLocation

/// Two tabs, each with its own NavigationStack. On iPad the tab bar
/// adapts into a sidebar automatically (`.sidebarAdaptable`).
struct RootView: View {
    @Environment(LocationManager.self) private var locationManager

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map.fill") {
                MapScreen()
            }
            Tab("Spots", systemImage: "list.bullet") {
                SpotListScreen()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .task {
            // Skip the permission prompt during UI tests.
            if !AppEnvironment.isUITesting { locationManager.start() }
        }
    }
}

/// Wraps a coordinate so it can drive `.sheet(item:)`.
struct NewSpotRequest: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
