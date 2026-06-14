# MILO Coding Metrics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Gunakan `superpowers:subagent-driven-development` (recommended) atau `superpowers:executing-plans` untuk implementasi task-by-task. Steps menggunakan checkbox syntax (`- [ ]`).

**Goal:** Menambahkan fitur WakaTime-style coding metrics & LOC tracking yang local-first, privacy-friendly, dan terintegrasi ke floating pet MILO.

**Architecture:** Membuat feature module `CodingMetrics` di bawah `Milo/App/Features/CodingMetrics/` dengan model-model Codable, service-service tracker (active app, project, language, Git LOC, session), WakaTime client optional, dan SwiftUI views. Service utama di-inject dari `AppDelegate` ke `MiloWindowController`, `MenuBarController`, dan `MiloRootView`. Data lokal disimpan via `MiloLocalStorageService` (JSON-over-UserDefaults), API key WakaTime disimpan di Keychain.

**Tech Stack:** Swift 5, SwiftUI, AppKit, Foundation, Security (Keychain), URLSession.

---

## Hasil Eksplorasi Codebase

Struktur aktual MILO:

- Xcode project (`Milo.xcodeproj`), bukan SPM.
- Source utama di `Milo/App/`.
- Feature modules ada di `Milo/App/Features/{Pomodoro,Reminder,Todo,Settings,Companion}/`.
- Dependency injection manual di `AppDelegate.swift`.
- Persistence via `MiloLocalStorageService` (UserDefaults + JSON).
- **Belum ada Keychain.**
- **App Sandbox aktif** (`ENABLE_APP_SANDBOX = YES`), tanpa entitlements file kustom.
- Tidak ada test target.

## Keputusan Final

1. **Opsi A: Disable App Sandbox** — Ubah `ENABLE_APP_SANDBOX = NO` di `project.pbxproj`.
2. **Struktur `App/Features/CodingMetrics/`** mengikuti pola existing.
3. **Tidak ada unit tests / TDD** — verifikasi via build + manual test.
4. **File watcher ditunda** — LOC hanya dari Git diff working tree dan Git commits hari ini.
5. **WakaTime auth fix** — Gunakan `Basic base64(apiKey:)` bukan `Basic base64(apiKey)`.

## Struktur File

### File Baru

Dibuat di `Milo/App/Features/CodingMetrics/` mengikuti pola existing:

- `Models/LOCSummary.swift`
- `Models/CodingLanguageMetric.swift`
- `Models/CodingProjectMetric.swift`
- `Models/EditorUsageMetric.swift`
- `Models/CodingSession.swift`
- `Models/CodingMetricsSnapshot.swift`
- `Models/WakaTimeSummary.swift`
- `Services/ActiveAppDetector.swift`
- `Services/ActiveProjectDetector.swift`
- `Services/LanguageEstimator.swift`
- `Services/GitLOCTracker.swift`
- `Services/CodingMetricsService.swift`
- `Services/WakaTimeClient.swift`
- `Services/CodingMetricsCoordinator.swift`
- `Views/CodingMetricsBadgeView.swift`
- `Views/CodingMetricsPanelView.swift`
- `Views/LOCSummaryView.swift`
- `Views/CodingMetricsSettingsView.swift`

File Keychain:

- `Milo/App/Core/Persistence/KeychainService.swift`

### File Diubah

- `Milo/App/Core/Persistence/MiloStorageKeys.swift`
- `Milo/App/Features/Settings/Views/SettingsView.swift`
- `Milo/App/Features/Settings/Views/PrivacySettingsView.swift`
- `Milo/App/Application/AppDelegate.swift`
- `Milo/App/Application/MenuBarController.swift`
- `Milo/App/Application/MiloWindowController.swift`
- `Milo/App/Features/Companion/Views/MiloRootView.swift`
- `Milo.xcodeproj/project.pbxproj`

---

## Tasks

### Task 1: Models

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Models/LOCSummary.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/CodingLanguageMetric.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/CodingProjectMetric.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/EditorUsageMetric.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/CodingSession.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/CodingMetricsSnapshot.swift`
- Create: `Milo/App/Features/CodingMetrics/Models/WakaTimeSummary.swift`

- [ ] **Step 1.1:** Salin kode model dari PRD ke masing-masing file.
- [ ] **Step 1.2:** Perbaiki `CodingMetricsSnapshot.makeDateKey` agar zero-padded:

```swift
static func makeDateKey(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
```

- [ ] **Step 1.3:** Build untuk memastikan tidak ada compile error model.

Run: `bash script/build_and_run.sh`
Expected: Build sukses.

### Task 2: Storage Keys & Keychain

**Files:**
- Modify: `Milo/App/Core/Persistence/MiloStorageKeys.swift`
- Create: `Milo/App/Core/Persistence/KeychainService.swift`

- [ ] **Step 2.1:** Tambah keys ke `MiloStorageKeys`:

```swift
static let codingMetricsSnapshot = "Milo.CodingMetrics.Snapshot"
static let codingMetricsEnabled = "Milo.CodingMetrics.Enabled"
static let codingMetricsShowBadge = "Milo.CodingMetrics.ShowBadge"
static let localProjectPaths = "Milo.CodingMetrics.ProjectPaths"
static let wakaTimeEnabled = "Milo.WakaTime.Enabled"
```

- [ ] **Step 2.2:** Buat `KeychainService.swift` persis seperti PRD.
- [ ] **Step 2.3:** Build.

### Task 3: Detectors & Estimator

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Services/ActiveAppDetector.swift`
- Create: `Milo/App/Features/CodingMetrics/Services/ActiveProjectDetector.swift`
- Create: `Milo/App/Features/CodingMetrics/Services/LanguageEstimator.swift`

- [ ] **Step 3.1:** Salin kode PRD.
- [ ] **Step 3.2:** Build.

### Task 4: Git LOC Tracker

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Services/GitLOCTracker.swift`

- [ ] **Step 4.1:** Salin kode PRD.
- [ ] **Step 4.2:** Tambah ignore untuk `.pbxproj` dan `.generated.`:

```swift
static let ignoredFilenameFragments = [
    ".generated.",
    ".min.js",
    ".min.css",
    ".pbxproj"
]
```

- [ ] **Step 4.3:** Build.

### Task 5: Coding Metrics Service

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Services/CodingMetricsService.swift`

- [ ] **Step 5.1:** Salin kode PRD.
- [ ] **Step 5.2:** Build.

### Task 6: WakaTime Client

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Services/WakaTimeClient.swift`

- [ ] **Step 6.1:** Salin kode PRD.
- [ ] **Step 6.2:** Perbaiki auth header WakaTime:

```swift
let credentials = "\(apiKey):".data(using: .utf8)?.base64EncodedString() ?? ""
request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
```

- [ ] **Step 6.3:** Build.

### Task 7: Coding Metrics Coordinator

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Services/CodingMetricsCoordinator.swift`

- [ ] **Step 7.1:** Salin kode PRD.
- [ ] **Step 7.2:** Build.

### Task 8: SwiftUI Views

**Files:**
- Create: `Milo/App/Features/CodingMetrics/Views/LOCSummaryView.swift`
- Create: `Milo/App/Features/CodingMetrics/Views/CodingMetricsBadgeView.swift`
- Create: `Milo/App/Features/CodingMetrics/Views/CodingMetricsPanelView.swift`
- Create: `Milo/App/Features/CodingMetrics/Views/CodingMetricsSettingsView.swift`

- [ ] **Step 8.1:** Buat `LOCSummaryView.swift` persis PRD.
- [ ] **Step 8.2:** Buat `CodingMetricsBadgeView.swift` persis PRD.
- [ ] **Step 8.3:** Buat `CodingMetricsPanelView.swift` persis PRD, tambah project paths management.
- [ ] **Step 8.4:** Buat `CodingMetricsSettingsView.swift` dengan:
  - Toggle enable coding metrics
  - Toggle show badge
  - WakaTime enable toggle
  - SecureField API key
  - Save/Remove API key buttons
  - Project paths picker (Add/Remove)
  - Privacy notes
- [ ] **Step 8.5:** Build.

### Task 9: Disable App Sandbox

**Files:**
- Modify: `Milo.xcodeproj/project.pbxproj`

- [ ] **Step 9.1:** Ubah `ENABLE_APP_SANDBOX = NO` di kedua build configuration (Debug & Release).
- [ ] **Step 9.2:** Build.

### Task 10: Integrasi Settings Tab

**Files:**
- Modify: `Milo/App/Features/Settings/Views/SettingsView.swift`

- [ ] **Step 10.1:** Ganti placeholder "Coding metrics placeholder" dengan `CodingMetricsSettingsView()`.
- [ ] **Step 10.2:** Build.

### Task 11: Integrasi Privacy Settings

**Files:**
- Modify: `Milo/App/Features/Settings/Views/PrivacySettingsView.swift`

- [ ] **Step 11.1:** Tambah section baru "Coding Metrics" yang menjelaskan data yang disimpan dan tidak disimpan.
- [ ] **Step 11.2:** Build.

### Task 12: Integrasi AppDelegate

**Files:**
- Modify: `Milo/App/Application/AppDelegate.swift`

- [ ] **Step 12.1:** Tambah property:

```swift
private var codingMetricsService: CodingMetricsService?
private var codingMetricsCoordinator: CodingMetricsCoordinator?
```

- [ ] **Step 12.2:** Di `applicationDidFinishLaunching`, setelah `pomodoroService`:

```swift
let codingMetricsService = CodingMetricsService()
let codingMetricsCoordinator = CodingMetricsCoordinator(
    localMetricsService: codingMetricsService
)
self.codingMetricsService = codingMetricsService
self.codingMetricsCoordinator = codingMetricsCoordinator
```

- [ ] **Step 12.3:** Inject ke `MiloWindowController` dan `MenuBarController`.
- [ ] **Step 12.4:** Di `applicationWillTerminate`:

```swift
codingMetricsCoordinator?.stop()
codingMetricsService?.save()
```

- [ ] **Step 12.5:** Build.

### Task 13: Integrasi MiloWindowController

**Files:**
- Modify: `Milo/App/Application/MiloWindowController.swift`

- [ ] **Step 13.1:** Tambah property dan parameter `codingMetricsCoordinator`.
- [ ] **Step 13.2:** Tambah method `openCodingMetricsPanel()`.
- [ ] **Step 13.3:** Tambah callbacks `onOpenCodingMetrics` dan `onResetCodingMetrics` ke `MiloRootView`.
- [ ] **Step 13.4:** Build.

### Task 14: Integrasi MenuBarController

**Files:**
- Modify: `Milo/App/Application/MenuBarController.swift`

- [ ] **Step 14.1:** Tambah parameter dan property `codingMetricsCoordinator`.
- [ ] **Step 14.2:** Tambah menu items "Coding Metrics" dan "Reset Local Coding Stats".
- [ ] **Step 14.3:** Tambah methods `openCodingMetrics()` dan `resetCodingMetrics()`.
- [ ] **Step 14.4:** Build.

### Task 15: Integrasi MiloRootView

**Files:**
- Modify: `Milo/App/Features/Companion/Views/MiloRootView.swift`

- [ ] **Step 15.1:** Tambah property `codingMetricsCoordinator`, `showCodingMetricsBadge`, dan callbacks.
- [ ] **Step 15.2:** Tambah badge di bawah Pomodoro badge.
- [ ] **Step 15.3:** Tambah context menu items.
- [ ] **Step 15.4:** Update preview dan call sites.
- [ ] **Step 15.5:** Build.

### Task 16: Final Integration & Verification

- [ ] **Step 16.1:** Pastikan semua file ditambahkan ke Xcode target (pbxproj).
- [ ] **Step 16.2:** Build clean: `bash script/build_and_run.sh --verify`
- [ ] **Step 16.3:** Test tanpa WakaTime API key.
- [ ] **Step 16.4:** Test dengan WakaTime API key (jika ada).
- [ ] **Step 16.5:** Test reset local stats.
- [ ] **Step 16.6:** Test right-click menu dan menu bar.

---

## Spec Coverage Checklist

| Requirement | Task |
|---|---|
| Local coding time tracking | Task 5 |
| Active app/editor detection | Task 3 |
| Active project detection | Task 3 |
| Language estimation from extension | Task 3 |
| LOC from Git diff working tree | Task 4 |
| LOC from Git commits today | Task 4 |
| Session summary | Task 5 |
| WakaTime API key di Keychain | Task 2, 6, 8 |
| WakaTime summary fetch | Task 6, 7 |
| UI display semua metrik | Task 8 |
| LOC added/deleted/net | Task 4, 8 |
| Source label Local/WakaTime/Local+WakaTime | Task 7, 8 |
| Ignore folder seperti node_modules | Task 4 |
| User bisa reset local stats | Task 8, 13, 14, 15 |
| Local stats tersimpan | Task 5 |
| Jangan simpan isi source code | Task 4 (hanya shortstat/numstat) |
| Jangan upload local data | Tidak ada upload |
| Tidak ada telemetry | Tidak ada |
| UI panel dari menu bar & right-click | Task 13, 14, 15 |
| Badge kecil dekat MILO | Task 8, 15 |
