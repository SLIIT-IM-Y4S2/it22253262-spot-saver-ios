//
//  SpotPin.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Custom map pin that "drops" in when it appears and grows when selected.
//

import SwiftUI

struct SpotPin: View {
    let category: SpotCategory
    var isSelected = false

    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 36
    @State private var hasDropped = false

    var body: some View {
        VStack(spacing: -1) {
            Image(systemName: category.symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(category.color.gradient, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2.5))
            PinTail()
                .fill(category.color)
                .frame(width: size * 0.36, height: size * 0.26)
        }
        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        .scaleEffect(isSelected ? 1.3 : 1, anchor: .bottom)
        .offset(y: hasDropped ? 0 : -50)
        .opacity(hasDropped ? 1 : 0)
        .animation(.spring(response: 0.35, dampingFraction: 0.55), value: isSelected)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { hasDropped = true }
        }
        .accessibilityLabel("\(category.title) spot")
    }
}

/// Downward-pointing triangle under the pin head.
nonisolated struct PinTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        ForEach(SpotCategory.allCases) { SpotPin(category: $0, isSelected: $0 == .food) }
    }
    .padding()
}
