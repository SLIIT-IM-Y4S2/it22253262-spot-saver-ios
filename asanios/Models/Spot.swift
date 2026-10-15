//
//  Spot.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Foundation
import SwiftData
import CoreLocation

/// A place the user has saved, persisted with SwiftData.
@Model
final class Spot {
    var name: String
    var notes: String
    /// Stored as a raw string so new categories never break existing data.
    var categoryRaw: String
    /// 0–5 stars.
    var rating: Int
    var latitude: Double
    var longitude: Double
    var address: String
    var isFavorite: Bool
    var createdAt: Date
    var lastVisited: Date?
    var visitCount: Int

    /// Photos are kept outside the main database file to keep queries fast.
    @Attribute(.externalStorage) var photoData: Data?

    init(
        name: String,
        category: SpotCategory,
        coordinate: CLLocationCoordinate2D,
        rating: Int = 0,
        notes: String = "",
        address: String = "",
        isFavorite: Bool = false,
        photoData: Data? = nil,
        createdAt: Date = .now,
        lastVisited: Date? = nil,
        visitCount: Int = 0
    ) {
        self.name = name
        self.categoryRaw = category.rawValue
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.rating = min(max(rating, 0), 5)
        self.notes = notes
        self.address = address
        self.isFavorite = isFavorite
        self.photoData = photoData
        self.createdAt = createdAt
        self.lastVisited = lastVisited
        self.visitCount = visitCount
    }

    var category: SpotCategory {
        get { SpotCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func markVisited(on date: Date = .now) {
        lastVisited = date
        visitCount += 1
    }
}
