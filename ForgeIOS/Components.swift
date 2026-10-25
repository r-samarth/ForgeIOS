import SwiftUI

enum ForgeColors {
    static let obsidian = Color(red: 5.0/255, green: 31.0/255, blue: 32.0/255)
    static let elevated = Color(red: 11.0/255, green: 43.0/255, blue: 38.0/255)
    static let glass = Color(red: 22.0/255, green: 56.0/255, blue: 50.0/255)
    static let emerald = Color(red: 35.0/255, green: 83.0/255, blue: 71.0/255)
    static let sage = Color(red: 142.0/255, green: 182.0/255, blue: 155.0/255)
    static let mint = Color(red: 218.0/255, green: 241.0/255, blue: 222.0/255)
    static let muted = sage.opacity(0.86)
}

struct ForgeBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [ForgeColors.obsidian, ForgeColors.elevated, ForgeColors.obsidian], startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [ForgeColors.emerald.opacity(0.42), .clear], center: .topLeading, startRadius: 8, endRadius: 390)
            RadialGradient(colors: [ForgeColors.sage.opacity(0.12), .clear], center: .topTrailing, startRadius: 4, endRadius: 280)
        }
        .ignoresSafeArea()
    }
}

struct ForgeCardModifier: ViewModifier {
    var emphasis = false
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(LinearGradient(colors: emphasis ? [ForgeColors.emerald.opacity(0.62), ForgeColors.glass.opacity(0.88)] : [ForgeColors.glass.opacity(0.73), ForgeColors.elevated.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(ForgeColors.sage.opacity(emphasis ? 0.32 : 0.19), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.22), radius: 15, x: 0, y: 8)
            }
    }
}

extension View {
    func forgeCard(emphasis: Bool = false) -> some View { modifier(ForgeCardModifier(emphasis: emphasis)) }
}

struct ForgeSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: String? = nil
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline.weight(.bold)).foregroundStyle(ForgeColors.mint)
                if let subtitle { Text(subtitle).font(.caption).foregroundStyle(ForgeColors.muted) }
            }
            Spacer(minLength: 4)
            if let trailing { Text(trailing).font(.caption.monospaced().weight(.semibold)).foregroundStyle(ForgeColors.sage) }
        }
    }
}

struct ForgeMetricTile: View {
    let title: String
    let value: String
    var symbol: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased()).font(.system(size: 9, weight: .semibold, design: .rounded)).tracking(0.8).foregroundStyle(ForgeColors.sage)
            HStack(spacing: 4) {
                Text(value).font(.system(size: 23, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(ForgeColors.mint).minimumScaleFactor(0.7).lineLimit(1)
                if let symbol { Image(systemName: symbol).font(.caption).foregroundStyle(ForgeColors.sage) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(ForgeColors.obsidian.opacity(0.42), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(ForgeColors.emerald.opacity(0.65), lineWidth: 1))
    }
}

struct ForgePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(ForgeColors.obsidian)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(LinearGradient(colors: [ForgeColors.mint, ForgeColors.sage], startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
    }
}

struct ForgeOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(ForgeColors.mint)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(ForgeColors.glass.opacity(0.7), in: Capsule())
            .overlay(Capsule().strokeBorder(ForgeColors.sage.opacity(0.25), lineWidth: 1))
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

struct ForgeProgressRing: View {
    let progress: Double
    var size: CGFloat = 108
    var body: some View {
        ZStack {
            Circle().stroke(ForgeColors.obsidian.opacity(0.95), lineWidth: size * 0.095)
            Circle().stroke(ForgeColors.emerald.opacity(0.75), lineWidth: size * 0.075)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(LinearGradient(colors: [ForgeColors.mint, ForgeColors.sage], startPoint: .topTrailing, endPoint: .bottomLeading), style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%").font(.system(size: size * 0.19, weight: .heavy, design: .rounded).monospacedDigit()).foregroundStyle(ForgeColors.mint)
                Text("FORGED").font(.system(size: size * 0.075, weight: .bold, design: .rounded)).tracking(1).foregroundStyle(ForgeColors.sage)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily progress \(Int(progress * 100)) percent")
    }
}

struct ForgeHabitGlyph: View {
    let icon: HabitIcon
    var size: CGFloat = 42
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
            .fill(LinearGradient(colors: [ForgeColors.emerald.opacity(0.9), ForgeColors.obsidian.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: size * 0.32).strokeBorder(ForgeColors.sage.opacity(0.28), lineWidth: 1))
            .overlay(Image(systemName: icon.symbol).font(.system(size: size * 0.38, weight: .semibold)).foregroundStyle(ForgeColors.mint))
            .frame(width: size, height: size)
    }
}

struct ForgeEmptyState: View {
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: "sparkles").font(.system(size: 27)).foregroundStyle(ForgeColors.sage)
            Text(title).font(.headline.weight(.bold)).foregroundStyle(ForgeColors.mint)
            Text(message).font(.subheadline).foregroundStyle(ForgeColors.muted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .forgeCard()
    }
}

struct ForgeToggleRow: View {
    let title: String
    let detail: String
    let symbol: String
    @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: symbol).font(.system(size: 16, weight: .semibold)).foregroundStyle(ForgeColors.sage).frame(width: 35, height: 35).background(ForgeColors.obsidian.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(ForgeColors.mint)
                Text(detail).font(.caption).foregroundStyle(ForgeColors.muted)
            }
            Spacer(minLength: 0)
            Toggle(title, isOn: $isOn).labelsHidden().tint(ForgeColors.sage)
        }
        .padding(.vertical, 8)
    }
}
