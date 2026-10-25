import Foundation
import SwiftUI

struct ForgeHabit: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var routine: HabitRoutine
    var duration: Int
    var anchor: String
    var icon: HabitIcon
    var createdAt: Date = Date()
}

enum HabitRoutine: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case deepWork = "Deep Work"
    case evening = "Evening"
    case allDay = "All Day"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .deepWork: return "brain.head.profile"
        case .evening: return "moon.stars.fill"
        case .allDay: return "circle.dotted"
        }
    }
}

enum HabitIcon: String, Codable, CaseIterable, Identifiable {
    case bolt, code, dumbbell, book, droplet, leaf, brain, moon, figureRun

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .bolt: return "bolt.fill"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .dumbbell: return "dumbbell.fill"
        case .book: return "book.closed.fill"
        case .droplet: return "drop.fill"
        case .leaf: return "leaf.fill"
        case .brain: return "brain.head.profile"
        case .moon: return "moon.fill"
        case .figureRun: return "figure.run"
        }
    }
    var label: String {
        switch self {
        case .bolt: return "Energy"
        case .code: return "Code"
        case .dumbbell: return "Strength"
        case .book: return "Reading"
        case .droplet: return "Hydration"
        case .leaf: return "Nutrition"
        case .brain: return "Focus"
        case .moon: return "Sleep"
        case .figureRun: return "Movement"
        }
    }
}

struct ForgeSettings: Codable, Equatable {
    var soundEnabled = true
    var strictMode = false
    var streakShields = 2
}

struct ForgeData: Codable {
    var habits: [ForgeHabit] = []
    var logs: [String: Set<String>] = [:]
    var notes: [String: String] = [:]
    var settings = ForgeSettings()
    var simulatedDayOffset = 0
    var lastActiveDateKey: String = ""

    static func fresh(today: Date = Date()) -> ForgeData {
        let key = ForgeDate.key(today)
        return ForgeData(
            habits: [
                ForgeHabit(name: "Morning Hydration & Mobility", routine: .morning, duration: 15, anchor: "Immediately after waking up", icon: .droplet),
                ForgeHabit(name: "Algorithmic Problem Solving", routine: .deepWork, duration: 45, anchor: "Before opening messages or feeds", icon: .code),
                ForgeHabit(name: "Strength & Conditioning", routine: .evening, duration: 45, anchor: "At 6:00 PM sharp", icon: .dumbbell),
                ForgeHabit(name: "Deep Technical Reading", routine: .evening, duration: 25, anchor: "After dinner with your phone away", icon: .book),
                ForgeHabit(name: "Clean Fuel & Nutrition", routine: .allDay, duration: 10, anchor: "At every meal decision", icon: .leaf)
            ],
            logs: [:],
            notes: [:],
            settings: ForgeSettings(),
            simulatedDayOffset: 0,
            lastActiveDateKey: key
        )
    }
}

struct ForgeBackup: Codable {
    var formatVersion = 1
    var exportedAt = Date()
    var data: ForgeData
}

enum ForgeDate {
    // Always follow the device's current calendar and time zone, including updates
    // made in iOS Settings while Forge is installed.
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
        calendar.timeZone = .autoupdatingCurrent
        return calendar
    }

    static func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }

    static func key(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    static func date(from key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    static func addingDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(date)) ?? date
    }

    static func short(_ date: Date) -> String { date.formatted(.dateTime.weekday(.abbreviated)) }
    static func monthDay(_ date: Date) -> String { date.formatted(.dateTime.month(.abbreviated).day()) }
    static func human(_ date: Date, today: Date) -> String {
        if calendar.isDate(date, inSameDayAs: today) { return "Today · " + date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()) }
        if calendar.isDate(date, inSameDayAs: addingDays(-1, to: today)) { return "Yesterday · " + date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()) }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }
}

enum ForgeTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case analytics = "Analytics"
    case history = "History"
    case vault = "Vault"

    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .today: return "checkmark.circle.fill"
        case .analytics: return "chart.bar.fill"
        case .history: return "calendar"
        case .vault: return "shield.lefthalf.filled"
        }
    }
}
