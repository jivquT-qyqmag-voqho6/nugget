import SwiftUI
import WatchKit

struct WatchApplyView: View {
    @EnvironmentObject var store: WatchTweakStore
    @State private var showConfirm = false
    @State private var showReset   = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                // ── Header ────────────────────────────────────────────
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "5E5CE6"), Color(hex: "9C59FF")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .padding(.top, 4)

                Text("Apply Tweaks")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // ── Summary ───────────────────────────────────────────
                if store.enabledCount > 0 {
                    Text("\(store.enabledCount) tweak\(store.enabledCount == 1 ? "" : "s") ready")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "5E5CE6"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "5E5CE6").opacity(0.15))
                        .clipShape(Capsule())
                } else {
                    Text("No tweaks enabled")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                // ── Phone indicator ───────────────────────────────────
                HStack(spacing: 5) {
                    Image(systemName: "iphone")
                        .font(.system(size: 11))
                    Text(store.phoneReachable ? "iPhone ready" : "iPhone offline")
                        .font(.system(size: 11))
                }
                .foregroundColor(store.phoneReachable ? Color(hex: "32D74B") : .gray)

                // ── Status message ────────────────────────────────────
                if !store.statusMessage.isEmpty {
                    Text(store.statusMessage)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(store.statusOK ? Color(hex: "32D74B") : Color(hex: "FF453A"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            (store.statusOK ? Color(hex: "32D74B") : Color(hex: "FF453A")).opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // ── Progress ──────────────────────────────────────────
                if store.isApplying {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .tint(Color(hex: "5E5CE6"))
                    Text("Sending to iPhone…")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Divider().background(Color.white.opacity(0.1))

                // ── Apply Button ──────────────────────────────────────
                Button {
                    if store.enabledCount > 0 && store.phoneReachable {
                        showConfirm = true
                    } else if !store.phoneReachable {
                        store.statusMessage = "Open Chris on iPhone first"
                        store.statusOK = false
                        WKInterfaceDevice.current().play(.failure)
                    } else {
                        store.statusMessage = "Enable at least one tweak"
                        store.statusOK = false
                        WKInterfaceDevice.current().play(.failure)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text(store.isApplying ? "Applying…" : "Apply")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        store.isApplying || store.enabledCount == 0
                        ? Color.gray.opacity(0.3)
                        : LinearGradient(
                            colors: [Color(hex: "5E5CE6"), Color(hex: "9C59FF")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(store.isApplying)

                // ── Reset Button ──────────────────────────────────────
                Button {
                    showReset = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset All")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Text("Requires WireGuard + pairing file on iPhone")
                    .font(.system(size: 9))
                    .foregroundColor(.gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

            }
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        // ── Confirm Apply Sheet ───────────────────────────────────────
        .sheet(isPresented: $showConfirm) {
            ConfirmApplySheet(onConfirm: {
                showConfirm = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    store.sendToPhone()
                }
            }, onCancel: {
                showConfirm = false
            })
        }
        // ── Confirm Reset Sheet ───────────────────────────────────────
        .sheet(isPresented: $showReset) {
            ConfirmResetSheet(onConfirm: {
                showReset = false
                store.resetAll()
            }, onCancel: {
                showReset = false
            })
        }
    }
}

// MARK: - Confirm Sheets

struct ConfirmApplySheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "FF9F0A"))
            Text("Apply Tweaks?")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("This will restore files to your iPhone. Make sure WireGuard is running.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Button("Cancel", action: onCancel)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .buttonStyle(.plain)

                Button("Apply", action: onConfirm)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color(hex: "5E5CE6"))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .buttonStyle(.plain)
            }
        }
        .padding()
    }
}

struct ConfirmResetSheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "trash.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "FF453A"))
            Text("Reset All?")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("All enabled tweaks will be cleared.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Button("Cancel", action: onCancel)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .buttonStyle(.plain)

                Button("Reset", action: onConfirm)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color(hex: "FF453A"))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .buttonStyle(.plain)
            }
        }
        .padding()
    }
}
