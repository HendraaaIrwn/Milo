# MILO

MILO is a tiny macOS desktop companion for developers. It lives as a floating pet on your desktop, reacts with small animations, follows your cursor, gives playful encouragement, and stays out of the way while you work.

The project is built with SwiftUI + AppKit and is designed around a local-first, privacy-first desktop experience.

## Status

MILO is an early prototype. The current app includes the floating companion, menu bar controls, mood animations, cursor eye-following, Pomodoro controls, local reminder entry, settings, and playful reaction bubbles.

Some larger PRD items, such as AI-agent status integrations, coding metrics, reaction history, and global typing detection, are planned or partially designed but not fully shipped in the current codebase.

## Features

- **Floating desktop pet** — borderless transparent `NSPanel`, always on top, draggable, and hidden from the Dock.
- **Menu bar controller** — show/hide MILO, start/pause/resume Pomodoro, add reminders, open settings, or quit.
- **Cursor eye follow** — MILO's pupils track mouse movement using an AppKit-backed SwiftUI tracking view.
- **Mood animations** — idle, typing, happy, confused, sleepy, reminder, and focus animation states.
- **Blink system** — randomized blinking with open, half-closed, and closed eye assets.
- **Reaction bubbles** — click MILO to show short developer-themed encouragement or soft roast lines.
- **Pomodoro helper** — local 25-minute focus timer with pause/resume behavior.
- **Local reminders** — add reminder text and due time from a small AppKit-hosted SwiftUI window.
- **Settings window** — toggles for launch behavior, eye follow, typing reaction flag, sound flag, and break nudges.
- **Privacy-first direction** — no cloud login or telemetry in current implementation.

## Screens and Controls

### Menu Bar

MILO runs as a menu bar utility app. The menu includes:

- `Show Milo`
- `Hide Milo`
- `Start Pomodoro` / `Pause Pomodoro` / `Resume Pomodoro`
- `Add Reminder`
- `Settings`
- `Quit`

### Floating Window

The companion window uses a non-activating floating panel so MILO can stay visible without stealing focus from IDEs or terminal windows.

### Settings

Settings are stored with `@AppStorage` / `UserDefaults` and currently include:

- `Show Milo on Launch`
- `Eye Follow Cursor`
- `Typing Reaction`
- `Sound Enabled`
- `Break Nudges Enabled`

## Project Structure

```text
Milo/
├── Milo.xcodeproj
├── MILO_PRD.md
├── README.md
└── Milo/
    ├── App/
    │   ├── AppDelegate.swift
    │   ├── MenuBarController.swift
    │   ├── MiloApp.swift
    │   ├── MiloWindowController.swift
    │   ├── PomodoroService.swift
    │   ├── ReminderEntryView.swift
    │   ├── ReminderService.swift
    │   └── SettingsView.swift
    ├── Core/
    │   └── AppState.swift
    ├── Features/
    │   ├── Chat/
    │   ├── Companion/
    │   │   ├── Animations/
    │   │   ├── Blink/
    │   │   ├── Character/
    │   │   ├── Models/
    │   │   └── Views/
    │   └── MouseTracking/
    └── Resources/
        └── Assets.xcassets/
```

## Architecture Notes

### AppKit shell

`AppDelegate` starts MILO as an accessory app and owns the menu bar, floating window, Pomodoro service, and reminder service.

`MiloWindowController` creates a transparent `NSPanel` configured as:

- borderless,
- non-activating,
- floating level,
- clear background,
- all-spaces capable,
- draggable through the hosting view.

### SwiftUI companion

`MiloRootView` renders the live floating character. It combines:

- `MiloCharacter` for the pet body, eyes, pupils, and mouth,
- `TrackingMouseView` for cursor tracking,
- `MiloReactionBubbleView` for short chat bubbles.

### Character animation

Mood-specific animation configuration lives under `Features/Companion/Animations`. Each mood maps to a resting and active `MiloAnimationFrame`, controlling body movement, rotation, mouth scale, and pupil offset.

### Mouse tracking

`TrackingMouseView` is an `NSViewRepresentable` wrapper around `NSView`. It uses mouse tracking areas plus a lightweight 60 FPS timer to report cursor position while keeping hit testing disabled.

### Data storage

Current local persistence uses `UserDefaults` for settings and reminders. Reminder data is encoded locally as JSON.

## Requirements

- macOS target from project settings: `26.5`
- Xcode with SwiftUI and AppKit support
- Swift language version from project settings: `5.0`

> The deployment target is currently set very high for local development. Lower it in Xcode project settings if you want wider macOS compatibility.

## Build and Run

Open the project in Xcode:

```bash
open Milo.xcodeproj
```

Then choose the `Milo` scheme and run the macOS app.

CLI build example:

```bash
xcodebuild \
  -project Milo.xcodeproj \
  -scheme Milo \
  -destination 'platform=macOS,arch=arm64' \
  build
```

In restricted environments, use a writable DerivedData path:

```bash
xcodebuild \
  -project Milo.xcodeproj \
  -scheme Milo \
  -derivedDataPath /private/tmp/MiloDerivedData \
  -destination 'platform=macOS,arch=arm64' \
  build
```

## Privacy

MILO's current prototype is local-first:

- no login,
- no cloud backend,
- no analytics SDK,
- no telemetry pipeline,
- no network sync.

Planned activity-detection features should follow the same privacy rule: derive animation state from high-level activity signals, not from source code content, typed characters, clipboard data, or private user text.

## Roadmap

Based on `MILO_PRD.md`, planned areas include:

- global keyboard activity detection for typing/kneading animation,
- typing bubble dialogs based only on timing and intensity,
- reaction log with local history,
- roast tone settings,
- AI coding agent status indicators,
- break nudges,
- mood check-ins,
- local todo and natural-language reminders,
- coding metrics,
- richer animation and sound states.

## Design Principles

- Stay tiny and ambient.
- Never steal focus from the developer's active app.
- Prefer local-first state.
- Keep reactions playful, not noisy.
- Treat privacy as a product feature, not a disclaimer.

## License

No license file is included yet. Add one before distributing or accepting external contributions.
