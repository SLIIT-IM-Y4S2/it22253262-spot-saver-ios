//
//  SpotRow.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI
import CoreLocation

/// Category badge reused by rows, cards and the detail screen.
struct CategoryBadge: View {
    let category: SpotCategory
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 44

    var body: some View {
        Image(systemName: category.symbol)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(category.color.gradient, in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct SpotRow: View {
    let spot: Spot
    var origin: CLLocation?

    var body: some View {
        HStack(spacing: 14) {
            CategoryBadge(category: spot.category)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(spot.name).font(.headline).lineLimit(1)
                    if spot.isFavorite {
                        Image(systemName: "heart.fill").font(.caption).foregroundStyle(.pink)
                            .accessibilityLabel("Favourite")
                    }
                }
                if !spot.address.isEmpty {
                    Text(spot.address).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
                HStack(spacing: 8) {
                    StarRatingView(rating: spot.rating)
                    if let distance = MapServices.formattedDistance(from: origin, to: spot) {
                        Text(distance).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
