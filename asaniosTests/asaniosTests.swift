//
//  asaniosTests.swift
//  Spot Saver – unit tests
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Testing
import Foundation
import CoreLocation
import SwiftData
@testable import asanios

@MainActor
struct SpotFilterTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let day: TimeInterval = 86_400

    private func spot(_ name: String, _ category: SpotCategory = .cafe, rating: Int = 0,
                      lat: Double = 6.9147, lon: Double = 79.9729, notes: String = "",
                      favorite: Bool = false, ageDays: Double = 0, visitedDaysAgo: Double? = nil) -> Spot {
        Spot(name: name, category: category, coordinate: .init(latitude: lat, longitude: lon),
             rating: rating, notes: notes, isFavorite: favorite,
             createdAt: now - ageDays * day,
             lastVisited: visitedDaysAgo.map { now - $0 * day })
    }

    @Test func searchMatchesNameAndNotesCaseInsensitively() {
        let spots = [spot("Campus Café"), spot("Library", notes: "quiet COFFEE corner"), spot("Parking")]
        let result = SpotFilter(searchText: "coffee").apply(to: spots)
        #expect(result.map(\.name) == ["Library"])
        #expect(SpotFilter(searchText: "campus").apply(to: spots).count == 1)
    }

    @Test func blankSearchReturnsEverything() {
        let spots = [spot("A"), spot("B")]
        #expect(SpotFilter(searchText: "   ").apply(to: spots).count == 2)
    }

    @Test func filtersByCategoryAndFavourites() {
        let spots = [spot("A", .food, favorite: true), spot("B", .food), spot("C", .study, favorite: true)]
        #expect(SpotFilter(category: .food).apply(to: spots).count == 2)
        #expect(SpotFilter(category: .food, favoritesOnly: true).apply(to: spots).map(\.name) == ["A"])
    }

    @Test func sortsByRatingThenNewest() {
        let spots = [spot("Low", rating: 2), spot("OldTop", rating: 5, ageDays: 3), spot("NewTop", rating: 5)]
        let result = SpotFilter(sort: .rating).apply(to: spots)
        #expect(result.map(\.name) == ["NewTop", "OldTop", "Low"])
    }

    @Test func sortsByNameUsingNaturalOrder() {
        let spots = [spot("Spot 10"), spot("spot 2"), spot("Apple")]
        #expect(SpotFilter(sort: .name).apply(to: spots).map(\.name) == ["Apple", "spot 2", "Spot 10"])
    }

    @Test func sortsByDistanceFromOrigin() {
        let origin = CLLocation(latitude: 6.9147, longitude: 79.9729)
        let spots = [spot("Far", lat: 7.0), spot("Near", lat: 6.915), spot("Mid", lat: 6.95)]
        let result = SpotFilter(sort: .distance).apply(to: spots, from: origin)
        #expect(result.map(\.name) == ["Near", "Mid", "Far"])
    }

    @Test func distanceSortWithoutLocationFallsBackToNewest() {
        let spots = [spot("Old", ageDays: 5), spot("New")]
        #expect(SpotFilter(sort: .distance).apply(to: spots, from: nil).map(\.name) == ["New", "Old"])
    }

    @Test func surprisePrefersSpotsNotVisitedRecently() {
        let spots = [spot("Yesterday", visitedDaysAgo: 1), spot("Never"), spot("LongAgo", visitedDaysAgo: 30)]
        let names = Set(SpotFilter.surpriseCandidates(from: spots, now: now).map(\.name))
        #expect(names == ["Never", "LongAgo"])
    }

    @Test func surpriseFallsBackToAllWhenEverythingIsRecent() {
        let spots = [spot("A", visitedDaysAgo: 1), spot("B", visitedDaysAgo: 2)]
        #expect(SpotFilter.surpriseCandidates(from: spots, now: now).count == 2)
        #expect(SpotFilter.surprise(from: [], now: now) == nil)
    }
}

@MainActor
struct SpotModelTests {
    @Test func ratingIsClampedAndCategoryRoundTrips() {
        let spot = Spot(name: "X", category: .parking, coordinate: .init(latitude: 0, longitude: 0), rating: 9)
        #expect(spot.rating == 5)
        #expect(spot.category == .parking)
        spot.categoryRaw = "unknown-future-value"
        #expect(spot.category == .other)
    }

    @Test func markVisitedUpdatesCountAndDate() {
        let spot = Spot(name: "X", category: .cafe, coordinate: .init(latitude: 0, longitude: 0))
        let date = Date(timeIntervalSince1970: 1_000)
        spot.markVisited(on: date)
        spot.markVisited(on: date)
        #expect(spot.visitCount == 2)
        #expect(spot.lastVisited == date)
    }

    @Test func spotPersistsInSwiftData() throws {
        let container = try ModelContainer(for: Spot.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        SampleData.makeSpots().forEach(context.insert)
        try context.save()
        let fetched = try context.fetch(FetchDescriptor<Spot>(sortBy: [SortDescriptor(\.name)]))
        #expect(fetched.count == 4)
        #expect(fetched.first?.name == "Campus Café")
    }
}

@MainActor
struct SpotDraftTests {
    private let coordinate = CLLocationCoordinate2D(latitude: 6.9, longitude: 79.9)

    @Test func requiresNonBlankNameWithinLimit() {
        var draft = SpotDraft(coordinate: coordinate)
        #expect(!draft.isValid)
        draft.name = "   "
        #expect(!draft.isValid)
        draft.name = "  Library  "
        #expect(draft.isValid)
        #expect(draft.makeSpot().name == "Library")
        draft.name = String(repeating: "a", count: SpotDraft.maxNameLength + 1)
        #expect(!draft.isValid)
    }

    @Test func applyCopiesEditsOntoExistingSpot() {
        let spot = Spot(name: "Old", category: .cafe, coordinate: coordinate)
        var draft = SpotDraft(spot: spot)
        draft.name = "New"
        draft.category = .study
        draft.rating = 4
        draft.apply(to: spot)
        #expect(spot.name == "New")
        #expect(spot.category == .study)
        #expect(spot.rating == 4)
    }
}
