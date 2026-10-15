//
//  CategoryChipBar.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Horizontal filter chips. The highlight slides between chips
//  using matchedGeometryEffect.
//

import SwiftUI

struct CategoryChipBar: View {
    @Binding var selection: SpotCategory?
    @Namespace private var highlight

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", symbol: "square.grid.2x2.fill", color: Theme.brand, value: nil)
                ForEach(SpotCategory.allCases) { category in
                    chip(title: category.title, symbol: category.symbol, color: category.color, value: category)
                }
            }
            .padding(.horizontal)
        }
        .scrollClipDisabled()
    }

    private func chip(title: String, symbol: String, color: Color, value: SpotCategory?) -> some View {
        let isSelected = selection == value
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { selection = value }
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background {
                    if isSelected {
                        Capsule().fill(color.gradient).matchedGeometryEffect(id: "chip", in: highlight)
                    } else {
                        Capsule().fill(.regularMaterial)
                    }
                }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("chip-\(value?.rawValue ?? "all")")
    }
}

#Preview {
    @Previewable @State var selection: SpotCategory?
    CategoryChipBar(selection: $selection)
}
