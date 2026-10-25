import SwiftUI

struct HabitEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: ForgeHabit?
    let onSave: (ForgeHabit) -> Void
    let onDelete: (String) -> Void
    @State private var name: String
    @State private var routine: HabitRoutine
    @State private var duration: String
    @State private var anchor: String
    @State private var icon: HabitIcon
    @State private var showingDeleteAlert = false

    init(habit: ForgeHabit?, onSave: @escaping (ForgeHabit) -> Void, onDelete: @escaping (String) -> Void) {
        self.habit = habit
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: habit?.name ?? "")
        _routine = State(initialValue: habit?.routine ?? .morning)
        _duration = State(initialValue: String(habit?.duration ?? 25))
        _anchor = State(initialValue: habit?.anchor ?? "")
        _icon = State(initialValue: habit?.icon ?? .bolt)
    }

    var body: some View {
        ZStack {
            ForgeBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(habit == nil ? "Forge a new habit" : "Refine your habit").font(.title3.weight(.heavy)).foregroundStyle(ForgeColors.mint)
                            Text("Small rituals. Long-term identity.").font(.caption).foregroundStyle(ForgeColors.muted)
                        }
                        Spacer()
                        Button { dismiss() } label: { Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundStyle(ForgeColors.sage).frame(width: 32, height: 32).background(ForgeColors.glass, in: Circle()) }
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        fieldLabel("HABIT TITLE")
                        TextField("e.g. 45-minute deep work", text: $name).forgeInput()
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("CHOOSE AN ICON")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                            ForEach(HabitIcon.allCases) { option in
                                Button { icon = option } label: {
                                    VStack(spacing: 5) {
                                        Image(systemName: option.symbol).font(.system(size: 19, weight: .semibold))
                                        Text(option.label).font(.system(size: 8, weight: .medium, design: .rounded))
                                    }
                                    .foregroundStyle(icon == option ? ForgeColors.obsidian : ForgeColors.sage)
                                    .frame(maxWidth: .infinity).frame(height: 57)
                                    .background(icon == option ? ForgeColors.mint : ForgeColors.obsidian.opacity(0.48), in: RoundedRectangle(cornerRadius: 13))
                                    .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(icon == option ? ForgeColors.mint : ForgeColors.emerald, lineWidth: 1))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        fieldLabel("ROUTINE BLOCK")
                        Picker("Routine", selection: $routine) {
                            ForEach(HabitRoutine.allCases) { option in Text(option.rawValue).tag(option) }
                        }
                        .pickerStyle(.segmented).tint(ForgeColors.sage)
                    }
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 7) {
                            fieldLabel("FOCUS TIME · MIN")
                            TextField("25", text: $duration).keyboardType(.numberPad).forgeInput()
                        }
                        VStack(alignment: .leading, spacing: 7) {
                            fieldLabel("AFTER I… (OPTIONAL)")
                            TextField("Your habit anchor", text: $anchor).forgeInput()
                        }
                    }
                    Button(action: save) {
                        HStack { Spacer(); Label(habit == nil ? "Create habit" : "Save changes", systemImage: "checkmark.circle.fill"); Spacer() }
                    }.buttonStyle(ForgePrimaryButtonStyle()).frame(maxWidth: .infinity)
                    if let habit {
                        Button { showingDeleteAlert = true } label: { HStack { Spacer(); Label("Delete this habit", systemImage: "trash").foregroundStyle(.orange); Spacer() } }.buttonStyle(.plain).padding(.top, 3)
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Delete this habit?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let habit { onDelete(habit.id) }
                dismiss()
            }
        } message: { Text("Its completion marks will also be removed. This cannot be undone.") }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 9, weight: .bold, design: .rounded)).tracking(0.7).foregroundStyle(ForgeColors.sage)
    }
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var result = habit ?? ForgeHabit(name: trimmed, routine: routine, duration: max(1, Int(duration) ?? 25), anchor: anchor, icon: icon)
        result.name = trimmed
        result.routine = routine
        result.duration = min(240, max(1, Int(duration) ?? 25))
        result.anchor = anchor.trimmingCharacters(in: .whitespacesAndNewlines)
        result.icon = icon
        onSave(result)
        dismiss()
    }
}

private extension View {
    func forgeInput() -> some View {
        self.font(.subheadline).foregroundStyle(ForgeColors.mint).padding(12)
            .background(ForgeColors.obsidian.opacity(0.6), in: RoundedRectangle(cornerRadius: 13))
            .overlay(RoundedRectangle(cornerRadius: 13).strokeBorder(ForgeColors.emerald, lineWidth: 1))
    }
}
