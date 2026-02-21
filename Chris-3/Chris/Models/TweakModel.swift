import Foundation
import SwiftUI

// MARK: - Tweak Types

enum TweakType {
    case toggle
    case text(placeholder: String)
    case stepper(min: Int, max: Int)
    case picker(options: [String])
}

enum TweakCategory: String, CaseIterable, Identifiable {
    case gestalt    = "Hidden Features"
    case statusBar  = "Status Bar"
    case springboard = "Springboard"
    case daemons    = "Daemons"
    case internalFlags = "Internal"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .gestalt:       return "wand.and.stars"
        case .statusBar:     return "iphone.gen3"
        case .springboard:   return "square.grid.2x2"
        case .daemons:       return "bolt.slash"
        case .internalFlags: return "wrench.and.screwdriver"
        }
    }

    var color: Color {
        switch self {
        case .gestalt:       return .purple
        case .statusBar:     return .blue
        case .springboard:   return .orange
        case .daemons:       return .red
        case .internalFlags: return .gray
        }
    }
}

// MARK: - Tweak Model

struct Tweak: Identifiable {
    let id: String
    let name: String
    let description: String
    let category: TweakCategory
    let type: TweakType
    let key: String
    let iOSMin: String
    let iOSMax: String?
    var isRisky: Bool = false
    var isChrisOnly: Bool = false   // Chris-exclusive tweak not in Nugget
}

// MARK: - All Tweaks

let allTweaks: [Tweak] = [

    // ── Hidden Features (MobileGestalt) ──────────────────────────────────────
    Tweak(id: "dynamic_island",    name: "Dynamic Island",                description: "Enable Dynamic Island on any device.",                          category: .gestalt,    type: .toggle,  key: "CwvKxM2iEFL9qfyGAEkL7A", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "aod",               name: "Always-On Display",             description: "Enable AOD on unsupported devices.",                            category: .gestalt,    type: .toggle,  key: "2OOJf1VhaM7NxfRok3HbWQ", iOSMin: "18.0", iOSMax: "18.1.1"),
    Tweak(id: "ai_enabler",        name: "Apple Intelligence",            description: "Enable Apple Intelligence on any device.",                      category: .gestalt,    type: .toggle,  key: "A62OafQ85EJAiiqKn4agtg", iOSMin: "18.1", iOSMax: "18.1.1"),
    Tweak(id: "boot_chime",        name: "Boot Chime",                    description: "Play the classic Apple startup chime.",                         category: .gestalt,    type: .toggle,  key: "njBFMx7OAF6p7vDGABCGmg", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "charge_limit",      name: "Charge Limit",                  description: "Enable the 80% charge limit option.",                           category: .gestalt,    type: .toggle,  key: "37kHRMBSBPAqtRiVJDxBuA", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "iphone_x_gestures", name: "iPhone X Gestures",             description: "Enable swipe gestures on iPhone SE.",                           category: .gestalt,    type: .toggle,  key: "YlEtTtHlNesRBOAn4OGEEw", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "tap_to_wake",       name: "Tap to Wake",                   description: "Enable tap-to-wake on unsupported devices.",                    category: .gestalt,    type: .toggle,  key: "yZf3GTRMGTuwSV9oHFmKCg", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "collision_sos",     name: "Collision SOS",                 description: "Enable crash detection on unsupported devices.",                category: .gestalt,    type: .toggle,  key: "HCzWusHQwZDea6nNhaKndw", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "stage_manager",     name: "Stage Manager",                 description: "Enable Stage Manager multitasking.",                            category: .gestalt,    type: .toggle,  key: "qizCHB5GCbjsNMXRHhSAFw", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "no_parallax",       name: "Disable Parallax",              description: "Remove wallpaper parallax effect.",                             category: .gestalt,    type: .toggle,  key: "UIParallaxCapability",   iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "region_free",       name: "No Region Restrictions",        description: "Remove region locks (e.g. shutter sound).",                     category: .gestalt,    type: .toggle,  key: "zHeENZu+wbg7JXItiWBMhQ", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "pencil_settings",   name: "Apple Pencil Settings",         description: "Show Apple Pencil options in Settings.",                        category: .gestalt,    type: .toggle,  key: "yhHcB0zwd7LAjHy3jPZtQg", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "action_button",     name: "Action Button Settings",        description: "Show Action Button page in Settings.",                          category: .gestalt,    type: .toggle,  key: "cT44WE1EohiwRzhsHSEq+Q", iOSMin: "17.0", iOSMax: "18.1.1"),
    Tweak(id: "suppress_di",       name: "Suppress Dynamic Island",       description: "Completely hide the Dynamic Island. (26.2+)",                   category: .gestalt,    type: .toggle,  key: "SuppressDynamicIsland",  iOSMin: "26.2", iOSMax: nil),
    Tweak(id: "solarium",          name: "Force Solarium Fallback",       description: "Disable Liquid Glass effects. (iOS 26+)",                       category: .gestalt,    type: .toggle,  key: "SAGvsp6O6kAQ4fEfDJpC4Q", iOSMin: "26.0", iOSMax: nil),
    // Chris-only
    Tweak(id: "pro_motion",        name: "Force 120Hz ProMotion",         description: "Force 120Hz on non-Pro devices.",                               category: .gestalt,    type: .toggle,  key: "ProMotionCapability",    iOSMin: "17.0", iOSMax: "18.1.1", isChrisOnly: true),
    Tweak(id: "spatial_audio",     name: "Spatial Audio Everywhere",      description: "Enable Spatial Audio on any device.",                           category: .gestalt,    type: .toggle,  key: "SpatialAudioCapability", iOSMin: "17.0", iOSMax: nil,      isChrisOnly: true),
    Tweak(id: "satellite_sos",     name: "Emergency SOS via Satellite",   description: "Enable satellite SOS on unsupported devices.",                  category: .gestalt,    type: .toggle,  key: "SatelliteSOSCapability", iOSMin: "17.0", iOSMax: "18.1.1", isChrisOnly: true),
    Tweak(id: "pencil_pro",        name: "Apple Pencil Pro Settings",     description: "Show Pencil Pro squeeze & barrel roll options.",                 category: .gestalt,    type: .toggle,  key: "PencilProCapability",    iOSMin: "17.0", iOSMax: "18.1.1", isChrisOnly: true),

    // ── Status Bar ────────────────────────────────────────────────────────────
    Tweak(id: "carrier_name",      name: "Carrier Name",                  description: "Override the carrier name text.",                               category: .statusBar,  type: .text(placeholder: "e.g. Chris Mobile"),     key: "CarrierName",      iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "secondary_carrier", name: "Secondary Carrier",             description: "Override the secondary carrier name.",                          category: .statusBar,  type: .text(placeholder: "Secondary carrier"),      key: "SecondaryCarrier", iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "time_text",         name: "Time Text",                     description: "Override the clock display.",                                   category: .statusBar,  type: .text(placeholder: "e.g. 9:41"),              key: "TimeText",         iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "wifi_bars",         name: "WiFi Bars",                     description: "Override the number of WiFi bars (0–3).",                       category: .statusBar,  type: .stepper(min: 0, max: 3),                     key: "WiFiBars",         iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "cell_bars",         name: "Cellular Bars",                 description: "Override the number of cell bars (0–3).",                       category: .statusBar,  type: .stepper(min: 0, max: 3),                     key: "CellularBars",     iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "battery_capacity",  name: "Battery Display %",             description: "Override the displayed battery percentage.",                    category: .statusBar,  type: .stepper(min: 0, max: 100),                   key: "BatteryCapacity",  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "breadcrumb",        name: "Breadcrumb Text",               description: "Override the back navigation breadcrumb.",                      category: .statusBar,  type: .text(placeholder: "Back"),                   key: "BreadcrumbText",   iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "hide_battery",      name: "Hide Battery Icon",             description: "Remove battery icon from status bar.",                          category: .statusBar,  type: .toggle,                                      key: "HideBattery",      iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "hide_wifi",         name: "Hide WiFi Icon",                description: "Remove WiFi icon from status bar.",                             category: .statusBar,  type: .toggle,                                      key: "HideWiFi",         iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "hide_cell",         name: "Hide Cellular Icon",            description: "Remove cellular icon from status bar.",                         category: .statusBar,  type: .toggle,                                      key: "HideCellular",     iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "numeric_signal",    name: "Numeric Signal Strength",       description: "Show dBm instead of bars.",                                     category: .statusBar,  type: .toggle,                                      key: "NumericStrength",  iOSMin: "17.0", iOSMax: nil),
    // Chris-only
    Tweak(id: "hide_clock",        name: "Hide Clock",                    description: "Remove the clock from status bar entirely.",                    category: .statusBar,  type: .toggle,                                      key: "HideClock",        iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "custom_batt_text",  name: "Custom Battery Text",           description: "Show custom text instead of battery %.",                        category: .statusBar,  type: .text(placeholder: "e.g. ∞"),                 key: "CustomBattText",   iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),

    // ── Springboard ───────────────────────────────────────────────────────────
    Tweak(id: "lock_footnote",     name: "Lock Screen Footnote",          description: "Custom text shown on the lock screen.",                         category: .springboard, type: .text(placeholder: "My iPhone"),              key: "SBLockFootnote",   iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "no_dim_charging",   name: "No Dim While Charging",         description: "Keep screen bright while plugged in.",                          category: .springboard, type: .toggle,                                      key: "SBNoDimCharging",  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "no_low_batt",       name: "Disable Low Battery Alerts",    description: "Silence low battery warnings.",                                 category: .springboard, type: .toggle,                                      key: "SBNoLowBattAlert", iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "airdrop_limit",     name: "Disable AirDrop Time Limit",    description: "Remove AirDrop 'share to everyone' timer.",                     category: .springboard, type: .toggle,                                      key: "SBAirDropLimit",   iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "di_screenshots",    name: "Dynamic Island in Screenshots", description: "Include DI area in screenshots.",                               category: .springboard, type: .toggle,                                      key: "SBDIScreenshots",  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "supervision_text",  name: "Supervision Text",              description: "Show supervision message on lock screen.",                      category: .springboard, type: .text(placeholder: "Supervised by…"),         key: "SBSupervision",    iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "auth_line",         name: "Auth Line on Lock Screen",      description: "Show red/green authentication status line.",                    category: .springboard, type: .toggle,                                      key: "SBAuthLine",       iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "no_float_tab",      name: "Disable Floating Tab Bar",      description: "Pin the tab bar on iPads.",                                     category: .springboard, type: .toggle,                                      key: "SBNoFloatTab",     iOSMin: "17.0", iOSMax: nil),
    // Chris-only
    Tweak(id: "hide_dock",         name: "Hide Dock",                     description: "Make the dock invisible.",                                      category: .springboard, type: .toggle,                                      key: "SBHideDock",       iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "hide_home_bar",     name: "Hide Home Bar",                 description: "Remove the home indicator bar.",                                category: .springboard, type: .toggle,                                      key: "SBHideHomeBar",    iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "hide_icon_labels",  name: "Hide App Icon Labels",          description: "Remove text labels under app icons.",                           category: .springboard, type: .toggle,                                      key: "SBHideIconLabels", iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "wifi_sleep",        name: "Never Drop WiFi on Sleep",      description: "Keep WiFi active when screen is off.",                          category: .springboard, type: .toggle,                                      key: "SBPersistWiFi",    iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),

    // ── Daemons ───────────────────────────────────────────────────────────────
    Tweak(id: "kill_ota",          name: "Disable OTA Updates",           description: "Stop automatic iOS update downloads.",                          category: .daemons,    type: .toggle,  key: "com.apple.mobile.softwareupdated", iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_usage",        name: "Disable Usage Tracking",        description: "Stop Apple analytics daemon.",                                  category: .daemons,    type: .toggle,  key: "com.apple.UsageTrackingAgent",     iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_gamecenter",   name: "Disable Game Center",           description: "Stop all Game Center services.",                                category: .daemons,    type: .toggle,  key: "com.apple.gamed",                  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_screentime",   name: "Disable Screen Time",           description: "Stop Screen Time monitoring.",                                  category: .daemons,    type: .toggle,  key: "com.apple.ScreenTimeAgent",        iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_spotlight",    name: "Disable Spotlight",             description: "Stop Spotlight indexing daemon.",                               category: .daemons,    type: .toggle,  key: "com.apple.spotlightd",             iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_tips",         name: "Disable Tips Daemon",           description: "Stop Tips app suggestion daemon.",                              category: .daemons,    type: .toggle,  key: "com.apple.tipsd",                  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_vpn",          name: "Disable VPN Daemon",            description: "Stop built-in VPN services.",                                   category: .daemons,    type: .toggle,  key: "com.apple.vpnd",                   iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_healthkit",    name: "Disable HealthKit",             description: "Stop HealthKit background daemon.",                             category: .daemons,    type: .toggle,  key: "com.apple.healthd",                iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_icloud",       name: "Disable iCloud Sync",           description: "Stop iCloud background sync daemon.",                           category: .daemons,    type: .toggle,  key: "com.apple.cloudd",                 iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_hotspot",      name: "Disable Personal Hotspot",      description: "Stop internet tethering daemon.",                               category: .daemons,    type: .toggle,  key: "com.apple.InternetTethering",      iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_passbook",     name: "Disable Wallet/Passbook",       description: "Stop Wallet background daemon.",                                category: .daemons,    type: .toggle,  key: "com.apple.passd",                  iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_voicecontrol", name: "Disable Voice Control",         description: "Stop Voice Control daemon.",                                    category: .daemons,    type: .toggle,  key: "com.apple.voicecontrol",           iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "kill_thermal",      name: "Disable Thermal Monitor",       description: "Stop thermal throttle daemon. DANGEROUS.",                      category: .daemons,    type: .toggle,  key: "com.apple.thermalmonitord",        iOSMin: "17.0", iOSMax: nil, isRisky: true),
    // Chris-only
    Tweak(id: "kill_siri",         name: "Disable Siri",                  description: "Stop all Siri background services.",                            category: .daemons,    type: .toggle,  key: "com.apple.siri",                   iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "kill_adservices",   name: "Disable Ad Services",           description: "Stop Apple advertising attribution.",                           category: .daemons,    type: .toggle,  key: "com.apple.adservicesd",            iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "kill_suggestions",  name: "Disable Siri Suggestions",      description: "Stop proactive suggestion daemon.",                             category: .daemons,    type: .toggle,  key: "com.apple.suggestions",            iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "kill_findmy",       name: "Disable Find My Friends",       description: "Stop Find My location sharing daemon.",                         category: .daemons,    type: .toggle,  key: "com.apple.followup",               iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),

    // ── Internal Flags ────────────────────────────────────────────────────────
    Tweak(id: "build_statusbar",   name: "Build Version in Status Bar",   description: "Show iOS build string in the status bar.",                      category: .internalFlags, type: .toggle, key: "InternalBuild",       iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "metal_hud",         name: "Metal GPU HUD",                 description: "Show the Metal GPU performance overlay.",                       category: .internalFlags, type: .toggle, key: "MetalForceHUDEnabled",iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "key_flick",         name: "iPad Keyboard on iPhone",       description: "Enable iPad-style key flick typing on iPhones.",                category: .internalFlags, type: .toggle, key: "KeyFlickInput",       iOSMin: "17.0", iOSMax: "26.0"),
    Tweak(id: "rtl_force",         name: "Force Right-to-Left Layout",    description: "Force RTL UI direction.",                                       category: .internalFlags, type: .toggle, key: "NSForceRTL",          iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "appstore_debug",    name: "App Store Debug Gesture",       description: "Enable hidden App Store debug gesture.",                        category: .internalFlags, type: .toggle, key: "AppStoreDebugGesture",iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "paste_sound",       name: "Play Sound on Paste",           description: "Play a chime when pasting content.",                            category: .internalFlags, type: .toggle, key: "PlaySoundOnPaste",    iOSMin: "17.0", iOSMax: nil),
    Tweak(id: "ignore_build",      name: "Ignore Liquid Glass Build Check",description: "Skip compatibility check for Liquid Glass apps.",              category: .internalFlags, type: .toggle, key: "IgnoreSolariumCheck", iOSMin: "26.0", iOSMax: nil),
    // Chris-only
    Tweak(id: "force_dark",        name: "Force System Dark Mode",        description: "Lock the entire system into dark mode.",                        category: .internalFlags, type: .toggle, key: "ForceDarkMode",       iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
    Tweak(id: "anim_speed",        name: "UI Animation Speed",            description: "Speed multiplier for all UI animations (0.1–2.0).",             category: .internalFlags, type: .text(placeholder: "e.g. 0.5"),            key: "UIAnimSpeed",    iOSMin: "17.0", iOSMax: nil, isChrisOnly: true),
]
