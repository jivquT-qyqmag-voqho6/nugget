import SwiftUI

struct WatchDashboardView: View {
    @EnvironmentObject var store: WatchTweakStore

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {

                // ── App Icon + Title ──────────────────────────────────
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "5E5CE6"), Color(hex: "9C59FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)
                    Text("C")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 4)

                Text("Chris")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("iOS Tweaks")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                Divider()
                    .background(Color.white.opacity(0.12))
                    .padding(.vertical, 2)

                // ── Status Row ────────────────────────────────────────
                HStack(spacing: 10) {
                    StatPill(
                        value: "\(store.enabledCount)",
                        label: "Enabled",
                        color: Color(hex: "5E5CE6")
                    )
                    StatPill(
                        value: "\(store.tweaks.count)",
                        label: "Total",
                        color: .gray
                    )
                }

                // ── Phone status ──────────────────────────────────────
                HStack(spacing: 5) {
                    Circle()
                        .fill(store.phoneReachable ? Color(hex: "32D74B") : Color(hex: "FF453A"))
                        .frame(width: 7, height: 7)
                    Text(store.phoneReachable ? "iPhone Connected" : "iPhone Offline")
                        .font(.system(size: 11))
                        .foregroundColor(store.phoneReachable ? Color(hex: "32D74B") : .gray)
                }
                .padding(.vertical, 2)

                // ── Last sync ─────────────────────────────────────────
                if let sync = store.lastSyncTime {
                    Text("Synced \(sync, style: .relative) ago")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }

                // ── Category summary ──────────────────────────────────
                VStack(spacing: 4) {
                    ForEach(store.byCategory, id: \.0) { cat, tweaks in
                        let on = tweaks.filter { $0.isToggled || !$0.textValue.isEmpty }.count
                        if on > 0 {
                            HStack {
                                Text(catIcon(cat))
                                    .font(.system(size: 12))
                                Text(catShort(cat))
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(on)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(catColor(cat))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                    }
                }

                // ── Quick tip ─────────────────────────────────────────
                Text("Swipe → to browse tweaks")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
    }

    func catIcon(_ cat: String) -> String {
        switch cat {
        case "Hidden Features": return "✨"
        case "Status Bar":      return "📶"
        case "Springboard":     return "🏠"
        case "Daemons":         return "⚡"
        default:                return "⚙️"
        }
    }

    func catShort(_ cat: String) -> String {
        switch cat {
        case "Hidden Features": return "Hidden"
        case "Status Bar":      return "Status Bar"
        case "Springboard":     return "Springboard"
        case "Daemons":         return "Daemons"
        default:                return "Internal"
        }
    }

    func catColor(_ cat: String) -> Color {
        switch cat {
        case "Hidden Features": return Color(hex: "9C59FF")
        case "Status Bar":      return Color(hex: "0A84FF")
        case "Springboard":     return Color(hex: "FF9F0A")
        case "Daemons":         return Color(hex: "FF453A")
        default:                return .gray
        }
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Color helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int>>8)*17, (int>>4 & 0xF)*17, (int & 0xF)*17)
        case 6:  (a, r, g, b) = (255, int>>16, int>>8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 1, 1, 1)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
