// MobileGestaltPatcher.swift
// Reads a MobileGestalt plist, applies tweak values, and returns patched data.

import Foundation

enum PatchError: Error, LocalizedError {
    case invalidPlist
    case missingCachesKey
    case serializationFailed

    var errorDescription: String? {
        switch self {
        case .invalidPlist:         return "The MobileGestalt plist file is invalid or corrupted."
        case .missingCachesKey:     return "MobileGestalt plist is missing the expected cache key."
        case .serializationFailed:  return "Failed to serialize the patched plist."
        }
    }
}

class MobileGestaltPatcher {

    /// Applies MobileGestalt tweaks to the given plist data.
    /// - Parameters:
    ///   - originalData: Raw bytes of com.apple.MobileGestalt.plist
    ///   - changes: Dictionary of MobileGestalt key → new value
    /// - Returns: Patched plist data ready to restore to device.
    static func patch(originalData: Data, changes: [String: Any]) throws -> Data {
        guard var plist = try PropertyListSerialization.propertyList(
            from: originalData,
            options: [],
            format: nil
        ) as? [String: Any] else {
            throw PatchError.invalidPlist
        }

        // MobileGestalt plists store values under a nested key structure.
        // The actual key path varies by iOS version, but typically:
        //   Root → "caches" → <gestalt key> → value
        // Some keys are directly at the root.

        if var caches = plist["caches"] as? [String: Any] {
            for (key, value) in changes {
                if value is Bool || value is Int || value is String {
                    caches[key] = value
                }
            }
            plist["caches"] = caches
        } else {
            // Fallback: apply at root level
            for (key, value) in changes {
                plist[key] = value
            }
        }

        guard let patched = try? PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .binary,
            options: 0
        ) else {
            throw PatchError.serializationFailed
        }

        return patched
    }

    /// Builds a SpringBoard preferences plist from springboard tweak values.
    static func buildSpringboardPlist(changes: [String: Any]) throws -> Data {
        var prefs: [String: Any] = [:]

        for (key, value) in changes {
            prefs[key] = value
        }

        guard let data = try? PropertyListSerialization.data(
            fromPropertyList: prefs,
            format: .binary,
            options: 0
        ) else {
            throw PatchError.serializationFailed
        }

        return data
    }

    /// Builds a status bar overrides plist.
    /// Written to: /var/mobile/Library/SpringBoard/statusBarOverrides
    static func buildStatusBarPlist(changes: [String: Any]) throws -> Data {
        var overrides: [String: Any] = [:]
        for (key, value) in changes {
            overrides[key] = value
        }
        guard let data = try? PropertyListSerialization.data(
            fromPropertyList: overrides,
            format: .binary,
            options: 0
        ) else {
            throw PatchError.serializationFailed
        }
        return data
    }
}
