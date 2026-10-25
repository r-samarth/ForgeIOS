import Foundation
import SwiftUI
import UIKit

@MainActor
final class ForgeStore: ObservableObject {
    @Published private(set) var data: ForgeData
    @Published var selectedDate: Date
    @Published var toastMessage: String?
    @Published var focusRemainingSeconds: Int = 0
    @Published var focusHabitID: String?
    @Published var focusHabitName: String = ""
    @Published var focusDeadline: Date?
    @Published var focusIsPaused = false
    @Published var focusIsVisible = false

    private let storageKey = "forge_habit_engine_v1"

    init() {
        let restoredData: ForgeData
        if let stored = UserDefaults.standard.data(forKey: storageKey),
           let loaded = try? JSONDecoder.forge.decode(ForgeData.self, from: stored) {
            restoredData = loaded
        } else {
            restoredData = .fresh()
        }
        self.data = restoredData
        let todayWithOffset = ForgeDate.calendar.date(byAdding: .day, value: restoredData.simulatedDayOffset, to: Date()) ?? Date()
        self.selectedDate = ForgeDate.startOfDay(todayWithOffset)
        checkDayRollover()
        persist()
    }

    var effectiveToday: Date {
        ForgeDate.startOfDay(ForgeDate.calendar.date(byAdding: .day, value: data.simulatedDayOffset, to: Date()) ?? Date())
    }
    var todayKey: String { ForgeDate.key(effectiveToday) }
    var selectedKey: String { ForgeDate.key(selectedDate) }
    var storageSizeText: String {
        guard let bytes = try? JSONEncoder.forge.encode(data).count else { return "—" }
        return String(format: "%.1f KB", Double(bytes) / 1024)
    }
    var midnightCountdown: String { midnightCountdown(at: Date()) }

    /// Counts down to the next midnight in the iPhone's current local time zone.
    /// The supplied date is provided by TimelineView so this label updates every second.
    func midnightCountdown(at now: Date) -> String {
        let startOfToday = ForgeDate.calendar.startOfDay(for: now)
        let nextMidnight = ForgeDate.calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        let seconds = max(0, Int(ceil(nextMidnight.timeIntervalSince(now))))
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }

    func persist() {
        guard let encoded = try? JSONEncoder.forge.encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    func showToast(_ message: String) { toastMessage = message }
    func dismissToast() { toastMessage = nil }

    func checkDayRollover() {
        let currentKey = todayKey
        if data.lastActiveDateKey != currentKey {
            data.lastActiveDateKey = currentKey
            selectedDate = effectiveToday
            persist()
            showToast("A fresh day is ready to forge.")
        }
    }

    func selectDate(_ date: Date) { selectedDate = ForgeDate.startOfDay(date) }
    func lastSevenDays() -> [Date] { stride(from: 6, through: 0, by: -1).map { ForgeDate.addingDays(-$0, to: effectiveToday) } }

    func isCompleted(_ habitID: String, on date: Date) -> Bool {
        data.logs[ForgeDate.key(date), default: []].contains(habitID)
    }

    func toggleCompletion(_ habitID: String, on date: Date? = nil) {
        let key = ForgeDate.key(date ?? selectedDate)
        var completed = data.logs[key, default: []]
        let wasCompleted = completed.contains(habitID)
        if wasCompleted {
            completed.remove(habitID)
            showToast("Check-in removed")
        } else {
            completed.insert(habitID)
        }
        data.logs[key] = completed
        if data.settings.soundEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        if !wasCompleted {
            let habitName = data.habits.first(where: { $0.id == habitID })?.name ?? "Habit"
            showToast("\(habitName) forged · \(currentStreak(for: habitID)) day streak")
        }
        persist()
    }

    func completionCount(on date: Date) -> Int {
        let ids = data.logs[ForgeDate.key(date), default: []]
        return data.habits.filter { ids.contains($0.id) }.count
    }

    func progress(on date: Date) -> Double {
        guard !data.habits.isEmpty else { return 0 }
        return Double(completionCount(on: date)) / Double(data.habits.count)
    }

    func currentStreak(for habitID: String) -> Int {
        var cursor = effectiveToday
        if !isCompleted(habitID, on: cursor) { cursor = ForgeDate.addingDays(-1, to: cursor) }
        var streak = 0
        for _ in 0..<366 {
            if isCompleted(habitID, on: cursor) {
                streak += 1
                cursor = ForgeDate.addingDays(-1, to: cursor)
            } else { break }
        }
        return streak
    }

    func bestStreak(for habitID: String, days: Int = 365) -> Int {
        var best = 0
        var current = 0
        for offset in stride(from: days, through: 0, by: -1) {
            if isCompleted(habitID, on: ForgeDate.addingDays(-offset, to: effectiveToday)) {
                current += 1
                best = max(best, current)
            } else { current = 0 }
        }
        return max(best, currentStreak(for: habitID))
    }

    func bestStreakOverall() -> Int { data.habits.map { bestStreak(for: $0.id) }.max() ?? 0 }
    func bestDayStreakCount() -> Int {
        var best = 0
        for habit in data.habits { best = max(best, bestStreak(for: habit.id)) }
        return best
    }

    func dayNote(_ date: Date) -> String { data.notes[ForgeDate.key(date), default: ""] }
    func saveNote(_ note: String, for date: Date) {
        let key = ForgeDate.key(date)
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { data.notes.removeValue(forKey: key) }
        else { data.notes[key] = trimmed }
        persist()
        showToast("Reflection saved locally")
    }

    func saveHabit(_ habit: ForgeHabit) {
        if let index = data.habits.firstIndex(where: { $0.id == habit.id }) {
            data.habits[index] = habit
            showToast("Habit updated")
        } else {
            data.habits.append(habit)
            showToast("New daily habit forged")
        }
        persist()
    }

    func deleteHabit(_ habitID: String) {
        data.habits.removeAll { $0.id == habitID }
        for key in Array(data.logs.keys) {
            var checked = data.logs[key, default: []]
            checked.remove(habitID)
            data.logs[key] = checked
        }
        persist()
        showToast("Habit removed")
    }

    func toggleSound() { data.settings.soundEnabled.toggle(); persist() }
    func toggleStrictMode() { data.settings.strictMode.toggle(); persist() }
    func simulateMidnight() {
        data.simulatedDayOffset += 1
        data.lastActiveDateKey = todayKey
        selectedDate = effectiveToday
        persist()
        showToast("Midnight rollover simulated · fresh day ready")
    }
    func syncRealClock() {
        data.simulatedDayOffset = 0
        data.lastActiveDateKey = todayKey
        selectedDate = effectiveToday
        persist()
        showToast("Synced to your device clock")
    }
    func clearHistory() {
        data.logs = [:]
        data.notes = [:]
        data.simulatedDayOffset = 0
        data.lastActiveDateKey = todayKey
        selectedDate = effectiveToday
        persist()
        showToast("History cleared · ready for Day 1")
    }
    func restoreStarterHabits() {
        let fresh = ForgeData.fresh(today: effectiveToday)
        data.habits = fresh.habits
        data.logs = [:]
        data.notes = [:]
        data.settings = fresh.settings
        data.simulatedDayOffset = 0
        data.lastActiveDateKey = ForgeDate.key(Date())
        selectedDate = ForgeDate.startOfDay(Date())
        persist()
        showToast("Starter habits restored")
    }

    func exportBackup() -> Data? { try? JSONEncoder.forge.encode(ForgeBackup(data: data)) }
    func importBackup(_ bytes: Data) throws {
        let backup = try JSONDecoder.forge.decode(ForgeBackup.self, from: bytes)
        guard backup.formatVersion == 1 else { throw ForgeImportError.unsupportedVersion }
        data = backup.data
        data.lastActiveDateKey = todayKey
        selectedDate = effectiveToday
        persist()
        showToast("Forge backup restored")
    }

    func startFocus(for habit: ForgeHabit) {
        focusHabitID = habit.id
        focusHabitName = habit.name
        focusRemainingSeconds = max(60, habit.duration * 60)
        focusDeadline = Date().addingTimeInterval(TimeInterval(focusRemainingSeconds))
        focusIsPaused = false
        focusIsVisible = true
        showToast("Focus session started")
    }
    func toggleFocusPause() {
        guard focusIsVisible else { return }
        if focusIsPaused {
            focusDeadline = Date().addingTimeInterval(TimeInterval(focusRemainingSeconds))
            focusIsPaused = false
        } else {
            if let deadline = focusDeadline { focusRemainingSeconds = max(0, Int(deadline.timeIntervalSinceNow)) }
            focusDeadline = nil
            focusIsPaused = true
        }
    }
    func updateFocusClock() {
        checkDayRollover()
        guard focusIsVisible, !focusIsPaused, let deadline = focusDeadline else { return }
        focusRemainingSeconds = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
        if focusRemainingSeconds == 0 {
            focusIsPaused = true
            focusDeadline = nil
            showToast("Focus timer finished · great work")
        }
    }
    func completeFocusSession() {
        if let id = focusHabitID {
            let key = todayKey
            var completed = data.logs[key, default: []]
            completed.insert(id)
            data.logs[key] = completed
            persist()
        }
        stopFocus()
        showToast("Focus session completed")
    }
    func stopFocus() {
        focusIsVisible = false
        focusIsPaused = false
        focusDeadline = nil
        focusRemainingSeconds = 0
        focusHabitID = nil
    }
    var focusTimeText: String { String(format: "%02d:%02d", focusRemainingSeconds / 60, focusRemainingSeconds % 60) }
}

enum ForgeImportError: Error { case unsupportedVersion }

extension JSONEncoder {
    static var forge: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var forge: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
