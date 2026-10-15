# Spot Saver – SE4041 MADD Assignment 02, Part A

**Student:** Asan M A M · **ID:** IT22253262

A personal map of the places you love: cafés, study spots, food and parking.
Save a spot with a long-press on the map, rate it, add notes and a photo, and get directions later.

## Build & run
1. Open `asanios.xcodeproj` in Xcode 26+ (macOS).
2. Select an iPhone simulator (iOS 26.5+) and press **Run** (⌘R).
3. In the simulator, choose **Features → Location → Custom Location** (e.g. 6.9147, 79.9729) to test "Nearest" sorting.
4. On first launch, open **Spots → Load Sample Spots** for demo data.
5. Tests: **Product → Test** (⌘U).

## Requirements map
| Brief requirement | Where |
|---|---|
| ≥3 screens, NavigationStack | `Views/` – Map, Spot list, Detail, Editor (each tab has a `NavigationStack`) |
| Data persistence | SwiftData `@Model Spot` (`Models/Spot.swift`), photos in external storage |
| Emerging tech | MapKit (annotations, `MapReader` long-press drop, reverse geocoding, directions) + CoreLocation async updates |
| Custom component / modifier | `StarRatingView`, `SpotPin`, `CategoryChipBar`, `CardStyle` modifier, `PressableButtonStyle` |
| Animations, gestures | pin drop & selection springs, matched-geometry chips, long-press, drag-to-rate, swipe actions, haptics |
| Adaptive layout | `.sidebarAdaptable` tabs, size-class split in `SpotDetailView`, `ViewThatFits` buttons, all orientations |
| Dark Mode, Dynamic Type, accessibility | system colours, light/dark AccentColor, `@ScaledMetric`, VoiceOver labels & adjustable rating |
| Performance | photo downscaling, external storage, throttled location updates |
| Testing | `asaniosTests` (Swift Testing: filter, sort, surprise, model, draft) · `asaniosUITests` (add, search, visit, launch metric) |

## Structure
```
asanios/
  SpotSaverApp.swift     app entry, ModelContainer
  Models/                Spot, SpotCategory, SpotDraft
  Logic/                 SpotFilter (search/sort/surprise), SampleData
  Services/              LocationManager, MapServices (geocoding, directions, image resize)
  Theme/                 colours, CardStyle modifier, button style
  Components/            StarRatingView, SpotPin, CategoryChipBar, SpotRow
  Views/                 RootView, MapScreen, SpotListScreen, SpotDetailView, SpotEditorView
```

## TODO
- [ ] Custom app icon (1024×1024) in `Assets.xcassets/AppIcon`
- [ ] User guide, technical documentation and report in `docs/`
- [ ] UAT with 3–5 students; record results
