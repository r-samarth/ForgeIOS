import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: ForgeStore
    let onAddHabit: () -> Void
    let onEditHabit: (ForgeHabit) -> Void
    let onStartFocus: (ForgeHabit) -> Void
    @State private var activeFilter = "All Habits"

    private var filteredHabits: [ForgeHabit] {
        let habits = store.data.habits
        if activeFilter == "All Habits" { return habits }
        return habits.filter { $0.routine.rawValue == activeFilter }
    }
    private var doneCount: Int { store.completionCount(on: store.selectedDate) }
    private var topStreak: Int { store.bestDayStreakCount() }

    var body: some View {
        VStack(spacing: 16) {
            heroCard
            weekStrip
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(["All Habits"] + HabitRoutine.allCases.map(\.rawValue), id: \.self) { filter in
                            Button { withAnimation(.easeInOut(duration: 0.2)) { activeFilter = filter } } label: {
                                Text(filter).font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(activeFilter == filter ? ForgeColors.obsidian : ForgeColors.sage)
                                    .padding(.horizontal, 12).padding(.vertical, 8)
                                    .background(activeFilter == filter ? ForgeColors.mint : ForgeColors.glass.opacity(0.63), in: Capsule())
                                    .overlay(Capsule().strokeBorder(ForgeColors.sage.opacity(activeFilter == filter ? 0 : 0.18), lineWidth: 1))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                Button(action: onAddHabit) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .heavy)).foregroundStyle(ForgeColors.obsidian).frame(width: 33, height: 33).background(LinearGradient(colors: [ForgeColors.mint, ForgeColors.sage], startPoint: .topLeading, endPoint: .bottomTrailing), in: Circle())
                }.accessibilityLabel("Add habit")
            }

            VStack(spacing: 10) {
                HStack {
                    ForgeSectionHeader(title: "Your Protocol", subtitle: ForgeDate.human(store.selectedDate, today: store.effectiveToday), trailing: "\(doneCount)/\(store.data.habits.count)")
                }
                if filteredHabits.isEmpty {
                    ForgeEmptyState(title: "Nothing in this block", message: "Add a habit or switch to another routine to keep your momentum going.")
                } else {
                    ForEach(filteredHabits) { habit in
                        habitCard(habit)
                    }
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled").font(.system(size: 18)).foregroundStyle(ForgeColors.sage).frame(width: 40, height: 40).background(ForgeColors.emerald.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 3) {
                    Text("Midnight reset is armed").font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                    Text("Each new day starts fresh. Your logs and streak history stay on this device.").font(.caption).foregroundStyle(ForgeColors.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(13).forgeCard()
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(ForgeColors.mint).frame(width: 6, height: 6)
                        Text(store.selectedKey == store.todayKey ? "TODAY’S FORGE PROTOCOL" : "DATE INSPECTOR")
                            .font(.system(size: 9, weight: .bold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
                    }
                    Text("\(doneCount) of \(store.data.habits.count) Forged")
                        .font(.system(size: 24, weight: .heavy, design: .rounded)).foregroundStyle(ForgeColors.mint).minimumScaleFactor(0.78).lineLimit(1)
                    Text(doneCount == store.data.habits.count && !store.data.habits.isEmpty ? "Protocol complete. Consistency compounds." : "Every check-in compounds your identity.")
                        .font(.caption).foregroundStyle(ForgeColors.muted).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                ForgeProgressRing(progress: store.progress(on: store.selectedDate), size: 100)
            }
            HStack(spacing: 8) {
                ForgeMetricTile(title: "Best streak", value: "\(topStreak)d", symbol: "flame.fill")
                ForgeMetricTile(title: "Momentum", value: "\(Int(store.progress(on: store.selectedDate) * 100))%", symbol: "chart.line.uptrend.xyaxis")
                ForgeMetricTile(title: "Mode", value: store.data.settings.strictMode ? "STRICT" : "FLEX", symbol: "shield.fill")
            }
        }
        .padding(16).forgeCard(emphasis: true)
    }

    private var weekStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("7-DAY CONSISTENCY").font(.system(size: 9, weight: .bold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
                Spacer()
                if store.selectedKey != store.todayKey {
                    Button("Return to today") { store.selectDate(store.effectiveToday) }
                        .font(.system(size: 10, weight: .bold, design: .rounded)).foregroundStyle(ForgeColors.mint)
                }
            }
            HStack(spacing: 6) {
                ForEach(store.lastSevenDays(), id: \.self) { date in
                    let chosen = ForgeDate.calendar.isDate(date, inSameDayAs: store.selectedDate)
                    let ratio = store.progress(on: date)
                    Button { store.selectDate(date) } label: {
                        VStack(spacing: 7) {
                            Text(ForgeDate.short(date).uppercased()).font(.system(size: 8, weight: .bold, design: .rounded)).foregroundStyle(chosen ? ForgeColors.obsidian : ForgeColors.sage)
                            Text(date.formatted(.dateTime.day())).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundStyle(chosen ? ForgeColors.obsidian : ForgeColors.mint)
                            Circle().fill(ratio >= 1 && !store.data.habits.isEmpty ? ForgeColors.mint : (ratio > 0 ? ForgeColors.sage : ForgeColors.emerald.opacity(0.9))).frame(width: 5, height: 5)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 9)
                        .background(chosen ? ForgeColors.sage : ForgeColors.obsidian.opacity(0.3), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(chosen ? ForgeColors.mint.opacity(0.3) : ForgeColors.sage.opacity(0.1), lineWidth: 1))
                    }.buttonStyle(.plain)
                }
            }
        }.padding(12).forgeCard()
    }

    private func habitCard(_ habit: ForgeHabit) -> some View {
        let completed = store.isCompleted(habit.id, on: store.selectedDate)
        return HStack(spacing: 11) {
            ForgeHabitGlyph(icon: habit.icon, size: 43)
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name).font(.subheadline.weight(.bold)).foregroundStyle(ForgeColors.mint).strikethrough(completed, color: ForgeColors.sage.opacity(0.8)).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Image(systemName: habit.routine.symbol)
                    Text(habit.routine.rawValue)
                    Text("·")
                    Image(systemName: "clock")
                    Text("\(habit.duration)m")
                }.font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(ForgeColors.sage)
                if !habit.anchor.isEmpty {
                    Text(habit.anchor).font(.system(size: 10, weight: .regular, design: .rounded)).foregroundStyle(ForgeColors.muted).lineLimit(1)
                }
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundStyle(ForgeColors.sage)
                    Text("\(store.currentStreak(for: habit.id)) day streak")
                    Text("· Best \(store.bestStreak(for: habit.id))d")
                }.font(.system(size: 9, weight: .semibold, design: .rounded)).foregroundStyle(ForgeColors.muted)
            }
            Spacer(minLength: 0)
            VStack(spacing: 9) {
                Button { store.toggleCompletion(habit.id, on: store.selectedDate) } label: {
                    ZStack {
                        Circle().fill(completed ? LinearGradient(colors: [ForgeColors.mint, ForgeColors.sage], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [ForgeColors.obsidian, ForgeColors.glass], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Circle().strokeBorder(completed ? ForgeColors.mint : ForgeColors.sage.opacity(0.5), lineWidth: 1.5)
                        if completed { Image(systemName: "checkmark").font(.system(size: 16, weight: .heavy)).foregroundStyle(ForgeColors.obsidian) }
                    }.frame(width: 32, height: 32)
                }.buttonStyle(.plain).accessibilityLabel(completed ? "Mark \(habit.name) incomplete" : "Complete \(habit.name)")
                Button { onStartFocus(habit) } label: {
                    Image(systemName: "timer").font(.system(size: 12, weight: .semibold)).foregroundStyle(ForgeColors.sage).frame(width: 31, height: 28).background(ForgeColors.obsidian.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
                }.accessibilityLabel("Start focus timer for \(habit.name)")
            }
        }
        .padding(12)
        .background(completed ? ForgeColors.emerald.opacity(0.36) : ForgeColors.glass.opacity(0.53), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(completed ? ForgeColors.mint.opacity(0.28) : ForgeColors.sage.opacity(0.15), lineWidth: 1))
        .contextMenu {
            Button { onEditHabit(habit) } label: { Label("Edit habit", systemImage: "pencil") }
            Button { onStartFocus(habit) } label: { Label("Start focus timer", systemImage: "timer") }
        }
    }
}
