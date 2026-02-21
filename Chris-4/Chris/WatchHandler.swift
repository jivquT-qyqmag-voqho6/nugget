// WatchHandler.swift
// Add this to the iPhone Chris app target.
// Handles messages from the Apple Watch companion app.

import Foundation
import WatchConnectivity
import SwiftUI

class WatchHandler: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchHandler()

    @Published var watchConnected: Bool = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - Receive message from Watch

    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {

        guard let action = message["action"] as? String else {
            replyHandler(["success": false, "error": "Unknown action"])
            return
        }

        switch action {
        case "applyTweaks":
            handleApplyFromWatch(message: message, reply: replyHandler)
        default:
            replyHandler(["success": false, "error": "Unknown action"])
        }
    }

    private func handleApplyFromWatch(
        message: [String: Any],
        reply: @escaping ([String: Any]) -> Void
    ) {
        guard let tweakData = message["tweaks"] as? [[String: Any]] else {
            reply(["success": false, "error": "No tweak data"])
            return
        }

        // Update the shared TweakManager with watch's selections
        DispatchQueue.main.async {
            // Find the TweakManager in the environment
            // In a real app, inject this via a shared singleton or AppDelegate
            let manager = AppDelegate.shared.tweakManager

            for item in tweakData {
                guard let id = item["id"] as? String else { continue }
                if let toggled = item["isToggled"] as? Bool {
                    manager.toggles[id] = toggled
                }
                if let text = item["textValue"] as? String, !text.isEmpty {
                    manager.values[id] = text
                }
            }

            // Kick off the restore
            manager.applyTweaks()

            // Listen for completion and reply
            // (simplified — in production, observe manager.statusOK)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                reply(["success": true])
            }
        }
    }

    // MARK: - Push state to Watch

    func pushStateToWatch(manager: TweakManager) {
        guard WCSession.default.isReachable else { return }

        let payload: [[String: Any]] = allTweaks.map {[
            "id": $0.id,
            "isToggled": manager.toggles[$0.id] ?? false,
            "textValue": manager.values[$0.id] ?? ""
        ]}

        WCSession.default.sendMessage(
            ["syncTweaks": payload],
            replyHandler: nil,
            errorHandler: { err in
                print("[WatchHandler] Push failed: \(err)")
            }
        )
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            self.watchConnected = activationState == .activated
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.watchConnected = session.isPaired && session.isWatchAppInstalled
        }
    }
}

// MARK: - AppDelegate stub (add to existing AppDelegate or SceneDelegate)
// This is a reference — merge into your existing AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    static let shared = AppDelegate()
    let tweakManager = TweakManager()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Start watch handler
        _ = WatchHandler.shared
        return true
    }
}
