<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)">
    <img src="docs/assets/milo-banner.png" width="600" alt="MILO — Tiny Coding Companion">
  </picture>
</p>

<p align="center">
  <strong>🐾 A tiny floating desktop companion for developers.</strong>
  <br>
  <em>Reacts to your coding, keeps you focused, reminds you to breathe —</em>
  <br>
  <em>all offline, all local, all privacy-first.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-26.5%2B-white?logo=apple" alt="macOS 26.5+">
  <img src="https://img.shields.io/badge/Swift-5.0-FA7343?logo=swift" alt="Swift 5.0">
  <img src="https://img.shields.io/badge/platform-desktop-lightgrey" alt="Platform Desktop">
  <img src="https://img.shields.io/badge/privacy-first-green" alt="Privacy First">
  <img src="https://img.shields.io/badge/local--only-blue" alt="Local Only">
</p>

---

## ✨ What is MILO?

MILO is a tiny desktop pet that **lives on your screen** while you code. It animates, blinks, follows your cursor, responds to your typing intensity, and quietly helps you with Pomodoro timers, reminders, todos, and now — **WakaTime-style coding metrics**.

Built with **SwiftUI + AppKit** for macOS. No cloud. No login. No telemetry. Just a small friend on your desktop.

<table>
<tr>
<td width="50%">

**🐾 Companion**
- Floating, borderless, draggable pet
- Eye tracking follows your cursor
- Mood animations (idle, typing, happy, sleepy, focus…)
- Random blink engine
- Click to get developer reactor lines

</td>
<td width="50%">

**⏱️ Productivity**
- Pomodoro timer (25/5, 50/10, 90/15)
- Timer badge under MILO
- Local reminders with snooze & reschedule
- Local todo list with overdue detection
- Break nudge system

</td>
</tr>
<tr>
<td width="50%">

**📊 Coding Metrics** <sup><code>new</code></sup>
- Tracks active coding time
- Detects editor (Xcode, VS Code, Cursor, Terminal…)
- Estimates top language from file extensions
- Git LOC: lines added/deleted from diff + commits
- Ignores `node_modules`, `.git`, `build`, `dist`, etc.
- Optional WakaTime enrichment

</td>
<td width="50%">

**🔒 Privacy**
- Zero cloud / zero telemetry
- Keyboard activity: timing & intensity only
- Never reads typed characters or source code
- Git LOC from summary stats, not file content
- WakaTime API key in macOS Keychain
- All data stays on your Mac

</td>
</tr>
</table>

---

## 🖥️ Screens & Controls

### Menu Bar

| Menu Item | Action |
|---|---|
| `Show Milo` / `Hide Milo` | Toggle the floating companion |
| `Start Pomodoro ▸` | Pick timer preset |
| `Pomodoro Settings` | Custom duration config |
| `Add Reminder` | Quick reminder entry |
| `Chat Reminder` | Natural-language reminder input |
| `Reminder History` | View past reminders |
| `Add Todo` | Quick todo entry |
| `Open Todos` | Full todo list |
| `Coding Metrics` | Open metrics dashboard |
| `Reset Local Coding Stats` | Wipe today's stats |
| `Settings` | Full settings window |
| `Quit` | Exit MILO |

### Right-Click MILO

Right-click the floating pet for quick access to Pomodoro, Todos, Reminders, Coding Metrics, and Hide.

### Badges

Two compact badges appear below MILO when active:

- **🍅 Pomodoro badge** — timer countdown during focus/break
- **📊 Coding Metrics badge** — coding time today, top language, LOC

### Windows

| Window | Description |
|---|---|
| `MILO Settings` | 10-tab settings: General, Appearance, Sound, Pomodoro, Reminders, Break Nudges, Mood Check-ins, Agent Integrations, Coding Metrics, Privacy |
| `MILO Coding Metrics` | Full dashboard: coding time, language, project, editor usage, LOC breakdown, WakaTime enrichment |
| `MILO Todo List` | Full todo list with edit, delete, done, convert-to-reminder |
| `MILO Reminder History` | Past reminders with timeline |
| `MILO Chat` | Natural-language reminder/todo input |

---

## 📊 Coding Metrics

> **New in this release** — local WakaTime-style tracking with optional WakaTime API enrichment.

### Local Tracking (no API key required)

| Metric | Source |
|---|---|
| ⏱️ Coding time today | Active editor detection, 5-second tick |
| 🖥️ Active editor | `NSWorkspace.frontmostApplication` |
| 📁 Active project | User-configured folders (most recently modified) |
| 🗣️ Top language | File extension frequency from `git diff --name-only` |
| ➕ Lines added | `git diff --shortstat` + `git log --numstat` |
| ➖ Lines deleted | `git diff --shortstat` + `git log --numstat` |
| 📈 Net LOC | Added minus deleted |

### Ignored Paths

```
node_modules / .git / build / dist / DerivedData / vendor
.next / .nuxt / .svelte-kit / coverage / Pods / Carthage / .swiftpm
*.generated.* / *.min.js / *.min.css / *.pbxproj
```

### WakaTime Integration (optional)

1. Add your WakaTime API key in **Settings → Coding Metrics**
2. Key stored in macOS Keychain (not UserDefaults)
3. Fetch today's summary: time, top language, top project, editor usage
4. Displayed alongside local metrics with source label
5. Local metrics always available regardless of WakaTime status

---

## 🏗️ Project Structure

```
Milo/
├── Milo.xcodeproj
├── MILO_PRD.md
├── README.md
├── script/
│   └── build_and_run.sh
├── docs/
│   └── superpowers/plans/
└── Milo/
    ├── App/
    │   ├── Application/
    │   │   ├── AppDelegate.swift          # Composition root
    │   │   ├── MainApp.swift              # @main entry
    │   │   ├── MenuBarController.swift    # NSStatusItem & menu
    │   │   └── MiloWindowController.swift # Floating panel & child windows
    │   └── Core/
    │       ├── Models/
    │       │   └── AppState.swift
    │       ├── Persistence/
    │       │   ├── MiloLocalStorageService.swift  # JSON-over-UserDefaults
    │       │   ├── MiloStorageKeys.swift          # All storage keys
    │       │   └── KeychainService.swift          # WakaTime API key
    │       └── Services/
    │           └── MiloMumbleEngine.swift  # Procedural voice
    │
    ├── Features/
    │   ├── Chat/
    │   │   ├── Models/        # Mood ↔ dialogue mapping
    │   │   ├── Services/      # Text normalization
    │   │   └── Views/         # Chat input & bubbles
    │   ├── CodingMetrics/     # ✨ New feature module
    │   │   ├── Models/
    │   │   │   ├── LOCSummary.swift
    │   │   │   ├── CodingLanguageMetric.swift
    │   │   │   ├── CodingProjectMetric.swift
    │   │   │   ├── EditorUsageMetric.swift
    │   │   │   ├── CodingSession.swift
    │   │   │   ├── CodingMetricsSnapshot.swift
    │   │   │   └── WakaTimeSummary.swift
    │   │   ├── Services/
    │   │   │   ├── ActiveAppDetector.swift
    │   │   │   ├── ActiveProjectDetector.swift
    │   │   │   ├── LanguageEstimator.swift
    │   │   │   ├── GitLOCTracker.swift
    │   │   │   ├── CodingMetricsService.swift
    │   │   │   ├── WakaTimeClient.swift
    │   │   │   └── CodingMetricsCoordinator.swift
    │   │   └── Views/
    │   │       ├── CodingMetricsBadgeView.swift
    │   │       ├── CodingMetricsPanelView.swift
    │   │       ├── LOCSummaryView.swift
    │   │       └── CodingMetricsSettingsView.swift
    │   ├── Companion/
    │   │   ├── Animations/    # Per-mood animation configs
    │   │   ├── Blink/         # Blink timing engine
    │   │   ├── Character/     # Pet body, eyes, pupils, mouth
    │   │   ├── Models/        # Animation state, mood, reaction lines
    │   │   ├── Services/      # State store, keyboard, typing bubble
    │   │   └── Views/         # Root view, floating pet, home view
    │   ├── MouseTracking/
    │   │   └── Views/         # NSViewRepresentable cursor tracker
    │   ├── Pomodoro/
    │   │   ├── Models/        # Session, preset, stats
    │   │   ├── Services/      # Timer, sound, break nudge
    │   │   └── Views/         # Settings, control, ring, badge
    │   ├── Reminder/
    │   │   ├── Models/        # Reminder, history event
    │   │   ├── Services/      # CRUD, scheduler, notifications, NL parser
    │   │   └── Views/         # Entry, history, reschedule, bubble
    │   ├── Settings/
    │   │   ├── Models/        # Legacy audio keys
    │   │   ├── ViewModels/    # Audio settings store
    │   │   └── Views/         # Settings, privacy
    │   └── Todo/
    │       ├── Models/        # Todo
    │       ├── Services/      # CRUD, scheduler, command parser, date parser
    │       └── Views/         # List, editor, row, bubble
    │
    ├── UI/
    │   ├── Assets.xcassets/   # Character assets, icons
    │   └── Components/
    │       ├── Bubbles/       # Reaction bubble views
    │       └── Rows/          # Reminder history row
```

---

## 🔧 Architecture Notes

### AppKit Shell + SwiftUI Content

MILO uses AppKit for window management and SwiftUI for all content:

- **`AppDelegate`** — composition root. Creates all services and wires them.
- **`MenuBarController`** — `NSStatusItem` with full menu.
- **`MiloWindowController`** — manages the floating `NSPanel` (borderless, non-activating, floating level, all-spaces, clear background) plus child windows for Settings, Todos, Chat, Reminder History, Pomodoro Settings, and Coding Metrics.

### Dependency Injection

All services are created in `AppDelegate.applicationDidFinishLaunching(_:)` and passed explicitly into controllers and views. No `@EnvironmentObject` — just `@ObservedObject` and manual constructor injection.

### Data Storage

| Backend | Used For |
|---|---|
| `MiloLocalStorageService` (JSON → UserDefaults) | Reminders, todos, Pomodoro state, coding metrics snapshot |
| `@AppStorage` (UserDefaults) | Toggles: showMiloOnLaunch, eyeFollowCursor, typingReaction, sounds, badges |
| `KeychainService` (macOS Keychain) | WakaTime API key |

### Concurrency

- All services are `@MainActor` and `ObservableObject`
- Timer-based services (Pomodoro, coding metrics) use `Task { while !isCancelled }` loops
- Git LOC tracking uses `async` methods with `Task.detached` for non-blocking subprocess execution
- WakaTime API uses `async/await` URLSession

---

## 🚀 Build & Run

### Prerequisites

- macOS 26.5+
- Xcode 26+ with Swift 5.0

### Quick Start

```bash
# Clone
git clone https://github.com/hendrairawan/Milo.git
cd Milo

# Build & Run
bash script/build_and_run.sh

# Or open in Xcode
open Milo.xcodeproj
```

### CLI Build

```bash
xcodebuild \
  -project Milo.xcodeproj \
  -scheme Milo \
  -destination 'platform=macOS,arch=arm64' \
  build
```

### Custom DerivedData

```bash
xcodebuild \
  -project Milo.xcodeproj \
  -scheme Milo \
  -derivedDataPath /tmp/MiloDerivedData \
  -destination 'platform=macOS,arch=arm64' \
  build
```

---

## 🔒 Privacy

MILO is **local-first by design**:

| ✅ Stored Locally | ❌ Never Stored / Sent |
|---|---|
| Keyboard activity timing & intensity | Typed characters or key values |
| Active app name & bundle ID | Source code content |
| File extensions (language estimation) | Clipboard content |
| Git diff/numstat summaries | Keyboard history or per-key logs |
| User-configured project folder paths | File contents |
| Pomodoro sessions & stats | Any data to cloud |
| Reminders & todos | Telemetry or analytics |
| WakaTime API key (Keychain) | WakaTime API key (UserDefaults) |

> **WakaTime is read-only.** MILO fetches your summary — it never uploads local metrics to WakaTime.

---

## 🗺️ Roadmap

**✅ Done**

- [x] Floating desktop pet with cursor tracking
- [x] Mood animations & blink engine
- [x] Pomodoro timer with presets
- [x] Local reminders (NL parser, notifications, snooze, reschedule)
- [x] Local todos (overdue detection, chat input)
- [x] Global keyboard activity detection
- [x] Typing reaction bubbles
- [x] Settings (10 tabs)
- [x] **Coding metrics — local + WakaTime** ✨
- [x] **Git LOC tracking** ✨
- [x] **Keychain for WakaTime API key** ✨

**🚧 Planned**

- [ ] AI coding agent status indicators
- [ ] Reaction log with local history
- [ ] Mood check-ins
- [ ] Richer sound & animation states
- [ ] File watcher for real-time project activity
- [ ] Weekly coding metrics summary
- [ ] SQLite migration for local storage

---

## 🎨 Design Principles

> Stay tiny. Stay ambient. Never steal focus. Keep it playful.

- **Tiny & Ambient** — MILO is a small presence, not a full app window
- **Never Steals Focus** — uses `nonActivatingPanel`, floats above but passes clicks through
- **Local-First State** — everything stored on your Mac, not in the cloud
- **Playful, Not Noisy** — reactions are quick, cute, and skippable
- **Privacy as a Feature** — no login, no cloud, no telemetry, no tracking

---

## 📝 License

MIT — see [LICENSE](LICENSE) file.

---

<p align="center">
  <sub>Made with ☕️ for developers who code solo.</sub>
</p>
