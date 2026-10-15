//
//  MapScreen.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Home screen. Long-press the map to drop a new spot,
//  tap a pin to preview it, "Surprise me" picks a forgotten spot.
//

import SwiftUI
import SwiftData
import MapKit

struct MapScreen: View {
    @Query(sort: \Spot.createdAt, order: .reverse) private var spots: [Spot]
    @Environment(LocationManager.self) private var locationManager

    @State private var position: MapCameraPosition = .userLocation(fallback: .region(.sliitMalabe))
    @State private var selection: Spot?
    @State private var categoryFilter: SpotCategory?
    @State private var visibleCenter: CLLocationCoordinate2D?
    @State private var newSpot: NewSpotRequest?
    @State private var surpriseTrigger = 0

    private var visibleSpots: [Spot] {
        SpotFilter(category: categoryFilter).apply(to: spots)
    }

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position, selection: $selection) {
                    UserAnnotation()
                    ForEach(visibleSpots) { spot in
                        Annotation(spot.name, coordinate: spot.coordinate, anchor: .bottom) {
                            SpotPin(category: spot.category, isSelected: selection == spot)
                        }
                        .tag(spot)
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleCenter = context.region.center
                }
                .simultaneousGesture(dropPinGesture(proxy: proxy))
                .accessibilityIdentifier("spotMap")
            }
            .safeAreaInset(edge: .top) {
                CategoryChipBar(selection: $categoryFilter)
                    .padding(.vertical, 8)
            }
            .safeAreaInset(edge: .bottom) {
                if let selection {
                    SpotSummaryCard(spot: selection) { self.selection = nil }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selection)
            .navigationTitle("Spot Saver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Surprise Me", systemImage: "dice.fill", action: surpriseMe)
                        .disabled(spots.isEmpty)
                        .symbolEffect(.bounce, value: surpriseTrigger)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Spot", systemImage: "plus") {
                        let center = visibleCenter
                            ?? locationManager.lastLocation?.coordinate
                            ?? MKCoordinateRegion.sliitMalabe.center
                        newSpot = NewSpotRequest(coordinate: center)
                    }
                }
            }
            .navigationDestination(for: Spot.self) { SpotDetailView(spot: $0) }
            .sheet(item: $newSpot) { request in
                NavigationStack { SpotEditorView(mode: .create(request.coordinate)) }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: newSpot?.id)
        }
    }

    /// Long-press then lift to drop a pin at that point on the map.
    private func dropPinGesture(proxy: MapProxy) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .onEnded { value in
                guard case .second(true, let drag?) = value,
                      let coordinate = proxy.convert(drag.location, from: .local) else { return }
                newSpot = NewSpotRequest(coordinate: coordinate)
            }
    }

    private func surpriseMe() {
        guard let pick = SpotFilter.surprise(from: visibleSpots.isEmpty ? spots : visibleSpots) else { return }
        surpriseTrigger += 1
        withAnimation(.easeInOut(duration: 1.0)) {
            position = .region(MKCoordinateRegion(center: pick.coordinate, latitudinalMeters: 800, longitudinalMeters: 800))
            selection = pick
        }
    }
}

/// Floating card shown when a pin is selected.
struct SpotSummaryCard: View {
    let spot: Spot
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(value: spot) {
                HStack(spacing: 14) {
                    CategoryBadge(category: spot.category)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.name).font(.headline).foregroundStyle(.primary)
                        if !spot.address.isEmpty {
                            Text(spot.address).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                        }
                        StarRatingView(rating: spot.rating)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityIdentifier("summaryCard")

            Button("Close", systemImage: "xmark.circle.fill", action: onClose)
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

#Preview {
    MapScreen()
        .environment(LocationManager())
        .modelContainer(for: Spot.self, inMemory: true)
}
