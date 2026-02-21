# Chris Watch

Apple Watch companion app for Chris — control your iOS tweaks from your wrist.

---

## Features

### 3 Watch Screens (swipe between them)

**Screen 1 — Dashboard**
- Chris logo + app name
- Enabled tweak count badge
- iPhone connection status (live dot)
- Per-category summary (shows how many tweaks on per section)
- Last sync timestamp

**Screen 2 — Tweaks**
- Browse all 25 tweaks by category
- Tap the emoji tabs to switch: ✨ 📶 🏠 ⚡ ⚙️
- Toggle tweaks on/off directly on watch
- Tap text tweaks to enter a value (dictation / keyboard)
- **CHRIS** badge on Chris-exclusive tweaks

**Screen 3 — Apply**
- See how many tweaks are ready
- iPhone connection indicator
- Confirm sheet before applying (safety)
- Sends selections to iPhone app which runs the restore
- Reset all button with confirmation

### Watch Face Complications
Supports all complication families:
- Modular Small, Utilitarian Small, Circular Small
- Graphic Corner, Graphic Circular, Graphic Bezel, Graphic Rectangular
- Shows count of enabled tweaks on your watch face

---

## Adding to Xcode

### Step 1 — Add Watch Target
1. Open `Chris.xcodeproj`
2. File → New → Target → **watchOS → Watch App**
3. Name it `ChrisWatch`
4. Set **Bundle ID** to `com.yourname.chris.watchkitapp`
5. Uncheck "Include Notification Scene"

### Step 2 — Add files
Drag all files from `ChrisWatch/ChrisWatch/` into the new watch target:
- `ChrisWatchApp.swift`
- `Views/WatchContentView.swift`
- `Views/WatchDashboardView.swift`
- `Views/WatchTweakListView.swift`
- `Views/WatchApplyView.swift`
- `Models/WatchTweakStore.swift`
- `Complications/ChrisComplications.swift`

### Step 3 — Add WatchHandler to iPhone target
Add `Chris/WatchHandler.swift` to the **iPhone** Chris target (not the watch target).

### Step 4 — Set complication class
In the watch target's Info.plist, confirm:
```
CLKComplicationPrincipalClass = ChrisWatch.ChrisComplicationProvider
```

### Step 5 — Link WatchConnectivity
Both targets need `WatchConnectivity.framework`:
- iPhone target → Frameworks → + → WatchConnectivity
- Watch target → Frameworks → + → WatchConnectivity

### Step 6 — Build & run
Select the **ChrisWatch** scheme in Xcode, choose a Watch simulator or your real Apple Watch, press ⌘R.

---

## How it works

```
Apple Watch                        iPhone
─────────────────────────────────────────────────────
[User enables tweaks on Watch]
         │
         │  WCSession.sendMessage()
         ▼
[WatchHandler receives message]
         │
         │  Updates TweakManager
         ▼
[ChrisRestoreEngine.apply()]
         │
         │  minimuxer + SparseRestore
         ▼
[Files written to device]
         │
         │  reply(["success": true])
         ▼
[Watch shows "✓ Applied!"]
```

---

## Requirements
- Apple Watch Series 4+ (watchOS 9+)
- iPhone with Chris app installed and running
- WireGuard active on iPhone during apply
- Pairing file imported in iPhone app

---

## File Structure
```
ChrisWatch/
└── ChrisWatch/
    ├── ChrisWatchApp.swift          ← Entry point
    ├── Info.plist
    ├── Models/
    │   └── WatchTweakStore.swift    ← State + WatchConnectivity
    ├── Views/
    │   ├── WatchContentView.swift   ← TabView shell
    │   ├── WatchDashboardView.swift ← Home screen
    │   ├── WatchTweakListView.swift ← Browse + toggle tweaks
    │   └── WatchApplyView.swift     ← Send + confirm
    └── Complications/
        └── ChrisComplications.swift ← All watch face complications
```
