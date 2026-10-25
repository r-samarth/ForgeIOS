import SwiftUI

private struct WeekdayDatum: Identifiable {
    let weekday: Int
    let label: String
    let value: Double
    var id: Int { weekday }
}

struct AnalyticsView: View {
    @EnvironmentObject private var store: ForgeStore
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 12)

    private var totalCheckins: Int {
        store.data.logs.values.reduce(0) { $0 + $1.filter { id in store.data.habits.contains(where: { $0.id == id }) }.count }
    }
    private var perfectDays: Int {
        guard !store.data.habits.isEmpty else { return 0 }
        return (0..<365).map { ForgeDate.addingDays(-$0, to: store.effectiveToday) }.filter { store.completionCount(on: $0) == store.data.habits.count }.count
    }
    private var rate30Days: Int {
        guard !store.data.habits.isEmpty else { return 0 }
        let total = (0..<30).reduce(0) { $0 + store.completionCount(on: ForgeDate.addingDays(-$1, to: store.effectiveToday)) }
        return Int((Double(total) / Double(store.data.habits.count * 30) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 13) {
                ForgeSectionHeader(title: "Consistency Analytics", subtitle: "Your discipline, measured without judgement")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 9) {
                    ForgeMetricTile(title: "Total check-ins", value: "\(totalCheckins)", symbol: "checkmark.seal.fill")
                    ForgeMetricTile(title: "Perfect days", value: "\(perfectDays)", symbol: "sparkles")
                    ForgeMetricTile(title: "30-day rate", value: "\(rate30Days)%", symbol: "chart.line.uptrend.xyaxis")
                    ForgeMetricTile(title: "Longest streak", value: "\(store.bestStreakOverall())d", symbol: "flame.fill")
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 13) {
                ForgeSectionHeader(title: "12-Week Consistency Heatmap", subtitle: "Daily completion across all active habits")
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach((0..<84).reversed(), id: \.self) { offset in
                        let date = ForgeDate.addingDays(-offset, to: store.effectiveToday)
                        let progress = store.progress(on: date)
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(heatColor(progress))
                            .frame(height: 19)
                            .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(ForgeColors.sage.opacity(0.1), lineWidth: 0.5))
                            .help("\(ForgeDate.key(date)): \(Int(progress * 100))%")
                    }
                }
                HStack(spacing: 5) {
                    Text("Less").font(.system(size: 9, weight: .medium)).foregroundStyle(ForgeColors.muted)
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2).fill(heatColor(Double(level) / 4)).frame(width: 11, height: 11)
                    }
                    Text("More").font(.system(size: 9, weight: .medium)).foregroundStyle(ForgeColors.muted)
                    Spacer()
                    Text("84 days").font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(ForgeColors.sage)
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 14) {
                ForgeSectionHeader(title: "Habit Reliability Matrix", subtitle: "Current streak, personal best and 14-day rate")
                if store.data.habits.isEmpty {
                    ForgeEmptyState(title: "No habits to analyse", message: "Create your first habit to start building a useful consistency picture.")
                } else {
                    ForEach(store.data.habits) { habit in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 9) {
                                ForgeHabitGlyph(icon: habit.icon, size: 36)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name).font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint).lineLimit(1)
                                    Text("\(store.currentStreak(for: habit.id))d current · \(store.bestStreak(for: habit.id))d best")
                                        .font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(ForgeColors.muted)
                                }
                                Spacer()
                                Text("\(fourteenDayRate(for: habit.id))%")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(ForgeColors.mint)
                            }
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(ForgeColors.obsidian.opacity(0.8))
                                    Capsule().fill(LinearGradient(colors: [ForgeColors.mint, ForgeColors.sage], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geometry.size.width * CGFloat(fourteenDayRate(for: habit.id)) / 100)
                                }
                            }.frame(height: 6)
                        }
                    }
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 14) {
                ForgeSectionHeader(title: "Day-of-Week Profile", subtitle: "Average completion over the past 8 weeks")
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(weekdayData()) { item in
                        VStack(spacing: 7) {
                            Text("\(Int(item.value * 100))")
                                .font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(ForgeColors.sage)
                            GeometryReader { geometry in
                                VStack {
                                    Spacer(minLength: 0)
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(LinearGradient(colors: [ForgeColors.sage, ForgeColors.emerald], startPoint: .top, endPoint: .bottom))
                                        .frame(height: max(5, geometry.size.height * item.value))
                                }.frame(maxWidth: .infinity)
                            }.frame(height: 82)
                            Text(item.label).font(.system(size: 9, weight: .semibold, design: .rounded)).foregroundStyle(ForgeColors.muted)
                        }.frame(maxWidth: .infinity)
                    }
                }
            }.padding(15).forgeCard()
        }
    }

    private func heatColor(_ progress: Double) -> Color {
        guard progress > 0 else { return ForgeColors.obsidian.opacity(0.85) }
        if progress < 0.25 { return ForgeColors.glass }
        if progress < 0.5 { return ForgeColors.emerald }
        if progress < 0.85 { return ForgeColors.sage.opacity(0.85) }
        return ForgeColors.mint
    }

    private func fourteenDayRate(for habitID: String) -> Int {
        let done = (0..<14).filter { store.isCompleted(habitID, on: ForgeDate.addingDays(-$0, to: store.effectiveToday)) }.count
        return Int((Double(done) / 14 * 100).rounded())
    }

    private func weekdayData() -> [WeekdayDatum] {
        let labels = ["S", "M", "T", "W", "T", "F", "S"]
        return (1...7).map { weekday in
            let matching = (0..<56).map { ForgeDate.addingDays(-$0, to: store.effectiveToday) }.filter { ForgeDate.calendar.component(.weekday, from: $0) == weekday }
            let average = matching.isEmpty ? 0 : matching.map { store.progress(on: $0) }.reduce(0, +) / Double(matching.count)
            return WeekdayDatum(weekday: weekday, label: labels[weekday - 1], value: average)
        }
    }
}
