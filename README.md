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
- Use the native iOS interface and custom Forge app icon.

## Install Forge on your iPhone

> **Important:** Forge is currently distributed as source code. This repository does **not** currently include an App Store download, TestFlight invitation or ready-to-install signed IPA. To install this development build on an iPhone today, you need a Mac with Xcode. A normal iPhone user cannot install it just by opening this GitHub page on their phone.

### What you need

- A Mac that can run **Xcode 16 or later**.
- An Apple Account added to Xcode. A paid Apple Developer Program membership is not usually needed for basic personal development testing.
- An iPhone running **iOS 17 or later**.
- A USB cable to connect the iPhone to your Mac (wireless running can be configured after pairing).

### Step 1 — Download the project

Choose **one** of these methods:

**Option A: Download ZIP**
1. Open the [ForgeIOS repository](https://github.com/r-samarth/ForgeIOS).
2. Click **Code → Download ZIP**.
3. Extract the ZIP on your Mac.
4. Open the extracted `ForgeIOS` folder.

**Option B: Clone with Git**
Open Terminal and run:

```bash
git clone https://github.com/r-samarth/ForgeIOS.git
cd ForgeIOS
```

### Step 2 — Open the Xcode project

1. Open `ForgeIOS.xcodeproj` from the project folder.
2. Wait for Xcode to finish loading and indexing the files.
3. In the project navigator, select the blue **ForgeIOS** project icon.
4. Under **Targets**, select **ForgeIOS**.

### Step 3 — Set up signing

iOS requires an app installed directly from Xcode to be code-signed.

1. In Xcode, open **Xcode → Settings → Accounts** and sign in with your Apple Account if you have not already.
2. Select the **ForgeIOS** target, then open **Signing & Capabilities**.
3. Enable **Automatically manage signing**.
4. Choose your own **Team** (for a personal setup, this may be listed as **Personal Team**).
5. If Xcode reports that the bundle identifier is unavailable, change `dev.samarth.forgeios` to a unique identifier you control, such as `com.yourname.forge`.

Xcode manages the development signing assets for the selected team. For Apple's official instructions, see [Run an app on a device](https://help.apple.com/xcode/mac/current/en.lproj/dev5a825a1ca.html).

### Step 4 — Connect and prepare your iPhone

1. Connect the iPhone to the Mac and unlock the iPhone.
2. If prompted, tap **Trust This Computer** on the iPhone and enter your passcode.
3. In Xcode's top toolbar, open the run-destination menu and select your physical iPhone, not a simulator.
4. If Xcode asks you to enable **Developer Mode**, open **Settings → Privacy & Security → Developer Mode** on the iPhone, turn it on, restart if prompted, then confirm **Turn On** after restarting. This option appears after the device has been paired for development. See Apple's [Developer Mode guide](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device).

### Step 5 — Build and install

1. Select the **ForgeIOS** scheme and your connected iPhone in Xcode's toolbar.
2. Click the **Run ▶** button or press **Command + R**.
3. Wait for Xcode to build the app and install it on the iPhone.
4. Once launch completes, Forge should open on the device. The app creates its starter habits on first launch.

If the build fails, open Xcode's Issue navigator (**View → Navigators → Issues**, or **Command + 5**) and read the first red error. A GitHub Actions Simulator build passing does not guarantee that the local project's signing settings are correct for every developer's Apple Account.

### Can I install it directly from GitHub on my iPhone?

**Not yet.** The GitHub repository contains the source project, not a public App Store or TestFlight release. Running from Xcode is the current developer-install method. For simpler installation by people who do not own a Mac, Forge would need to be distributed through TestFlight or the App Store, or another appropriately signed distribution route. Do not download an IPA from an unknown source.

## Build in the iOS Simulator

1. Open `ForgeIOS.xcodeproj` on a Mac with Xcode 16 or later.
2. Select the **ForgeIOS** scheme.
3. Select an iPhone simulator as the run destination.
4. Press **Command + R**.

The deployment target is iOS 17. The GitHub Actions workflow builds the project for the iOS Simulator without signing on pushes and pull requests to `main`.

## Storage, privacy and daily reset

Forge stores habits, check-ins, settings and reflections on the device using `UserDefaults` and JSON encoding. There is no login, analytics SDK, remote database or cloud sync configured. **Data does not automatically sync between devices.** Export a JSON backup from the Vault before deleting the app or moving to another installation.

The midnight countdown uses the iPhone's current local clock and time zone, refreshes every second while the app is visible, and counts down to the next local midnight. When Forge launches or becomes active again, it checks the device date and switches to the new day if needed. Completion marks are associated with local calendar dates, so yesterday's marks remain in history rather than appearing completed today.

The focus timer is an in-app feature, not a background push notification. It recalculates from its deadline when Forge becomes active again. The Vault's **Simulate +1 day** control is for testing only; tap **Sync real clock** to return to the device's real date.

## Project structure

- `ForgeIOS/ForgeIOSApp.swift` — app entry point and shared store.
- `ForgeIOS/ForgeStore.swift` — local persistence, date rollover, analytics calculations, backup and focus timer state.
- `ForgeIOS/TodayView.swift` — daily protocol, completion ring, week strip and habit cards.
- `ForgeIOS/AnalyticsView.swift` — consistency metrics and charts.
- `ForgeIOS/HistoryView.swift` — monthly calendar, date inspector and notes.
- `ForgeIOS/VaultView.swift` — local data settings, rollover tools and backup controls.
- `ForgeIOS/HabitEditorView.swift` — native habit create/edit sheet.
- `ForgeIOS/Assets.xcassets/AppIcon.appiconset` — Forge app icon.
- `ForgeIOS/Assets.xcassets/ForgeMark.imageset` — Forge brand mark used in the app header.
- `branding/ForgeLogo.svg` — editable vector brand mark.

## License

Add a license file before redistributing Forge under an open-source license.
