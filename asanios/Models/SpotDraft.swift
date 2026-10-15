//
//  SpotDraft.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Foundation
import CoreLocation

/// Editable copy of a spot. The editor works on a draft so that
/// "Cancel" never leaves half-edited data in the database.
struct SpotDraft {
    static let maxNameLength = 60

    var name = ""
    var notes = ""
    var category: SpotCategory = .cafe
    var rating = 0
    var latitude: Double
    var longitude: Double
    var address = ""
    var isFavorite = false
    var photoData: Data?

    init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    init(spot: Spot) {
        name = spot.name
        notes = spot.notes
        category = spot.category
        rating = spot.rating
        latitude = spot.latitude
        longitude = spot.longitude
        address = spot.address
        isFavorite = spot.isFavorite
        photoData = spot.photoData
    }

    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }

    /// Used as a `.task(id:)` key – changes whenever the pin moves.
    var coordinateKey: String { "\(latitude),\(longitude)" }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var isValid: Bool {
        !trimmedName.isEmpty && trimmedName.count <= Self.maxNameLength
    }

    func makeSpot() -> Spot {
        Spot(
            name: trimmedName,
            category: category,
            coordinate: coordinate,
            rating: rating,
            notes: notes,
            address: address,
            isFavorite: isFavorite,
            photoData: photoData
        )
    }

    func apply(to spot: Spot) {
        spot.name = trimmedName
        spot.notes = notes
        spot.category = category
        spot.rating = min(max(rating, 0), 5)
        spot.latitude = latitude
        spot.longitude = longitude
        spot.address = address
        spot.isFavorite = isFavorite
        spot.photoData = photoData
    }
}
