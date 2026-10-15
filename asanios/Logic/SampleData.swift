//
//  SampleData.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    /// Default camera when the user's location is unknown: SLIIT Malabe campus.
    static let sliitMalabe = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.9729),
        latitudinalMeters: 3_000,
        longitudinalMeters: 3_000
    )
}

enum SampleData {
    /// A few demo spots around Malabe for first launch and the live demo.
    static func makeSpots(now: Date = .now) -> [Spot] {
        let day: TimeInterval = 86_400
        return [
            Spot(name: "SLIIT Library", category: .study,
                 coordinate: .init(latitude: 6.9149, longitude: 79.9727), rating: 5,
                 notes: "Quiet floor upstairs. Plugs near the windows.",
                 address: "SLIIT, New Kandy Rd, Malabe", isFavorite: true,
                 createdAt: now - day * 10, lastVisited: now - day, visitCount: 12),
            Spot(name: "Campus Café", category: .cafe,
                 coordinate: .init(latitude: 6.9139, longitude: 79.9736), rating: 4,
                 notes: "Good iced coffee, busy at lunch.",
                 address: "Malabe", createdAt: now - day * 8, lastVisited: now - day * 20, visitCount: 3),
            Spot(name: "Rice & Curry Corner", category: .food,
                 coordinate: .init(latitude: 6.9081, longitude: 79.9693), rating: 4,
                 notes: "Cheap lunch packets.",
                 address: "Kaduwela Rd, Malabe", createdAt: now - day * 5),
            Spot(name: "Free Parking Lane", category: .parking,
                 coordinate: .init(latitude: 6.9171, longitude: 79.9758), rating: 3,
                 notes: "Fills up after 8:30 am.",
                 address: "Malabe", createdAt: now - day * 2),
        ]
    }
}
