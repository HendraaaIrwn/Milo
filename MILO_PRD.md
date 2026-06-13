# PRD — MILO: Tiny Coding Companion & Assistant

## 1. Product Summary

**MILO** adalah desktop companion untuk developer: karakter kecil yang hidup di layar, bereaksi terhadap aktivitas coding, membantu menjaga fokus, memberi reminder, dan menjadi “status pet” untuk AI coding agent seperti Codex, Claude Code, Cursor, dan agent lain yang didukung.

MILO bukan sekadar chatbot. MILO adalah presence kecil di desktop yang:

- menemani saat coding,
- memberi feedback visual/audio,
- mengingatkan break,
- mencatat reaksi dan mood,
- mendeteksi status AI agent,
- membantu todo/reminder,
- menampilkan Pomodoro dan coding stats,
- tetap berjalan secara lokal, offline, dan privacy-first.

> Catatan naming: semua referensi “Sora” pada daftar fitur dianggap sebagai “Milo” agar konsisten.

---

## 2. Product Vision

MILO ingin membuat sesi coding terasa lebih hidup, tidak sepi, dan lebih sehat. Developer sering terlalu lama duduk, lupa istirahat, tenggelam dalam bug, atau menunggu agent selesai bekerja tanpa context. MILO hadir sebagai “teman kecil” yang memperhatikan alur kerja, bukan mengganggu.

**Vision statement:**

> MILO is a tiny coding companion that makes solo coding feel less lonely, more focused, and more aware — without stealing focus, sending data away, or becoming another noisy productivity app.

---

## 3. Target Users

### Primary Users

1. **Solo developer / indie hacker**
   - Sering coding sendiri.
   - Pakai AI coding agent seperti Codex, Claude Code, Cursor, atau Copilot.
   - Butuh teman kecil yang fun tapi tetap useful.

2. **Beginner programmer**
   - Butuh reminder, focus timer, dan mood support.
   - Suka elemen visual/pet agar coding terasa tidak intimidating.

3. **AI-assisted developer**
   - Sering menjalankan agent task.
   - Butuh notifikasi visual ketika agent selesai, menunggu input, gagal, atau perlu review.

### Secondary Users

1. Student developer.
2. Game developer.
3. MacOS power user.
4. Productivity nerd yang suka Pomodoro + coding metrics.

---

## 4. Problem Statement

Developer modern punya banyak alat coding, tapi pengalaman kerja sering terasa:

- terlalu mekanis,
- terlalu sunyi,
- terlalu fokus pada output,
- kurang sadar waktu dan energi,
- penuh context switching antar IDE, terminal, browser, dan agent.

AI coding agent juga sering berjalan di background, tapi statusnya tidak selalu mudah terlihat. Developer harus bolak-balik cek terminal atau app untuk tahu apakah task selesai.

MILO memecahkan masalah ini dengan menyediakan companion kecil yang:

- menunjukkan status kerja secara visual,
- menjaga ritme coding,
- memberi reminder yang personal,
- mencatat reaksi dan mood,
- membuat aktivitas coding lebih ringan dan menyenangkan.

---

## 5. Goals

### Product Goals

1. Membuat desktop companion yang terasa hidup, lucu, dan berguna.
2. Memberikan feedback visual terhadap aktivitas developer.
3. Membantu developer menjaga fokus dan break.
4. Menjadi status indicator untuk AI coding agent.
5. Menyediakan reminder dan todo lokal.
6. Menampilkan coding stats seperti WakaTime-style time tracking dan line of code.
7. Berjalan offline secara default.
8. Tidak mencuri fokus dari pekerjaan utama.

### User Goals

1. “Aku ingin tahu kalau agent-ku sudah selesai tanpa harus cek terminal.”
2. “Aku ingin diingatkan break tanpa merasa diganggu.”
3. “Aku ingin companion yang lucu tapi tidak useless.”
4. “Aku ingin Pomodoro yang terasa playful.”
5. “Aku ingin tahu berapa lama aku coding hari ini.”
6. “Aku ingin set reminder cepat pakai bahasa natural.”

---

## 6. Non-Goals

MILO v1 tidak bertujuan untuk:

1. Menjadi IDE.
2. Menggantikan Codex, Claude Code, Cursor, atau Copilot.
3. Menjadi full project management app.
4. Melakukan code review berat tanpa user mengaktifkan AI mode.
5. Mengirim data coding ke server MILO.
6. Membaca isi source code tanpa izin eksplisit.
7. Menjadi app chat AI general-purpose seperti ChatGPT.
8. Memonitor semua aktivitas user secara invasif.

---

## 7. Product Positioning

**One-liner:**

> MILO is a tiny desktop coding companion that reacts to your work, watches your AI agents, reminds you to breathe, and celebrates when things finally build.

**Elevator pitch:**

MILO adalah desktop pet untuk developer yang hidup di layar dan bereaksi terhadap aktivitas coding. Saat kamu mengetik, MILO ikut “knead” keyboard. Saat mouse bergerak, matanya mengikuti. Saat AI agent selesai, MILO melompat bahagia dan memberi tahu. Saat kamu terlalu lama kerja, MILO mengingatkan break. Semua berjalan lokal-first, offline, dan privacy-first.

---

## 8. Core Experience

### Main Loop

1. User membuka laptop dan MILO muncul sebagai floating pet.
2. User mulai coding.
3. MILO mendeteksi aktivitas:
   - typing,
   - mouse movement,
   - app active,
   - terminal/agent running,
   - Pomodoro active,
   - reminder due,
   - coding stats update.
4. MILO merespons dengan animasi kecil:
   - mata mengikuti cursor,
   - tangan kneading keyboard,
   - idle animation,
   - thinking face saat agent bekerja,
   - happy hop saat agent selesai,
   - roast ringan saat user click/hold.
5. Jika user bekerja terlalu lama, MILO memberi break nudges.
6. User dapat membuka chat atau right-click menu untuk:
   - set reminder,
   - membuat todo,
   - start Pomodoro,
   - lihat reaction log,
   - lihat WakaTime/LOC stats,
   - mute sound,
   - ganti mood/personality.

---

## 9. Must-Have Features

### 9.1 Floating Desktop Pet

#### Description

MILO muncul sebagai karakter kecil di desktop, always-on-top, namun tidak mengganggu aktivitas user.

#### Requirements

- MILO dapat tampil di atas window lain.
- MILO bisa dipindahkan dengan drag.
- MILO memiliki idle animation.
- MILO tidak menghalangi klik kecuali area karakternya.
- MILO punya ukuran kecil/medium/large.
- MILO dapat dituck away atau disembunyikan.

#### Acceptance Criteria

- User dapat memunculkan dan menyembunyikan MILO dari menu bar.
- MILO tetap terlihat saat user berpindah app.
- MILO tidak membuat IDE kehilangan fokus saat animasi berjalan.

---

### 9.2 Reaction Log

#### Description

User dapat klik MILO untuk melihat apa yang sedang “dipikirkan” MILO. Reaction log juga berisi komentar, roast, mood, dan status aktivitas.

#### Interaction

- Click MILO: muncul bubble pendek.
- Long click / hold 3 detik: buka Reaction Log.
- Right-click: menu “Open Reaction Log”.

#### Reaction Log Content

- Recent reactions.
- Trigger source:
  - typing burst,
  - idle,
  - agent running,
  - agent done,
  - Pomodoro complete,
  - break nudge,
  - todo reminder,
  - roast mode.
- Timestamp.
- Mood label.
- Optional funny commentary.

#### Example Reaction

```text
10:24 — You pressed Cmd+S 14 times. Milo respects the anxiety.
10:41 — Codex finished. Milo did a happy hop.
11:10 — 90 minutes active. Milo recommends touching grass, or at least water.
```

#### Acceptance Criteria

- Reaction log menyimpan minimal 100 reaksi terakhir secara lokal.
- User bisa clear log.
- User bisa disable roast mode.
- Reaction log tidak menyimpan isi kode atau teks yang diketik.

---

### 9.3 Roast Interaction

#### Description

Saat user klik MILO, MILO bisa memberi komentar lucu, supportif, atau roast ringan.

#### Tone Rules

- Lucu, bukan menghina serius.
- Tidak menyerang identitas, fisik, agama, ras, gender, atau hal sensitif.
- Bisa self-aware dan developer-themed.
- Roast bisa dimatikan.

#### Example Lines

```text
“Bro, itu bug bukan fitur. Tapi nice try.”
“Kamu sudah buka 27 tab. Kita sedang coding atau bikin museum?”
“Tenang. Error merah itu cuma confetti dari compiler.”
```

#### Acceptance Criteria

- Roast mode default off atau soft.
- User bisa pilih tone:
  - Gentle
  - Playful
  - Spicy
  - Off

---

### 9.4 Sound Effects

#### Description

MILO memiliki audio feedback opsional dengan suara mumble karakter ala game, bukan voice acting penuh.

#### Requirements

- Toggle sound on/off.
- Volume slider.
- Sound categories:
  - meow,
  - mumble,
  - happy hop,
  - reminder,
  - Pomodoro finish,
  - agent done,
  - warning/break nudge.
- Tidak memutar suara saat macOS Focus/DND aktif, kecuali user override.

#### Acceptance Criteria

- Default sound off atau low volume.
- Semua sound berjalan lokal.
- Tidak ada audio panjang yang mengganggu.
- Reminder critical boleh punya sound lebih tegas jika user mengaktifkan.

---

### 9.5 Mood Check-ins

#### Description

Setiap 30 menit active use, MILO bertanya secara halus bagaimana kondisi user.

#### Active Use Definition

Active use dihitung jika dalam 30 menit terakhir terdapat kombinasi:

- keyboard activity,
- mouse movement,
- active IDE/editor,
- terminal active,
- AI agent running,
- Pomodoro running.

#### Behavior

- Check-in muncul sebagai bubble kecil.
- Tidak membuka modal besar.
- Tidak mengganggu typing.
- Bisa snooze.

#### Example

```text
“Milo check-in: kamu masih oke, atau sudah jadi bagian dari bug?”
```

#### Mood Options

- Great
- Focused
- Tired
- Stuck
- Stressed
- Hungry
- Need break

#### Acceptance Criteria

- Check-in hanya muncul setelah 30 menit active use.
- Jika user memilih “stressed” atau “tired”, MILO menurunkan chattiness dan menyarankan break.
- Mood history disimpan lokal.
- User bisa disable mood check-ins.

---

### 9.6 Break Nudges

#### Description

MILO memberi reminder break berdasarkan durasi active coding session.

#### Break Levels

1. **Gentle — 90 minutes**
   - Bubble lembut.
   - Animasi stretch.
   - Sound optional.

2. **Firm — 2 hours**
   - Bubble lebih tegas.
   - MILO blocking tiny animation selama beberapa detik.
   - Menawarkan break timer 5 menit.

3. **Non-negotiable — 3 hours**
   - MILO masuk “serious mode”.
   - Menampilkan pesan besar kecil di dekat MILO.
   - User harus memilih:
     - Start 5-min break
     - Snooze 10 min
     - Ignore once

#### Acceptance Criteria

- Break timer berdasarkan active use, bukan hanya wall-clock.
- User bisa customize interval.
- Default:
  - 90 min gentle,
  - 120 min firm,
  - 180 min non-negotiable.
- Jika Pomodoro aktif, break nudge mengikuti siklus Pomodoro.

---

### 9.7 Alarms & Reminders

#### Description

User dapat membuat alarm/reminder melalui right-click menu atau chat natural language.

#### Input Methods

1. Right-click → Add Reminder.
2. Chat:

```text
remind me in 30 min to take a break
ingatkan aku jam 3 untuk push commit
besok jam 9 ingatkan review PR
```

#### Reminder Object

- id
- title/message
- due time
- repeat rule optional
- sound mode
- completed status
- created source:
  - right-click
  - chat
  - todo
  - Pomodoro
- local notification id

#### Reminder Behavior

Saat due, MILO meows/mumbles. Bubble muncul di atas MILO.

User bisa:

- Done
- Snooze 5 min
- Snooze 15 min
- Reschedule

#### Acceptance Criteria

- Reminder tetap ada setelah app restart.
- Reminder berjalan offline.
- Natural language parser minimal mendukung:
  - “in X minutes”
  - “in X hours”
  - “today at HH:mm”
  - “tomorrow at HH:mm”
  - bahasa Indonesia sederhana: “dalam 30 menit”, “jam 3”, “besok jam 9”.

---

### 9.8 Todo List + Reminder

#### Description

MILO dapat membuat todo list sederhana dan mengingatkan todo tersebut.

#### Requirements

- Add todo via chat.
- Add todo via right-click.
- Mark done.
- Edit todo.
- Delete todo.
- Add due time.
- Convert todo to reminder.
- Show active todo count near MILO or in menu.

#### Example Commands

```text
add todo: fix login bug
buat todo: update README besok jam 10
remind todo deploy jam 5 sore
```

#### Acceptance Criteria

- Todo tersimpan lokal.
- Todo bisa punya reminder.
- Todo overdue muncul dalam bubble MILO.
- Todo list dapat dibuka dari right-click menu.

---

### 9.9 Message Reminder with Meow

#### Description

User memilih waktu dan pesan, lalu MILO “meows” untuk mengingatkan.

#### Requirements

- Custom message.
- Custom time.
- Optional sound:
  - meow,
  - mumble,
  - silent,
  - urgent.
- Optional repeat:
  - once,
  - daily,
  - weekdays,
  - custom.

#### Acceptance Criteria

- User bisa membuat reminder dalam kurang dari 10 detik.
- Reminder muncul walau app sedang minimized.
- Jika sound off, bubble tetap muncul.

---

### 9.10 AI Agent Status Reactions

#### Description

Saat AI coding agent yang didukung selesai menjalankan task, MILO memberi notifikasi visual/audio.

#### Supported Agents for MVP

- Codex CLI / Codex Desktop where possible.
- Claude Code CLI.
- Cursor Agent basic detection.
- Xcode build process.
- Generic terminal command watcher.

#### Agent States

- Idle
- Thinking / Running
- Waiting for user input
- Done
- Failed
- Needs review

#### MILO Reactions

- Running: thinking face.
- Waiting: curious tilt.
- Done: happy hop + short bubble.
- Failed: dramatic flop.
- Needs review: points at screen.

#### Acceptance Criteria

- MILO dapat mendeteksi proses agent aktif.
- MILO dapat menampilkan status “agent running”.
- MILO memberi notifikasi saat task selesai.
- Jika integrasi mendalam belum tersedia, MVP boleh memakai process/log watcher sebagai fallback.
- Tidak membaca prompt atau output agent tanpa izin user.

---

### 9.11 Keyboard Kneading

#### Description

Saat user mengetik, MILO melakukan animasi tangan seperti kneading keyboard.

#### Requirements

- Global keyboard activity detection.
- Tidak menyimpan karakter yang diketik.
- Hanya event timing dan intensity.
- Animasi berubah berdasarkan typing speed:
  - slow typing: tiny taps,
  - fast typing: energetic kneading,
  - very fast: overheat mode.

#### Acceptance Criteria

- Saat user mengetik di editor, MILO bereaksi dalam <200ms.
- Tidak ada logging isi keystroke.
- Fitur bisa mati jika permission tidak diberikan.
- App tetap usable tanpa keyboard permission.

---

### 9.12 Eye Follow Cursor

#### Description

MILO mengikuti pergerakan mouse dengan mata.

#### Requirements

- Eye tracking berdasarkan posisi cursor.
- Smooth animation.
- Idle blink.
- Optional head tilt ketika cursor dekat.

#### Acceptance Criteria

- Mata MILO mengikuti cursor secara real-time.
- Tidak mengganggu performa.
- Bisa dinonaktifkan pada low power mode.

---

### 9.13 Offline, Local-first, Always Works

#### Description

MILO harus tetap berguna tanpa internet.

#### Requirements

- Core companion mode berjalan offline.
- Reaction pool lokal.
- Reminder lokal.
- Todo lokal.
- Pomodoro lokal.
- Coding stats lokal.
- Agent process watcher lokal.
- Optional AI mode hanya aktif jika user menghubungkan provider/cloud/local LLM.

#### Data Policy

- Default: no telemetry.
- No remote analytics.
- No crash reporting tanpa opt-in.
- No code upload.
- No key logging.
- Semua user data tersimpan lokal.

#### Acceptance Criteria

- Fresh install dapat berjalan tanpa login.
- Tidak butuh API key untuk core features.
- Jika internet mati, MILO tetap bisa:
  - animasi,
  - reminder,
  - todo,
  - Pomodoro,
  - break nudge,
  - reaction log,
  - local coding stats.

---

### 9.14 Pomodoro Focus Timer

#### Description

MILO menyediakan Pomodoro focus timer dengan visual timer kecil.

#### Requirements

- Start / pause / reset.
- Preset:
  - 25/5
  - 50/10
  - 90/15
  - custom.
- Timer badge di dekat MILO.
- Break animation.
- Focus stats:
  - Pomodoros today,
  - total focus time,
  - streak,
  - skipped breaks.

#### Acceptance Criteria

- User bisa start Pomodoro dari right-click.
- Saat focus selesai, MILO memberi animasi dan sound optional.
- Pomodoro stats tersimpan lokal.
- Pomodoro tidak bentrok dengan break nudge.

---

### 9.15 WakaTime-style Coding Metrics & Line of Code

#### Description

MILO menampilkan coding activity seperti WakaTime-style stats: waktu coding, project aktif, bahasa pemrograman, dan perubahan line of code.

#### MVP Scope

MILO memiliki local coding metrics dengan optional WakaTime integration.

#### Local Metrics

- Active coding time.
- Active app/editor.
- Project/folder aktif jika bisa dideteksi.
- Language estimation dari file extension.
- Lines added/deleted via Git diff.
- Session summary.

#### Optional WakaTime Integration

- User memasukkan WakaTime API key.
- MILO mengambil summary coding activity.
- MILO menampilkan:
  - coding time today,
  - top language,
  - top project,
  - editor usage.

#### LOC Tracking

MILO menghitung LOC dari:

- Git diff working tree.
- Git commits hari ini.
- Optional file watcher.

#### Acceptance Criteria

- Tanpa WakaTime API key, MILO tetap punya local stats.
- Dengan WakaTime API key, MILO dapat menampilkan stats dari WakaTime.
- LOC tidak menghitung folder ignored:
  - node_modules,
  - .git,
  - build,
  - dist,
  - DerivedData,
  - vendor,
  - generated files.
- User bisa reset local stats.

---

## 10. User Stories

### Reaction & Personality

- Sebagai developer, aku ingin klik MILO dan mendapat komentar lucu agar coding terasa tidak sepi.
- Sebagai user, aku ingin melihat reaction log agar tahu apa saja yang MILO deteksi.
- Sebagai user, aku ingin roast mode bisa dimatikan agar MILO tidak mengganggu mood.

### Focus & Health

- Sebagai developer, aku ingin MILO mengingatkanku break setelah terlalu lama coding.
- Sebagai user, aku ingin MILO bertanya mood setiap 30 menit agar aku sadar kondisi diri.
- Sebagai user, aku ingin Pomodoro yang playful agar fokus terasa lebih ringan.

### Reminder & Todo

- Sebagai user, aku ingin bilang “remind me in 30 min” agar cepat membuat reminder.
- Sebagai user, aku ingin todo sederhana yang bisa mengingatkanku.
- Sebagai user, aku ingin MILO meow ketika reminder tiba.

### Agent Awareness

- Sebagai AI-assisted developer, aku ingin MILO memberi tahu saat Codex/Claude/Cursor selesai.
- Sebagai user, aku ingin MILO menunjukkan agent sedang thinking/running agar aku tidak bolak-balik cek terminal.
- Sebagai user, aku ingin MILO memberi sinyal jika agent gagal.

### Coding Stats

- Sebagai developer, aku ingin tahu berapa lama aku coding hari ini.
- Sebagai developer, aku ingin tahu line of code added/deleted.
- Sebagai user WakaTime, aku ingin MILO bisa menampilkan ringkasan WakaTime.

---

## 11. UX Requirements

### 11.1 Main UI Surfaces

#### Floating Pet

- Always-on-top.
- Small visual footprint.
- Can be dragged.
- Shows animation and tiny bubbles.

#### Right-click Menu

Menu utama:

- Open Chat
- Add Reminder
- Add Todo
- Start Pomodoro
- Reaction Log
- Coding Stats
- Agent Status
- Mood
- Sound On/Off
- Personality
- Settings
- Tuck Away Milo
- Quit

#### Chat Panel

- Small chat window attached near MILO.
- Supports natural language reminder/todo.
- Optional AI mode.
- Companion mode default.
- Chat history off by default.

#### Settings

Sections:

- General
- Appearance
- Sound
- Reminder
- Pomodoro
- Break Nudges
- Mood Check-ins
- Agent Integrations
- Coding Metrics
- Privacy & Storage
- Permissions

---

## 12. Companion States

### Idle

MILO breathing, blinking, occasionally looking around.

### Watching

MILO eyes follow cursor.

### Typing

MILO kneads keyboard.

### Fast Typing

MILO becomes excited.

### Overheat

If typing too fast for too long, MILO turns dramatic/red/steamy.

### Agent Thinking

MILO shows thinking face.

### Agent Done

MILO happy hop.

### Agent Failed

MILO dramatic flop.

### Reminder Due

MILO meows and shows message.

### Pomodoro Focus

MILO becomes quieter with timer badge.

### Break Time

MILO stretches.

### Roast Mode

MILO gives playful comments.

---

## 13. Functional Requirements

### 13.1 App Lifecycle

- Launch at login optional.
- Menu bar icon.
- Restore last position.
- Persist settings locally.
- Low CPU idle mode.

### 13.2 Permissions

MILO should request permissions only when needed:

- Accessibility/Input Monitoring for keyboard reactions.
- Notification permission for reminders.
- File/folder access for local LOC stats.
- Optional network for WakaTime/API integrations.
- Optional microphone only if future voice mode exists.

### 13.3 Data Storage

Local storage should include:

- settings,
- reminders,
- todos,
- reaction log,
- mood log,
- Pomodoro stats,
- local coding stats,
- agent integration config.

Sensitive storage:

- API keys stored in Keychain.
- No API key in UserDefaults/plain files.

### 13.4 Notification Rules

- Gentle reminder: bubble only.
- Normal reminder: bubble + optional sound.
- Critical reminder: bubble + stronger sound if enabled.
- Respect macOS Focus/DND by default.

---

## 14. Technical Recommendation

### 14.1 Platform

#### MVP Platform

- macOS first.

#### Recommended Stack

- Swift 6
- SwiftUI
- AppKit for floating window / always-on-top behavior
- SpriteKit or lightweight frame animation for 2D pixel pet
- RealityKit optional later for 3D
- UserDefaults / local JSON / SQLite for local data
- Keychain for API keys
- UserNotifications for reminders
- Combine / Observation for state
- FileManager + Git CLI for LOC
- URLSession for optional WakaTime API

#### Why macOS first?

- Target users likely use Mac for Codex, Xcode, Cursor, Claude Code.
- macOS supports floating companion windows well.
- Xcode integration and developer workflow are easier to prototype.

---

## 15. Agent Integration Design

### 15.1 Detection Strategy

#### Level 1 — Process Detection

Detect running processes:

- codex
- claude
- cursor
- xcodebuild
- git
- npm
- pnpm
- bun
- yarn
- cargo
- swift
- vite
- jest

#### Level 2 — Log / Output Detection

Optional watcher for:

- terminal session logs,
- task status files,
- known agent output patterns.

#### Level 3 — Plugin / API Integration

Future:

- Codex plugin hooks.
- Claude Code hooks.
- Cursor extension.
- MCP adapter.

### 15.2 Agent State Mapping

| Detected Signal | MILO State |
|---|---|
| Agent process starts | Thinking |
| Long-running task | Focused waiting |
| Process exits 0 | Happy hop |
| Process exits non-zero | Dramatic fail |
| Output contains “waiting for input” | Curious |
| Output contains “review” | Needs review |

---

## 16. Coding Metrics Design

### 16.1 Local Metrics Engine

MILO tracks:

- active editor time,
- session start/end,
- project folder,
- language,
- Git diff LOC,
- commits today,
- files changed.

### 16.2 LOC Calculation

Priority:

1. Git diff against HEAD.
2. Git log commits today.
3. File watcher fallback.

Exclusions:

- binary files,
- generated files,
- dependency folders,
- build artifacts.

### 16.3 Daily Summary Example

```text
Today:
- Coding time: 3h 42m
- Top project: Milo
- Top language: Swift
- LOC: +420 / -96
- Pomodoros: 5
- Breaks skipped: 2
Milo’s verdict: productive, slightly feral.
```

---

## 17. Privacy Requirements

### Default Privacy Promise

MILO should work without account, internet, or cloud.

### Must Not

- Store keystroke content.
- Upload code.
- Upload clipboard.
- Track user across apps for analytics.
- Send telemetry by default.
- Store API keys in plain text.

### Must

- Explain every permission clearly.
- Allow disabling each sensor.
- Store data locally.
- Provide “Delete all local data”.
- Provide “Export local data”.

---

## 18. MVP Scope

## MVP v1.0 Must Include

### Companion Core

- Floating MILO pet.
- Idle animation.
- Drag and reposition.
- Eye follows cursor.
- Keyboard kneading.
- Click interaction.
- Reaction bubbles.
- Reaction log.
- Sound toggle.
- Roast mode.

### Productivity

- Pomodoro timer.
- Break nudges: 90m, 2h, 3h.
- Mood check-ins every 30 min active use.
- Reminder via right-click.
- Reminder via natural language.
- Todo list.
- Todo reminders.
- Message reminder with meow.

### Agent Awareness

- Detect Codex/Claude/Cursor basic process.
- Detect xcodebuild.
- Agent running state.
- Agent done happy hop.
- Agent failed reaction.

### Metrics

- Local coding time.
- Local LOC via Git diff.
- WakaTime API integration optional.
- Daily stats panel.

### Privacy

- Offline mode default.
- Local storage.
- Keychain for API keys.
- No telemetry.

---

## 19. Out of Scope for MVP

- Full AI chatbot with cloud provider.
- Voice mode.
- 3D character.
- Marketplace for skins.
- Team dashboard.
- Cloud sync.
- Mobile companion.
- Deep IDE plugin.
- Full WakaTime replacement.
- Code review automation.

---

## 20. Success Metrics

### Engagement

- User keeps MILO running at least 3 days/week.
- Average daily interaction ≥ 5 interactions.
- Reaction log opened at least once/week.

### Productivity

- Pomodoro used at least 2 sessions/week.
- Break nudges accepted at least 30% of the time.
- Reminders created at least 3/week.

### Agent Awareness

- Agent done notification accuracy ≥ 85%.
- False positive agent done notification ≤ 10%.

### Performance

- Idle CPU < 2%.
- Memory < 150MB for 2D version.
- Animation response < 200ms.
- Reminder delivery delay < 5 seconds.

### Privacy

- Core app works without internet.
- Zero telemetry by default.
- No keystroke content stored.

---

## 21. Key Risks

### Risk 1 — macOS Permissions Feel Scary

Keyboard/mouse detection may trigger user concern.

**Mitigation:**

- Permission screen must be transparent.
- Explain: “MILO only reads timing, not what you type.”
- Feature works partially without permission.

### Risk 2 — Too Noisy

MILO might become distracting.

**Mitigation:**

- Chattiness slider.
- Focus mode.
- DND sync.
- Quiet hours.
- Mute sound.

### Risk 3 — Agent Detection Is Unreliable

Different agents expose status differently.

**Mitigation:**

- Start with process detection.
- Add per-agent adapters gradually.
- Show confidence state.
- Let user manually mark agent task as running/done.

### Risk 4 — LOC Metrics Can Be Wrong

Generated files and dependencies can distort LOC.

**Mitigation:**

- Respect .gitignore.
- Exclude common folders.
- Allow user custom ignore list.
- Show “estimated LOC” label.

### Risk 5 — Product Becomes Too Broad

Reminder, todo, Pomodoro, stats, agent watcher, pet, AI chat could bloat.

**Mitigation:**

- Keep MILO as companion-first.
- Every feature must appear through pet behavior.
- Avoid heavy dashboard UX in MVP.

---

## 22. Open Questions

1. Is MILO visually a cat, chicken, blob, robot, or custom character?
2. Should MILO be pixel-art only for MVP?
3. Should MILO support Windows later?
4. Should WakaTime integration be mandatory or optional?
5. Should chat AI mode exist in v1, or only local reaction pool?
6. Which agent should be first-class: Codex, Claude Code, Cursor, or Xcode?
7. Should roast mode be default off?
8. Should mood check-ins store long-term history or only daily?

---

## 23. Recommended MVP Build Order

### Phase 1 — Desktop Pet Core

- Floating window.
- Idle animation.
- Drag.
- Eye follow.
- Keyboard kneading.
- Click bubble.

### Phase 2 — Local Productivity

- Reminder.
- Todo.
- Pomodoro.
- Break nudges.
- Mood check-ins.

### Phase 3 — Agent Awareness

- Process watcher.
- Agent state mapping.
- Happy hop / fail reaction.
- Basic Codex/Claude/Cursor detection.

### Phase 4 — Coding Stats

- Active coding time.
- Git LOC.
- Daily summary.
- Optional WakaTime API.

### Phase 5 — Polish

- Sound effects.
- Reaction log.
- Roast mode.
- Settings.
- Privacy screen.
- Onboarding.

---

## 24. MVP Acceptance Checklist

MILO v1 is considered successful when:

- User can launch MILO and see it floating on desktop.
- MILO follows cursor with eyes.
- MILO kneads keyboard while user types.
- User can click MILO and get a reaction.
- User can open reaction log.
- User can start Pomodoro.
- User gets mood check-in every 30 min active use.
- User gets break nudges at 90 min, 2h, and 3h.
- User can create reminder from right-click.
- User can create reminder from chat.
- User can create todo and attach reminder.
- MILO meows/mumbles when reminder fires.
- MILO detects at least one supported agent running.
- MILO reacts when agent finishes.
- MILO shows local coding time.
- MILO shows estimated LOC.
- MILO works offline.
- MILO does not store typed text.
- MILO does not require login or API key for core features.

---

## 25. Product Personality

MILO should feel:

- tiny,
- playful,
- slightly chaotic,
- supportive,
- witty,
- developer-aware,
- not corporate,
- not too needy.

### Tone Examples

When user codes fast:

```text
“You are typing like the bug personally insulted your family.”
```

When agent finishes:

```text
“Task finished. Milo did a tiny victory hop. You’re welcome.”
```

When user skips break:

```text
“Your spine has opened a support ticket.”
```

When build fails:

```text
“Build failed. Milo has fallen dramatically for emotional accuracy.”
```

When Pomodoro completes:

```text
“Focus complete. Please collect your tiny productivity medal.”
```

---

# Final Summary

MILO is a local-first desktop coding companion for developers. It combines the charm of a desktop pet, the usefulness of a focus assistant, and the awareness of an AI-agent status monitor. The MVP should prioritize the living companion loop: react to coding, remind gently, celebrate agent completion, and help the user stay focused without becoming another productivity burden.
