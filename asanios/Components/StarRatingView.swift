//
//  StarRatingView.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Custom component: tap or drag across the stars to rate.
//  Supports Dynamic Type and VoiceOver (swipe up/down to adjust).
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var maximum = 5
    var isInteractive = true

    @ScaledMetric(relativeTo: .title3) private var starSize: CGFloat = 26
    private let spacing: CGFloat = 6

    /// Read-only stars, e.g. in list rows.
    init(rating: Int, maximum: Int = 5) {
        _rating = .constant(rating)
        self.maximum = maximum
        isInteractive = false
    }

    init(rating: Binding<Int>, maximum: Int = 5) {
        _rating = rating
        self.maximum = maximum
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maximum, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: isInteractive ? starSize : starSize * 0.55))
                    .foregroundStyle(index <= rating ? Color.yellow : Color.secondary.opacity(0.5))
                    .symbolEffect(.bounce, value: index <= rating)
                    .onTapGesture {
                        guard isInteractive else { return }
                        // Tapping the current top star clears it.
                        setRating(rating == index ? index - 1 : index)
                    }
            }
        }
        .contentShape(Rectangle())
        .gesture(scrubGesture, isEnabled: isInteractive)
        .sensoryFeedback(.selection, trigger: rating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maximum) stars")
        .accessibilityAdjustableAction { direction in
            guard isInteractive else { return }
            switch direction {
            case .increment: setRating(rating + 1)
            case .decrement: setRating(rating - 1)
            @unknown default: break
            }
        }
        .accessibilityIdentifier("starRating")
    }

    /// Drag horizontally across the stars to pick a rating.
    private var scrubGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let index = Int(value.location.x / (starSize + spacing)) + 1
                setRating(index)
            }
    }

    private func setRating(_ value: Int) {
        let clamped = min(max(value, 0), maximum)
        guard clamped != rating else { return }
        withAnimation(.snappy) { rating = clamped }
    }
}

#Preview {
    @Previewable @State var rating = 3
    StarRatingView(rating: $rating).padding()
}
