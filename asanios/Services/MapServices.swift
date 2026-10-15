//
//  MapServices.swift
//  Spot Saver
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import MapKit
import UIKit

enum MapServices {
    /// Turns a coordinate into a readable address (reverse geocoding).
    static func address(for coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else { return nil }
        do {
            let item = try await request.mapItems.first
            return item?.address?.shortAddress ?? item?.address?.fullAddress ?? item?.name
        } catch {
            return nil
        }
    }

    /// Opens Apple Maps with directions to the spot.
    static func openDirections(to spot: Spot) {
        let item = MKMapItem(location: spot.location, address: nil)
        item.name = spot.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }

    static func formattedDistance(from origin: CLLocation?, to spot: Spot) -> String? {
        guard let origin else { return nil }
        let meters = spot.location.distance(from: origin)
        return Measurement(value: meters, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}

enum ImageResizer {
    /// Shrinks picked photos before saving – full camera images can be 10+ MB.
    static func downscaled(_ data: Data, maxDimension: CGFloat = 1_024) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = image.preparingThumbnail(of: size) ?? image
        return resized.jpegData(compressionQuality: 0.8)
    }
}
