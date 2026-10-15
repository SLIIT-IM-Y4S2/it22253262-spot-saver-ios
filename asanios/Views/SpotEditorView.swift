//
//  SpotEditorView.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Create or edit a spot. Tap the mini map to move the pin;
//  the address is looked up automatically (reverse geocoding).
//

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct SpotEditorView: View {
    enum Mode {
        case create(CLLocationCoordinate2D)
        case edit(Spot)
    }

    let mode: Mode

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var draft: SpotDraft
    @State private var photoItem: PhotosPickerItem?
    @State private var needsAddressLookup: Bool
    @State private var isLookingUpAddress = false

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create(let coordinate):
            _draft = State(initialValue: SpotDraft(coordinate: coordinate))
            _needsAddressLookup = State(initialValue: true)
        case .edit(let spot):
            _draft = State(initialValue: SpotDraft(spot: spot))
            _needsAddressLookup = State(initialValue: spot.address.isEmpty)
        }
    }

    private var isNew: Bool {
        if case .create = mode { return true }
        return false
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $draft.name)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("nameField")
                Picker("Category", selection: $draft.category) {
                    ForEach(SpotCategory.allCases) { category in
                        Label(category.title, systemImage: category.symbol).tag(category)
                    }
                }
                Toggle("Favourite", systemImage: "heart", isOn: $draft.isFavorite)
            } footer: {
                if draft.trimmedName.count > SpotDraft.maxNameLength {
                    Text("Name must be \(SpotDraft.maxNameLength) characters or fewer.")
                        .foregroundStyle(.red)
                }
            }

            Section("Rating") {
                StarRatingView(rating: $draft.rating)
                    .frame(maxWidth: .infinity)
            }

            Section {
                locationPicker
                HStack {
                    Image(systemName: "mappin.and.ellipse").foregroundStyle(.secondary)
                    if isLookingUpAddress {
                        ProgressView().controlSize(.small)
                        Text("Finding address…").foregroundStyle(.secondary)
                    } else {
                        TextField("Address", text: $draft.address)
                    }
                }
            } header: {
                Text("Location")
            } footer: {
                Text("Tap the map to move the pin.")
            }

            Section("Photo") {
                if let data = draft.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .listRowInsets(EdgeInsets())
                    Button("Remove Photo", systemImage: "trash", role: .destructive) {
                        withAnimation { draft.photoData = nil; photoItem = nil }
                    }
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label(draft.photoData == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                }
            }

            Section("Notes") {
                TextField("What makes this spot great?", text: $draft.notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle(isNew ? "New Spot" : "Edit Spot")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(!draft.isValid)
                    .accessibilityIdentifier("saveButton")
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    draft.photoData = ImageResizer.downscaled(data)
                }
            }
        }
        .task(id: draft.coordinateKey) {
            await lookUpAddressIfNeeded()
        }
    }

    private var locationPicker: some View {
        MapReader { proxy in
            Map(initialPosition: .region(MKCoordinateRegion(center: draft.coordinate,
                                                           latitudinalMeters: 500, longitudinalMeters: 500))) {
                Marker(draft.trimmedName.isEmpty ? "New Spot" : draft.trimmedName,
                       systemImage: draft.category.symbol,
                       coordinate: draft.coordinate)
                    .tint(draft.category.color)
            }
            .onTapGesture { point in
                guard let coordinate = proxy.convert(point, from: .local) else { return }
                withAnimation { draft.coordinate = coordinate }
                needsAddressLookup = true
            }
        }
        .frame(height: 180)
        .listRowInsets(EdgeInsets())
        .accessibilityLabel("Spot location map")
    }

    private func lookUpAddressIfNeeded() async {
        guard needsAddressLookup else { return }
        isLookingUpAddress = true
        defer { isLookingUpAddress = false }
        if let address = await MapServices.address(for: draft.coordinate) {
            draft.address = address
        }
        needsAddressLookup = false
    }

    private func save() {
        switch mode {
        case .create:
            context.insert(draft.makeSpot())
        case .edit(let spot):
            draft.apply(to: spot)
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        SpotEditorView(mode: .create(MKCoordinateRegion.sliitMalabe.center))
    }
    .modelContainer(for: Spot.self, inMemory: true)
}
