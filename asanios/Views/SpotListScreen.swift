//
//  SpotListScreen.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI
import SwiftData
import MapKit

struct SpotListScreen: View {
    @Query private var spots: [Spot]
    @Environment(\.modelContext) private var context
    @Environment(LocationManager.self) private var locationManager

    @State private var filter = SpotFilter()
    @State private var newSpot: NewSpotRequest?

    var body: some View {
        NavigationStack {
            let results = filter.apply(to: spots, from: locationManager.lastLocation)

            List {
                ForEach(results) { spot in
                    NavigationLink(value: spot) {
                        SpotRow(spot: spot, origin: locationManager.lastLocation)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            withAnimation { context.delete(spot) }
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button(spot.isFavorite ? "Unfavourite" : "Favourite",
                               systemImage: spot.isFavorite ? "heart.slash" : "heart") {
                            withAnimation { spot.isFavorite.toggle() }
                        }
                        .tint(.pink)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .animation(.default, value: results.map(\.persistentModelID))
            .overlay { emptyState(hasResults: !results.isEmpty) }
            .safeAreaInset(edge: .top) {
                CategoryChipBar(selection: $filter.category)
                    .padding(.vertical, 8)
                    .background(.bar)
            }
            .searchable(text: $filter.searchText, prompt: "Search name, notes or address")
            .navigationTitle("My Spots")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { sortMenu }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Spot", systemImage: "plus") {
                        let coordinate = locationManager.lastLocation?.coordinate ?? MKCoordinateRegion.sliitMalabe.center
                        newSpot = NewSpotRequest(coordinate: coordinate)
                    }
                    .accessibilityIdentifier("addSpotButton")
                }
            }
            .navigationDestination(for: Spot.self) { SpotDetailView(spot: $0) }
            .sheet(item: $newSpot) { request in
                NavigationStack { SpotEditorView(mode: .create(request.coordinate)) }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $filter.sort) {
                ForEach(SpotSort.allCases) { Text($0.title).tag($0) }
            }
            Toggle("Favourites Only", systemImage: "heart", isOn: $filter.favoritesOnly)
        } label: {
            Label("Sort and Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    @ViewBuilder
    private func emptyState(hasResults: Bool) -> some View {
        if spots.isEmpty {
            ContentUnavailableView {
                Label("No Spots Yet", systemImage: "mappin.slash")
            } description: {
                Text("Long-press the map or tap + to save your first spot.")
            } actions: {
                Button("Load Sample Spots") {
                    withAnimation { SampleData.makeSpots().forEach(context.insert) }
                }
                .buttonStyle(.borderedProminent)
            }
        } else if !hasResults {
            ContentUnavailableView.search(text: filter.searchText)
        }
    }
}

#Preview {
    SpotListScreen()
        .environment(LocationManager())
        .modelContainer(for: Spot.self, inMemory: true)
}
