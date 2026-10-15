//
//  Theme.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Shared look & feel: brand colours (AccentColor asset, light + dark),
//  the custom `cardStyle()` modifier and a pressable button style.
//

import SwiftUI

enum Theme {
    static let cornerRadius: CGFloat = 18
    static let brand = Color.accentColor

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [brand, brand.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// Custom modifier: rounded, elevated card that adapts to Dark Mode.
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        modifier(CardStyle(padding: padding))
    }
}

/// Buttons shrink slightly while pressed, giving tactile feedback.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
