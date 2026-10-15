//
//  LocationManager.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Foundation
import CoreLocation
import Observation

/// Streams the user's location using the modern async CoreLocation API.
@Observable
final class LocationManager {
    private(set) var lastLocation: CLLocation?

    @ObservationIgnored private var session: CLServiceSession?
    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    func start() {
        guard updatesTask == nil else { return }
        // Holding a session asks for "When In Use" permission the first time.
        session = CLServiceSession(authorization: .whenInUse)
        updatesTask = Task { [weak self] in
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    guard let location = update.location else { continue }
                    // Ignore tiny movements to avoid needless view updates (saves battery).
                    if let last = self?.lastLocation, location.distance(from: last) < 25 { continue }
                    self?.lastLocation = location
                }
            } catch {
                // Location is optional in this app – the map just falls back to the default region.
            }
        }
    }

    func stop() {
        updatesTask?.cancel()
        updatesTask = nil
        session?.invalidate()
        session = nil
    }
}
