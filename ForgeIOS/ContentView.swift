import SwiftUI
import UniformTypeIdentifiers
import Combine

struct ContentView: View {
    @EnvironmentObject private var store: ForgeStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: ForgeTab = .today
    @State private var editingHabit: ForgeHabit?
    @State private var showingHabitEditor = false
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var backupDocument = ForgeBackupDocument(data: Data())
    @State private var showingImportError = false
    @State private var importErrorText = "The selected file could not be restored."

    private let secondPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForgeBackground()
            VStack(spacing: 0) {
                header
                if store.focusIsVisible { focusDrawer }
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        tabContent
                        Text("built by Sam  ·  local-first by design")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .tracking(0.45)
                            .foregroundStyle(ForgeColors.sage.opacity(0.65))
                            .padding(.top, 5)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                bottomBar
            }
        }
        .tint(ForgeColors.sage)
        .sheet(isPresented: $showingHabitEditor) {
            HabitEditorView(habit: editingHabit) { habit in
                store.saveHabit(habit)
            } onDelete: { id in
                store.deleteHabit(id)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fileExporter(isPresented: $showExporter, document: backupDocument, contentType: .json, defaultFilename: "forge-backup-\(store.todayKey)") { result in
            switch result {
            case .success: store.showToast("Backup exported successfully")
            case .failure(let error): store.showToast("Export failed: \(error.localizedDescription)")
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
            do {
                guard let url = try result.get().first else { return }
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                try store.importBackup(Data(contentsOf: url))
            } catch {
                importErrorText = error.localizedDescription
                showingImportError = true
            }
        }
        .alert("Couldn’t restore backup", isPresented: $showingImportError) {
            Button("OK", role: .cancel) { }
        } message: { Text(importErrorText) }
        .overlay(alignment: .top) {
            if let message = store.toastMessage {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ForgeColors.mint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(ForgeColors.sage.opacity(0.35), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 16, y: 6)
                    .padding(.top, 9)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { withAnimation { store.dismissToast() } }
                    .task(id: message) {
                        try? await Task.sleep(for: .seconds(2.8))
                        withAnimation { store.dismissToast() }
                    }
            }
        }
        .onReceive(secondPublisher) { _ in store.updateFocusClock() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.checkDayRollover(); store.updateFocusClock() }
        }
    }

    @ViewBuilder private var tabContent: some View {
        switch selectedTab {
        case .today:
            TodayView(onAddHabit: beginNewHabit, onEditHabit: editHabit, onStartFocus: store.startFocus)
        case .analytics:
            AnalyticsView()
        case .history:
            HistoryView()
        case .vault:
            VaultView(onExport: exportBackup, onImport: { showImporter = true })
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(LinearGradient(colors: [ForgeColors.emerald, ForgeColors.glass], startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(ForgeColors.mint.opacity(0.28), lineWidth: 1)
                    Image("ForgeMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 42, height: 42)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }.frame(width: 42, height: 42)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("Forge").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundStyle(ForgeColors.mint)
                        Text("built by Sam").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(ForgeColors.mint).padding(.horizontal, 7).padding(.vertical, 4).background(ForgeColors.glass, in: Capsule()).overlay(Capsule().strokeBorder(ForgeColors.sage.opacity(0.38), lineWidth: 1))
                    }
                    Text("DAILY DISCIPLINE ARCHITECTURE").font(.system(size: 8.5, weight: .semibold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
                }
                Spacer(minLength: 2)
                VStack(alignment: .trailing, spacing: 4) {
                    Label("12 AM RESET", systemImage: "clock").font(.system(size: 8, weight: .bold, design: .rounded)).tracking(0.55).foregroundStyle(ForgeColors.sage)
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        Text(store.midnightCountdown(at: context.date))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(ForgeColors.mint)
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(ForgeColors.glass.opacity(0.65), in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(ForgeColors.sage.opacity(0.18), lineWidth: 1))
            }
            .padding(.horizontal, 17).padding(.top, 10).padding(.bottom, 13)
            Rectangle().fill(ForgeColors.sage.opacity(0.15)).frame(height: 1)
        }
        .background(ForgeColors.elevated.opacity(0.66))
    }

    private var focusDrawer: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(ForgeColors.sage.opacity(0.28), lineWidth: 2)
                Image(systemName: "timer").font(.system(size: 15, weight: .semibold)).foregroundStyle(ForgeColors.sage)
            }.frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text("ACTIVE FOCUS FORGE").font(.system(size: 8, weight: .bold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
                Text(store.focusHabitName).font(.caption.weight(.semibold)).foregroundStyle(ForgeColors.mint).lineLimit(1)
            }
            Spacer(minLength: 3)
            Text(store.focusTimeText).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundStyle(ForgeColors.mint).monospacedDigit()
            Button { store.toggleFocusPause() } label: {
                Image(systemName: store.focusIsPaused ? "play.fill" : "pause.fill").font(.caption.weight(.bold)).foregroundStyle(ForgeColors.mint).frame(width: 29, height: 29).background(ForgeColors.emerald, in: Circle())
            }
            Button { store.completeFocusSession() } label: {
                Image(systemName: "checkmark").font(.caption.weight(.heavy)).foregroundStyle(ForgeColors.obsidian).frame(width: 29, height: 29).background(ForgeColors.mint, in: Circle())
            }
            Button { store.stopFocus() } label: { Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(ForgeColors.sage).padding(5) }
        }
        .padding(10).background(ForgeColors.glass.opacity(0.85), in: RoundedRectangle(cornerRadius: 18)).overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(ForgeColors.sage.opacity(0.28), lineWidth: 1))
        .padding(.horizontal, 16).padding(.top, 8)
    }

    private var bottomBar: some View {
        HStack(spacing: 5) {
            ForEach(ForgeTab.allCases) { tab in
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { selectedTab = tab } } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol).font(.system(size: 18, weight: .semibold))
                        Text(tab.rawValue).font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium, design: .rounded))
                    }
                    .foregroundStyle(selectedTab == tab ? ForgeColors.mint : ForgeColors.sage)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background {
                        if selectedTab == tab { RoundedRectangle(cornerRadius: 17, style: .continuous).fill(ForgeColors.emerald.opacity(0.78)).overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(ForgeColors.sage.opacity(0.17), lineWidth: 1)) }
                    }
                }.buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(ForgeColors.sage.opacity(0.27), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 7)
        .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 6)
        .background(LinearGradient(colors: [.clear, ForgeColors.obsidian.opacity(0.9)], startPoint: .top, endPoint: .bottom))
    }

    private func beginNewHabit() { editingHabit = nil; showingHabitEditor = true }
    private func editHabit(_ habit: ForgeHabit) { editingHabit = habit; showingHabitEditor = true }
    private func exportBackup() {
        guard let bytes = store.exportBackup() else { store.showToast("Could not create backup"); return }
        backupDocument = ForgeBackupDocument(data: bytes)
        showExporter = true
    }
}

struct ForgeBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}
