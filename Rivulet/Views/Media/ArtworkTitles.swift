// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2025-2026 Bain Gurley

//
//  ArtworkTitles.swift
//  Rivulet
//
//  Settings > Appearance > Titles Over Artwork. Off is for libraries whose
//  backdrops already carry the title (fanart.tv art with the logo baked in):
//  no clear logo, and no title text in its place, is drawn over a backdrop.
//  Readers: the Continue Watching card, the Home hero, the detail chrome,
//  the player's pause screen and the Top Shelf composite.
//

import Combine
import Foundation

enum ArtworkTitles {
    static let key = "showTitlesOverArtwork"

    static var shown: Bool { SettingsStore.bool(key, default: true) }

    /// Calls `handler` on the main queue with the new value each time the setting flips.
    static func observe(_ handler: @escaping (Bool) -> Void) -> AnyCancellable {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .map { _ in shown }
            .prepend(shown)
            .removeDuplicates()
            .dropFirst()
            .sink(receiveValue: handler)
    }
}
