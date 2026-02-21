import Foundation
import SwiftUI
import WatchConnectivity
import Combine

// MARK: - Lightweight tweak model for Watch
// (mirrors the iPhone TweakModel but only what the watch needs)

struct WatchTweak: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let isChrisOnly: Bool
    var isToggled: Bool
    var textValue: String
    var type: String  // "toggle" | "text" | "stepper"
}

// MARK: - Watch Tweak Store

class WatchTweakStore: NSObject, ObservableObject, WCSessionDelegate {

    @Published var tweaks: [WatchTweak] = WatchTweakStore.defaultTweaks()
    @Published var isApplying: Bool = false
    @Published var statusMessage: String = ""
    @Published var statusOK: Bool = true
    @Published var phoneReachable: Bool = false
    @Published var lastSyncTime: Date? = nil

    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Computed helpers

    var enabledCount: Int { tweaks.filter { $0.isToggled || !$0.textValue.isEmpty }.count }

    var byCategory: [(String, [WatchTweak])] {
        let cats = ["Hidden Features", "Status Bar", "Springboard", "Daemons", "Internal"]
        return cats.compactMap { cat in
            let t = tweaks.filter { $0.category == cat }
            return t.isEmpty ? nil : (cat, t)
        }
    }

    // MARK: - Actions

    func toggle(_ tweak: WatchTweak) {
        if let i = tweaks.firstIndex(where: { $0.id == tweak.id }) {
            tweaks[i].isToggled.toggle()
        }
    }

    func setValue(_ id: String, _ value: String) {
        if let i = tweaks.firstIndex(where: { $0.id == id }) {
            tweaks[i].textValue = value
        }
    }

    func sendToPhone() {
        guard let session = session, session.isReachable else {
            statusMessage = "iPhone not reachable"
            statusOK = false
            return
        }
        isApplying = true
        statusMessage = "Sending to iPhone…"
        statusOK = true

        let payload: [[String: Any]] = tweaks.map {[
            "id": $0.id,
            "isToggled": $0.isToggled,
            "textValue": $0.textValue
        ]}

        session.sendMessage(["action": "applyTweaks", "tweaks": payload], replyHandler: { reply in
            DispatchQueue.main.async {
                self.isApplying = false
                if let success = reply["success"] as? Bool, success {
                    self.statusMessage = "✓ Applied!"
                    self.statusOK = true
                    self.lastSyncTime = Date()
                    WKInterfaceDevice.current().play(.success)
                } else {
                    self.statusMessage = reply["error"] as? String ?? "Failed"
                    self.statusOK = false
                    WKInterfaceDevice.current().play(.failure)
                }
            }
        }, errorHandler: { err in
            DispatchQueue.main.async {
                self.isApplying = false
                self.statusMessage = err.localizedDescription
                self.statusOK = false
                WKInterfaceDevice.current().play(.failure)
            }
        })
    }

    func resetAll() {
        for i in tweaks.indices {
            tweaks[i].isToggled = false
            tweaks[i].textValue = ""
        }
        statusMessage = ""
        WKInterfaceDevice.current().play(.click)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.phoneReachable = session.isReachable
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.phoneReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // iPhone can push tweak state updates to watch
        if let tweakData = message["syncTweaks"] as? [[String: Any]] {
            DispatchQueue.main.async {
                for item in tweakData {
                    guard let id = item["id"] as? String else { continue }
                    if let i = self.tweaks.firstIndex(where: { $0.id == id }) {
                        self.tweaks[i].isToggled = item["isToggled"] as? Bool ?? false
                        self.tweaks[i].textValue = item["textValue"] as? String ?? ""
                    }
                }
                self.lastSyncTime = Date()
                WKInterfaceDevice.current().play(.click)
            }
        }
    }

    // MARK: - Default tweaks (subset of iPhone tweaks, watch-relevant)

    static func defaultTweaks() -> [WatchTweak] {[
        // Hidden Features
        WatchTweak(id: "dynamic_island",  name: "Dynamic Island",          category: "Hidden Features", isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "aod",             name: "Always-On Display",       category: "Hidden Features", isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "ai_enabler",      name: "Apple Intelligence",      category: "Hidden Features", isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "boot_chime",      name: "Boot Chime",              category: "Hidden Features", isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "charge_limit",    name: "Charge Limit",            category: "Hidden Features", isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "pro_motion",      name: "Force 120Hz",             category: "Hidden Features", isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "spatial_audio",   name: "Spatial Audio",           category: "Hidden Features", isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "satellite_sos",   name: "Satellite SOS",           category: "Hidden Features", isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        // Status Bar
        WatchTweak(id: "carrier_name",    name: "Carrier Name",            category: "Status Bar",      isChrisOnly: false, isToggled: false, textValue: "", type: "text"),
        WatchTweak(id: "time_text",       name: "Time Text",               category: "Status Bar",      isChrisOnly: false, isToggled: false, textValue: "", type: "text"),
        WatchTweak(id: "hide_battery",    name: "Hide Battery Icon",       category: "Status Bar",      isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "hide_wifi",       name: "Hide WiFi Icon",          category: "Status Bar",      isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "hide_clock",      name: "Hide Clock",              category: "Status Bar",      isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        // Springboard
        WatchTweak(id: "lock_footnote",   name: "Lock Screen Footnote",    category: "Springboard",     isChrisOnly: false, isToggled: false, textValue: "", type: "text"),
        WatchTweak(id: "hide_dock",       name: "Hide Dock",               category: "Springboard",     isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "hide_home_bar",   name: "Hide Home Bar",           category: "Springboard",     isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "hide_icon_labels",name: "Hide Icon Labels",        category: "Springboard",     isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        // Daemons
        WatchTweak(id: "kill_ota",        name: "Disable OTA Updates",     category: "Daemons",         isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "kill_usage",      name: "Disable Analytics",       category: "Daemons",         isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "kill_gamecenter", name: "Disable Game Center",     category: "Daemons",         isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "kill_siri",       name: "Disable Siri",            category: "Daemons",         isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "kill_adservices", name: "Disable Ad Services",     category: "Daemons",         isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        // Internal
        WatchTweak(id: "metal_hud",       name: "Metal GPU HUD",           category: "Internal",        isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "force_dark",      name: "Force Dark Mode",         category: "Internal",        isChrisOnly: true,  isToggled: false, textValue: "", type: "toggle"),
        WatchTweak(id: "build_statusbar", name: "Build in Status Bar",     category: "Internal",        isChrisOnly: false, isToggled: false, textValue: "", type: "toggle"),
    ]}
}
