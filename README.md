# Chris
### Unlock the fullest potential of your device

A native iOS SwiftUI app — like Nugget Mobile but with more tweaks, better design, and Chris-exclusive features.

> ⚠️ Back up your device before use. Not responsible for any issues.

---

## Requirements to Build

- **Mac** with macOS 13+
- **Xcode 15+** (free from App Store)
- **Apple Developer Account** (free account works for sideloading)
- iPhone running **iOS 16.0 – 18.1.1** (SparseRestore) or up to iOS 26.x when BookRestore is implemented

---

## How to Build & Install

### 1. Clone the repo
```bash
git clone https://github.com/your-username/Chris
cd Chris
open Chris.xcodeproj
```

### 2. Set your signing team
- In Xcode, click the **Chris** project in the sidebar
- Go to **Signing & Capabilities**
- Set **Team** to your Apple ID
- Change the **Bundle Identifier** to something unique like `com.yourname.chris`

### 3. Build & run
- Connect your iPhone via USB
- Select your device in Xcode's device picker
- Press **⌘R** to build and install

### 4. Trust the app on your iPhone
Go to **Settings → General → VPN & Device Management** → tap your developer profile → Trust

---

## Using Chris

### Step 1 — Get your pairing file
1. Download [jitterbugpair](https://github.com/osy/Jitterbug/releases/latest) on your computer
2. Run it with your iPhone connected
3. AirDrop the `.mobiledevicepairing` file to your iPhone
4. Open Chris and tap **Pairing File** → select it

### Step 2 — Get your MobileGestalt file (iOS 26.1 and below)
1. Install [Shortcuts](https://apps.apple.com/us/app/shortcuts/id915249334)
2. Download this shortcut: [Save MobileGestalt](https://www.icloud.com/shortcuts/66bd3c822a0145b98d46cd1c9077e6e5)
3. Run it and save the file
4. Open Chris and tap **MobileGestalt** → select it

### Step 3 — Set up WireGuard
1. Install [WireGuard](https://apps.apple.com/us/app/wireguard/id1441195209)
2. Download [SideStore's config](https://github.com/sidestore/sidestore/releases/download/0.1.1/sidestore.conf)
3. Import it into WireGuard and **enable the tunnel**

### Step 4 — Apply tweaks
1. Enable the tweaks you want in Chris
2. Tap **Apply Tweaks**
3. Respring when done

---

## Features

### 🔮 Hidden Features (19 tweaks — 4 Chris-exclusive)
| Tweak | iOS Range | Exclusive |
|---|---|---|
| Dynamic Island on any device | 17.0–18.1.1 | |
| Always-On Display | 18.0–18.1.1 | |
| Apple Intelligence | 18.1–18.1.1 | |
| Boot Chime | 17.0–18.1.1 | |
| Charge Limit | 17.0–18.1.1 | |
| Force 120Hz ProMotion | 17.0–18.1.1 | ⭐ |
| Spatial Audio Everywhere | 17.0+ | ⭐ |
| Emergency SOS via Satellite | 17.0–18.1.1 | ⭐ |
| Apple Pencil Pro Settings | 17.0–18.1.1 | ⭐ |
| + 10 more... | | |

### 📶 Status Bar (13 tweaks — 2 Chris-exclusive)
Carrier name, battery %, WiFi/cell bars, clock text, hide any icon, custom battery text ⭐, hide clock ⭐

### 🖥 Springboard (12 tweaks — 4 Chris-exclusive)
Lock screen footnote, no dim while charging, hide dock ⭐, hide home bar ⭐, hide icon labels ⭐, persistent WiFi ⭐

### ⚡ Daemons (17 tweaks — 4 Chris-exclusive)
Disable OTA, Game Center, Screen Time, Siri ⭐, Ad Services ⭐, Find My Friends ⭐, Suggestions ⭐, and more

### ⚙ Internal Flags (9 tweaks — 2 Chris-exclusive)
Metal HUD, iPad keyboard, force dark mode ⭐, animation speed ⭐, build in status bar, and more

---

## Adding the C Libraries (for full functionality)

Chris needs the same C libraries as Nugget Mobile:

```bash
# Clone the helper script from Nugget Mobile
curl -O https://raw.githubusercontent.com/leminlimez/Nugget-Mobile/main/get_libraries.sh
chmod +x get_libraries.sh
./get_libraries.sh
```

This downloads:
- `minimuxer` — local mux for device connection
- `libimobiledevice` — device communication
- `em_proxy` — SideStore's network proxy

Add the resulting `.dylib` files to your Xcode project under **Frameworks, Libraries, and Embedded Content**.

---

## Project Structure

```
Chris/
├── Chris.xcodeproj
├── entitlements.plist
└── Chris/
    ├── ChrisApp.swift          ← App entry point
    ├── Info.plist
    ├── Models/
    │   ├── TweakModel.swift    ← All tweak definitions (60+ tweaks)
    │   └── TweakManager.swift  ← State management
    ├── Views/
    │   ├── ContentView.swift   ← Main layout
    │   └── TweakListView.swift ← Tweak rows & controls
    ├── Restore/
    │   └── RestoreEngine.swift ← SparseRestore/BookRestore bridge
    └── Helpers/
        └── ColorHelpers.swift  ← Color utilities
```

---

## Credits

- [leminlimez/Nugget](https://github.com/leminlimez/Nugget) — original inspiration
- [JJTech](https://github.com/JJTech0130) — SparseRestore / TrollRestore
- [khanhduytran0](https://github.com/khanhduytran0) — BookRestore / SparseBox
- [SideStore](https://sidestore.io/) — minimuxer and em_proxy
- [pymobiledevice3](https://github.com/doronz88/pymobiledevice3) — device protocol reference

## License
MIT
