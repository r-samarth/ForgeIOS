# Forge for iOS

**Forge** is a native SwiftUI habit and discipline tracker inspired by the original Forge Liquid Glass prototype. It uses a dark botanical palette, translucent surfaces, a custom Forge app icon and a local-first data model.

## Features

- Create, edit and delete daily habits with an icon, routine, duration and habit-stacking anchor.
- Check in by date, browse a seven-day strip, and inspect earlier dates without losing history.
- View current/best habit streaks, a 12-week consistency heatmap, a 30-day rate, perfect-day count and weekday averages.
- Keep reflection notes alongside a monthly calendar and daily habit checklist.
- Run an in-app focus countdown for a selected habit, with pause, resume and complete controls.
- Test date rollover, return to the device clock, enable strict mode and adjust tactile feedback.
- Export/import a versioned JSON backup or clear history from the local vault.
- See a native iOS bottom tab bar and a custom 1024×1024 Forge icon.

## Storage and privacy

Forge stores data on the device using `UserDefaults` and JSON encoding. There is no login, analytics SDK, remote database or cloud sync configured. Export a backup before deleting the app or moving to another device; app-local data is not automatically transferred to another installation.

The countdown and focus timer are app UI features, not background push notifications. The focus timer recalculates from its deadline when Forge becomes active again. The simulator changes Forge's effective date for testing and can be reset from the Vault tab.

## Build with Xcode

1. Clone or download this repository on a Mac with Xcode 16 or later.
2. Open `ForgeIOS.xcodeproj`.
3. Select the **ForgeIOS** scheme and an iPhone simulator or connected iPhone.
4. For a physical iPhone, choose your Apple development team under **Signing & Capabilities** if Xcode requests it, then press **Run**.

The deployment target is iOS 17. The GitHub Actions workflow builds the project for the iOS Simulator without signing on every push and pull request to `main`.

## Project structure

- `ForgeIOS/ForgeIOSApp.swift` — app entry point and shared store.
- `ForgeIOS/ForgeStore.swift` — local persistence, date rollover, analytics calculations, backup and focus timer state.
- `ForgeIOS/TodayView.swift` — daily protocol, completion ring, week strip and habit cards.
- `ForgeIOS/AnalyticsView.swift` — consistency metrics and charts.
- `ForgeIOS/HistoryView.swift` — monthly calendar, date inspector and notes.
- `ForgeIOS/VaultView.swift` — local data settings, rollover tools and backup controls.
- `ForgeIOS/HabitEditorView.swift` — native habit create/edit sheet.
- `ForgeIOS/Assets.xcassets/AppIcon.appiconset` — Forge app icon.

## License

Add a license file before redistributing Forge under an open-source license.
