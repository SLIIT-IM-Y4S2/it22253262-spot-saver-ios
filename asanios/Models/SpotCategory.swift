//
//  SpotCategory.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

enum SpotCategory: String, CaseIterable, Identifiable {
    case cafe, study, food, parking, other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cafe: "Café"
        case .study: "Study"
        case .food: "Food"
        case .parking: "Parking"
        case .other: "Other"
        }
    }

    /// SF Symbol shown on pins, chips and rows.
    var symbol: String {
        switch self {
        case .cafe: "cup.and.saucer.fill"
        case .study: "book.fill"
        case .food: "fork.knife"
        case .parking: "parkingsign"
        case .other: "star.fill"
        }
    }

    /// System colours adapt automatically to Dark Mode.
    var color: Color {
        switch self {
        case .cafe: .brown
        case .study: .indigo
        case .food: .orange
        case .parking: .blue
        case .other: .pink
        }
    }
}
