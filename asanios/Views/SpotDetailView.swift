//
//  SpotDetailView.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Adaptive layout: stacked on iPhone portrait, side-by-side on
//  iPad / landscape (regular width).
//

import SwiftUI
import SwiftData
import MapKit

struct SpotDetailView: View {
    @Bindable var spot: Spot
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            Group {
                if sizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        media.frame(maxWidth: .infinity)
                        info.frame(maxWidth: .infinity)
                    }
                } else {
                    VStack(spacing: 20) {
                        media
                        info
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(spot.isFavorite ? "Unfavourite" : "Favourite",
                       systemImage: spot.isFavorite ? "heart.fill" : "heart") {
                    withAnimation(.spring) { spot.isFavorite.toggle() }
                }
                .tint(.pink)
                .symbolEffect(.bounce, value: spot.isFavorite)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button("Edit", systemImage: "pencil") { isEditing = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { isConfirmingDelete = true }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack { SpotEditorView(mode: .edit(spot)) }
        }
        .confirmationDialog("Delete \(spot.name)?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Spot", role: .destructive) {
                context.delete(spot)
                dismiss()
            }
        }
        .sensoryFeedback(.success, trigger: spot.visitCount)
    }

    // MARK: - Sections

    private var media: some View {
        VStack(spacing: 16) {
            if let data = spot.photoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .accessibilityLabel("Photo of \(spot.name)")
            }
            Map(initialPosition: .region(MKCoordinateRegion(center: spot.coordinate,
                                                           latitudinalMeters: 600, longitudinalMeters: 600)),
                interactionModes: []) {
                Marker(spot.name, systemImage: spot.category.symbol, coordinate: spot.coordinate)
                    .tint(spot.category.color)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .accessibilityHidden(true)
        }
    }

    private var info: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    CategoryBadge(category: spot.category)
                    VStack(alignment: .leading) {
                        Text(spot.name).font(.title2.bold())
                        Text(spot.category.title).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                StarRatingView(rating: $spot.rating)
                if !spot.address.isEmpty {
                    Label(spot.address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                }
                Label(visitSummary, systemImage: "clock.arrow.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()

            if !spot.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.headline)
                    Text(spot.notes).font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }

            ViewThatFits {
                HStack(spacing: 12) { actionButtons }
                VStack(spacing: 12) { actionButtons }
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        Button {
            MapServices.openDirections(to: spot)
        } label: {
            Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

        Button {
            withAnimation { spot.markVisited() }
        } label: {
            Label("I'm Here", systemImage: "checkmark.seal.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .accessibilityHint("Records a visit to this spot today")
    }

    private var visitSummary: String {
        guard let last = spot.lastVisited else { return "Not visited yet" }
        let times = spot.visitCount == 1 ? "1 visit" : "\(spot.visitCount) visits"
        return "\(times) · last \(last.formatted(.relative(presentation: .named)))"
    }
}
