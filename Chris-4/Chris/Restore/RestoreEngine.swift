// RestoreEngine.swift
// Orchestrates the full Chris restore pipeline:
//   1. Start minimuxer + em_proxy
//   2. Patch MobileGestalt / SpringBoard / StatusBar plists
//   3. Disable selected daemons via idevicebackup2.c
//   4. Run SparseRestore

import Foundation

// MARK: - Errors

enum RestoreError: Error, LocalizedError {
    case noPairingFile
    case noMobileGestalt
    case muxFailed(String)
    case patchFailed(String)
    case restoreFailed(String)
    case unsupportedVersion

    var errorDescription: String? {
        switch self {
        case .noPairingFile:        return "Select your .mobiledevicepairing file first."
        case .noMobileGestalt:      return "Select your MobileGestalt file first."
        case .muxFailed(let m):     return "Minimuxer error: \(m)"
        case .patchFailed(let m):   return "Patch error: \(m)"
        case .restoreFailed(let m): return "Restore failed: \(m)"
        case .unsupportedVersion:   return "Your iOS version is not supported."
        }
    }
}

// MARK: - Restore Engine

enum ChrisRestoreEngine {

    static func apply(
        manager: TweakManager,
        progress: @escaping @Sendable (Double, String) -> Void
    ) async throws {

        guard let pairingURL = manager.pairingFileURL else { throw RestoreError.noPairingFile }

        // 1. Start minimuxer
        await MainActor.run { progress(0.05, "Starting minimuxer…") }
        let pairingData = try Data(contentsOf: pairingURL)
        do {
            try Minimuxer.shared.start(pairingFileData: pairingData)
            try await Minimuxer.shared.waitUntilReady(timeout: 12.0)
        } catch {
            throw RestoreError.muxFailed(error.localizedDescription)
        }
        await MainActor.run { progress(0.15, "Device connected") }

        // 2. Collect tweaks
        let enabled = allTweaks.filter { manager.isEnabled($0) }
        var gestaltChanges:     [String: Any] = [:]
        var springboardChanges: [String: Any] = [:]
        var statusBarChanges:   [String: Any] = [:]
        var daemonIds:          [String]      = []

        for tweak in enabled {
            let value: Any
            switch tweak.type {
            case .toggle: value = manager.toggles[tweak.id] ?? false
            default:      value = manager.values[tweak.id] ?? ""
            }
            switch tweak.category {
            case .gestalt:        gestaltChanges[tweak.key]     = value
            case .springboard:    springboardChanges[tweak.key] = value
            case .statusBar:      statusBarChanges[tweak.key]   = value
            case .internalFlags:  springboardChanges[tweak.key] = value  // stored in SB prefs
            case .daemons:
                if let b = value as? Bool, b { daemonIds.append(tweak.key) }
            }
        }

        let totalSteps = Double(
            (gestaltChanges.isEmpty     ? 0 : 1) +
            (springboardChanges.isEmpty ? 0 : 1) +
            (statusBarChanges.isEmpty   ? 0 : 1) +
            daemonIds.count
        )
        var step = 0.0

        // 3. MobileGestalt
        if !gestaltChanges.isEmpty {
            guard let mgURL = manager.mobileGestaltURL else { throw RestoreError.noMobileGestalt }
            await MainActor.run { progress(0.20, "Patching MobileGestalt…") }
            let original = try Data(contentsOf: mgURL)
            let patched  = try MobileGestaltPatcher.patch(originalData: original, changes: gestaltChanges)
            step += 1
            await MainActor.run { progress(0.20 + (step/totalSteps)*0.65, "Restoring MobileGestalt…") }
            try callC(patched) { base, len in
                chris_restore_mobilegestalt(nil, base, len, nil, nil)
            }
        }

        // 4. SpringBoard
        if !springboardChanges.isEmpty {
            step += 1
            await MainActor.run { progress(0.20 + (step/totalSteps)*0.65, "Restoring SpringBoard…") }
            let data = try MobileGestaltPatcher.buildSpringboardPlist(changes: springboardChanges)
            try callC(data) { base, len in
                chris_restore_springboard_plist(nil, base, len, nil, nil)
            }
        }

        // 5. Status Bar
        if !statusBarChanges.isEmpty {
            step += 1
            await MainActor.run { progress(0.20 + (step/totalSteps)*0.65, "Restoring status bar…") }
            let data = try MobileGestaltPatcher.buildStatusBarPlist(changes: statusBarChanges)
            try callC(data) { base, len in
                chris_sparserestore_file(
                    nil, "HomeDomain",
                    "Library/SpringBoard/statusBarOverrides",
                    base, len, nil, nil
                )
            }
        }

        // 6. Daemons
        for daemonId in daemonIds {
            step += 1
            let pct = 0.20 + (step/totalSteps)*0.65
            await MainActor.run { progress(pct, "Disabling \(daemonId)…") }
            daemonId.withCString { cStr in
                _ = chris_disable_daemon(nil, cStr, nil, nil)
            }
        }

        await MainActor.run { progress(1.0, "✓ Done! Respring to apply.") }
    }

    // MARK: - Helper

    private static func callC(_ data: Data, fn: (UnsafePointer<UInt8>, Int) -> Int32) throws {
        let rc = data.withUnsafeBytes { ptr -> Int32 in
            guard let base = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return -1 }
            return fn(base, data.count)
        }
        if rc != 0 { throw RestoreError.restoreFailed("C restore returned \(rc)") }
    }
}

// MARK: - C function declarations

@_silgen_name("chris_sparserestore_file")
func chris_sparserestore_file(_ udid: UnsafePointer<CChar>?, _ domain: UnsafePointer<CChar>?, _ path: UnsafePointer<CChar>?, _ data: UnsafePointer<UInt8>?, _ size: Int, _ cb: (@convention(c)(Float, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void)?, _ ctx: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("chris_restore_mobilegestalt")
func chris_restore_mobilegestalt(_ udid: UnsafePointer<CChar>?, _ data: UnsafePointer<UInt8>?, _ size: Int, _ cb: (@convention(c)(Float, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void)?, _ ctx: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("chris_restore_springboard_plist")
func chris_restore_springboard_plist(_ udid: UnsafePointer<CChar>?, _ data: UnsafePointer<UInt8>?, _ size: Int, _ cb: (@convention(c)(Float, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void)?, _ ctx: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("chris_disable_daemon")
func chris_disable_daemon(_ udid: UnsafePointer<CChar>?, _ daemon: UnsafePointer<CChar>?, _ cb: (@convention(c)(Float, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void)?, _ ctx: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("minimuxer_start")
func minimuxer_start(_ data: UnsafePointer<UInt8>?, _ len: UInt) -> Int32

@_silgen_name("minimuxer_ready")
func minimuxer_ready() -> Bool

@_silgen_name("minimuxer_stop")
func minimuxer_stop()

@_silgen_name("minimuxer_last_error")
func minimuxer_last_error() -> UnsafePointer<CChar>?
