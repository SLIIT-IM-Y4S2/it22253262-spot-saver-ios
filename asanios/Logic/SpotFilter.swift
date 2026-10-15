//
//  SpotFilter.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Pure filtering/sorting logic kept out of the views so it can be unit tested.
//

import Foundation
import CoreLocation

enum SpotSort: String, CaseIterable, Identifiable {
    case newest, rating, name, distance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newest: "Newest"
        case .rating: "Top Rated"
        case .name: "Name"
        case .distance: "Nearest"
        }
    }
}

struct SpotFilter {
    var searchText = ""
    var category: SpotCategory?
    var favoritesOnly = false
    var sort: SpotSort = .newest

    func apply(to spots: [Spot], from origin: CLLocation? = nil) -> [Spot] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let filtered = spots.filter { spot in
            (category == nil || spot.category == category)
                && (!favoritesOnly || spot.isFavorite)
                && (query.isEmpty
                    || spot.name.localizedStandardContains(query)
                    || spot.notes.localizedStandardContains(query)
                    || spot.address.localizedStandardContains(query))
        }

        switch sort {
        case .newest:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .rating:
            return filtered.sorted { ($0.rating, $0.createdAt) > ($1.rating, $1.createdAt) }
        case .name:
            return filtered.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .distance:
            // Without a location we can't sort by distance, so fall back to newest.
            guard let origin else { return filtered.sorted { $0.createdAt > $1.createdAt } }
            return filtered.sorted { $0.location.distance(from: origin) < $1.location.distance(from: origin) }
        }
    }

    // MARK: - Surprise me

    /// Spots not visited within this many days are preferred by "Surprise me".
    static let staleAfterDays = 14

    /// Spots worth rediscovering: never visited, or not visited recently.
    /// Falls back to every spot when all have been visited recently.
    static func surpriseCandidates(from spots: [Spot], now: Date = .now) -> [Spot] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -staleAfterDays, to: now) ?? now
        let stale = spots.filter { ($0.lastVisited ?? .distantPast) < cutoff }
        return stale.isEmpty ? spots : stale
    }

    static func surprise(from spots: [Spot], now: Date = .now) -> Spot? {
        surpriseCandidates(from: spots, now: now).randomElement()
    }
}
