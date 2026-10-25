import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: ForgeStore
    @State private var monthOffset = 0
    @State private var noteDraft = ""
    private let weekdayColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var displayedMonth: Date {
        let first = ForgeDate.calendar.date(from: ForgeDate.calendar.dateComponents([.year, .month], from: store.effectiveToday)) ?? store.effectiveToday
        return ForgeDate.calendar.date(byAdding: .month, value: monthOffset, to: first) ?? first
    }
    private var monthDays: [Date?] {
        guard let range = ForgeDate.calendar.range(of: .day, in: .month, for: displayedMonth),
              let first = ForgeDate.calendar.date(from: ForgeDate.calendar.dateComponents([.year, .month], from: displayedMonth)) else { return [] }
        let weekday = ForgeDate.calendar.component(.weekday, from: first)
        return Array(repeating: nil, count: weekday - 1) + range.compactMap { day in
            ForgeDate.calendar.date(byAdding: .day, value: day - 1, to: first)
        }.map(Optional.some)
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(displayedMonth.formatted(.dateTime.month(.wide).year())).font(.headline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                        Text("Tap any date to review or edit a record").font(.caption).foregroundStyle(ForgeColors.muted)
                    }
                    Spacer()
                    Button { monthOffset -= 1 } label: { Image(systemName: "chevron.left").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint).frame(width: 33, height: 33).background(ForgeColors.glass, in: RoundedRectangle(cornerRadius: 11)) }
                    Button { monthOffset = 0; store.selectDate(store.effectiveToday) } label: { Text("Today").font(.caption.weight(.bold)).foregroundStyle(ForgeColors.mint).padding(.horizontal, 8).frame(height: 33).background(ForgeColors.glass, in: RoundedRectangle(cornerRadius: 11)) }
                    Button { monthOffset += 1 } label: { Image(systemName: "chevron.right").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint).frame(width: 33, height: 33).background(ForgeColors.glass, in: RoundedRectangle(cornerRadius: 11)) }
                }
                LazyVGrid(columns: weekdayColumns, spacing: 8) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"].indices, id: \.self) { index in
                        Text(["S", "M", "T", "W", "T", "F", "S"][index]).font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(ForgeColors.sage).frame(maxWidth: .infinity)
                    }
                }
                LazyVGrid(columns: weekdayColumns, spacing: 6) {
                    ForEach(monthDays.indices, id: \.self) { index in
                        if let date = monthDays[index] {
                            let selected = ForgeDate.calendar.isDate(date, inSameDayAs: store.selectedDate)
                            let hasData = store.completionCount(on: date) > 0 || !store.dayNote(date).isEmpty
                            Button { store.selectDate(date) } label: {
                                VStack(spacing: 4) {
                                    Text(date.formatted(.dateTime.day())).font(.system(size: 12, weight: selected ? .heavy : .medium, design: .rounded)).foregroundStyle(selected ? ForgeColors.obsidian : ForgeColors.mint)
                                    Circle().fill(hasData ? ForgeColors.sage : .clear).frame(width: 4, height: 4)
                                }
                                .frame(maxWidth: .infinity).frame(height: 40)
                                .background(selected ? ForgeColors.mint : ForgeColors.obsidian.opacity(0.33), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 11).strokeBorder(selected ? ForgeColors.mint : ForgeColors.sage.opacity(0.1), lineWidth: 1))
                            }.buttonStyle(.plain)
                        } else {
                            Color.clear.frame(height: 40)
                        }
                    }
                }
            }.padding(15).forgeCard()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("DATE INSPECTOR").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
                        Text(ForgeDate.human(store.selectedDate, today: store.effectiveToday)).font(.headline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                    }
                    Spacer()
                    Text("\(store.completionCount(on: store.selectedDate)) / \(store.data.habits.count)").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(ForgeColors.mint).padding(.horizontal, 10).padding(.vertical, 7).background(ForgeColors.emerald, in: Capsule())
                }
                if store.data.habits.isEmpty {
                    Text("Add habits on the Today tab to build a daily audit log.").font(.subheadline).foregroundStyle(ForgeColors.muted)
                } else {
                    ForEach(store.data.habits) { habit in
                        let completed = store.isCompleted(habit.id, on: store.selectedDate)
                        Button { store.toggleCompletion(habit.id, on: store.selectedDate) } label: {
                            HStack(spacing: 10) {
                                ForgeHabitGlyph(icon: habit.icon, size: 34)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name).font(.subheadline.weight(.semibold)).foregroundStyle(ForgeColors.mint).lineLimit(2)
                                    Text(habit.routine.rawValue).font(.caption2).foregroundStyle(ForgeColors.muted)
                                }
                                Spacer()
                                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22, weight: .medium)).foregroundStyle(completed ? ForgeColors.mint : ForgeColors.sage.opacity(0.7))
                            }.padding(.vertical, 3)
                        }.buttonStyle(.plain)
                    }
                }
                Rectangle().fill(ForgeColors.sage.opacity(0.16)).frame(height: 1).padding(.vertical, 3)
                VStack(alignment: .leading, spacing: 7) {
                    Text("DAILY DISCIPLINE & FRICTION NOTE").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(0.6).foregroundStyle(ForgeColors.sage)
                    TextField("What went well or caused friction?", text: $noteDraft, axis: .vertical)
                        .font(.subheadline).foregroundStyle(ForgeColors.mint).lineLimit(2...5)
                        .padding(12).background(ForgeColors.obsidian.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(ForgeColors.emerald, lineWidth: 1))
                    HStack {
                        Text("Saved only on this device").font(.caption2).foregroundStyle(ForgeColors.muted)
                        Spacer()
                        Button { store.saveNote(noteDraft, for: store.selectedDate) } label: { Label("Save note", systemImage: "square.and.arrow.down").font(.caption.weight(.bold)) }.buttonStyle(ForgePrimaryButtonStyle())
                    }
                }
            }.padding(15).forgeCard()
        }
        .onAppear { noteDraft = store.dayNote(store.selectedDate) }
        .onChange(of: store.selectedKey) { _, _ in noteDraft = store.dayNote(store.selectedDate) }
    }
}
