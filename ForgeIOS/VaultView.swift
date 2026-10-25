import SwiftUI

struct VaultView: View {
    @EnvironmentObject private var store: ForgeStore
    let onExport: () -> Void
    let onImport: () -> Void
    @State private var showingClearAlert = false
    @State private var showingStarterAlert = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 11) {
                    Image(systemName: "lock.shield.fill").font(.system(size: 22, weight: .semibold)).foregroundStyle(ForgeColors.mint).frame(width: 48, height: 48).background(ForgeColors.obsidian.opacity(0.7), in: RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(ForgeColors.sage.opacity(0.3), lineWidth: 1))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("On-Device Local Vault").font(.headline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                        Text("No account. No cloud dependency.").font(.caption).foregroundStyle(ForgeColors.muted)
                    }
                    Spacer(minLength: 0)
                    Text("LOCAL").font(.system(size: 9, weight: .heavy, design: .rounded)).tracking(0.6).foregroundStyle(ForgeColors.obsidian).padding(.horizontal, 8).padding(.vertical, 5).background(ForgeColors.sage, in: Capsule())
                }
                HStack(spacing: 8) {
                    ForgeMetricTile(title: "Storage used", value: store.storageSizeText, symbol: "internaldrive.fill")
                    ForgeMetricTile(title: "Network calls", value: "0", symbol: "wifi.slash")
                    ForgeMetricTile(title: "Daily reset", value: "12 AM", symbol: "clock.fill")
                }
                Text("Forge stores habits, check-ins, settings and reflections in local app storage. Export a JSON backup before moving or removing the app.")
                    .font(.caption).foregroundStyle(ForgeColors.muted).fixedSize(horizontal: false, vertical: true)
            }.padding(15).forgeCard(emphasis: true)

            VStack(alignment: .leading, spacing: 9) {
                ForgeSectionHeader(title: "Discipline Engine", subtitle: "Personalise the way Forge feels")
                ForgeToggleRow(title: "Tactile feedback", detail: "Haptic confirmation when you forge a habit", symbol: "hand.tap.fill", isOn: Binding(get: { store.data.settings.soundEnabled }, set: { newValue in if newValue != store.data.settings.soundEnabled { store.toggleSound() } }))
                Rectangle().fill(ForgeColors.sage.opacity(0.14)).frame(height: 1)
                ForgeToggleRow(title: "Strict Forge mode", detail: "Disable streak shields and grace days", symbol: "flame.fill", isOn: Binding(get: { store.data.settings.strictMode }, set: { newValue in if newValue != store.data.settings.strictMode { store.toggleStrictMode() } }))
                if store.data.settings.strictMode {
                    Text("Strict mode is enabled. The current build tracks and displays streaks without applying grace-day protection.")
                        .font(.caption2).foregroundStyle(ForgeColors.sage).fixedSize(horizontal: false, vertical: true)
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 12) {
                ForgeSectionHeader(title: "Midnight Rollover", subtitle: "Daily check-ins use the device’s local calendar")
                HStack(spacing: 11) {
                    Image(systemName: "moon.stars.fill").font(.system(size: 20)).foregroundStyle(ForgeColors.sage).frame(width: 39, height: 39).background(ForgeColors.obsidian.opacity(0.65), in: RoundedRectangle(cornerRadius: 13))
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Next daily reset").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                        Text("\(store.midnightCountdown) remaining").font(.system(size: 11, weight: .medium, design: .monospaced)).foregroundStyle(ForgeColors.sage)
                    }
                    Spacer()
                }
                Text("When the date changes, Forge opens a fresh day while preserving earlier records. The simulator below lets you test next-day behaviour without waiting until midnight.")
                    .font(.caption).foregroundStyle(ForgeColors.muted).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Button { store.simulateMidnight() } label: { Label("Simulate +1 day", systemImage: "forward.end.fill") }.buttonStyle(ForgePrimaryButtonStyle())
                    Button { store.syncRealClock() } label: { Label("Sync real clock", systemImage: "arrow.clockwise") }.buttonStyle(ForgeOutlineButtonStyle())
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 12) {
                ForgeSectionHeader(title: "Backup & Portability", subtitle: "Your data belongs to you")
                HStack(spacing: 9) {
                    Button(action: onExport) { Label("Export JSON", systemImage: "square.and.arrow.up") }.buttonStyle(ForgePrimaryButtonStyle()).frame(maxWidth: .infinity)
                    Button(action: onImport) { Label("Import JSON", systemImage: "square.and.arrow.down") }.buttonStyle(ForgeOutlineButtonStyle()).frame(maxWidth: .infinity)
                }
                Text("The backup includes your habit definitions, check-in history, notes and settings. Keep a copy somewhere safe.")
                    .font(.caption).foregroundStyle(ForgeColors.muted).fixedSize(horizontal: false, vertical: true)
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 12) {
                ForgeSectionHeader(title: "Reset Controls", subtitle: "These actions change local app data")
                Button { showingClearAlert = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "trash").font(.system(size: 16, weight: .semibold)).foregroundStyle(.orange).frame(width: 37, height: 37).background(ForgeColors.obsidian, in: RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Clear check-in history").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                            Text("Delete all logs and reflection notes").font(.caption).foregroundStyle(ForgeColors.muted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(ForgeColors.sage)
                    }.padding(11).background(ForgeColors.obsidian.opacity(0.3), in: RoundedRectangle(cornerRadius: 17))
                }.buttonStyle(.plain)
                Button { showingStarterAlert = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise").font(.system(size: 16, weight: .semibold)).foregroundStyle(ForgeColors.sage).frame(width: 37, height: 37).background(ForgeColors.obsidian, in: RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Restore starter habits").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                            Text("Replace habits and clear current history").font(.caption).foregroundStyle(ForgeColors.muted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(ForgeColors.sage)
                    }.padding(11).background(ForgeColors.obsidian.opacity(0.3), in: RoundedRectangle(cornerRadius: 17))
                }.buttonStyle(.plain)
            }.padding(15).forgeCard()
        }
        .alert("Clear all check-in history?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear history", role: .destructive) { store.clearHistory() }
        } message: { Text("This permanently deletes every completion log and reflection note on this device. Your habit definitions will remain.") }
        .alert("Restore starter habits?", isPresented: $showingStarterAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) { store.restoreStarterHabits() }
        } message: { Text("This replaces your current habit list with the five starter habits and clears saved history. Export a backup first if you need it.") }
    }
}
