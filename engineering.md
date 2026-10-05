# Engineering Specification & Architecture Manual — WristReply AI

This document is the authoritative blueprint for engineers building on WristReply AI. It consolidates
the functional prerequisites, engineering constraints, component boundaries, operating-system rules and
the zero-leakage privacy contract.

Every class name below is a real file under `android/core-engine/src/main/kotlin/com/wristreply/core/`.

---

## 1. Product definition

WristReply AI is an on-device, offline-first communication utility for Android and paired wearables. It
intercepts incoming conversational notifications, synthesises contextual reply suggestions locally
(Google ML Kit Smart Reply first, deterministic multilingual banks second), and exposes them as
interactive action pills in the Android notification drawer, on Wear OS clients, on Zepp OS companion
interfaces, and on budget RTOS smartwatch displays.

The system obeys zero-cloud principles: no network permission is declared, so conversations cannot leave
the device. The target budget is sub-50 ms inference latency and 15–25 MB resident RAM.

---

## 2. Component decoupling

```
                ┌──────────────────────────────────────────────┐
                │          Android notification event          │
                └──────────────────────┬───────────────────────┘
                                       │
                                       ▼
     ┌────────────────────────────────────────────────────────────┐
     │        Headless Kotlin daemon (pure native process)        │
     │                                                            │
     │  ┌──────────────────────────┐   ┌────────────────────────┐ │
     │  │ NotificationGate         │──►│ DynamicNotification    │ │
     │  │ SleepWindowGate          │   │ Inspector              │ │
     │  └──────────────────────────┘   └───────────┬────────────┘ │
     │                                             │              │
     │  ┌──────────────────────────┐               ▼              │
     │  │ SmartReplyResolver       │◄──[RemoteInput target]       │
     │  │  ├ EphemeralMLKitEngine  │                              │
     │  │  └ FallbackReplyEngine   │                              │
     │  └───────────┬──────────────┘                              │
     │              ▼                                             │
     │  ┌──────────────────────────┐   ┌────────────────────────┐ │
     │  │ NotificationPublisher    │──►│ ActionBroadcast        │ │
     │  │ WearSyncService          │   │ Receiver               │ │
     │  └──────────────────────────┘   └────────────────────────┘ │
     └────────────────────────────────────────────────────────────┘
                                       │
                    (reads preferences from native disk)
                                       │
                                       ▼
     ┌────────────────────────────────────────────────────────────┐
     │          Presentation client (Flutter framework)           │
     │       [instantiated ONLY when the user opens the UI]       │
     │                                                            │
     │  ┌──────────────────────────────────────────────────────┐  │
     │  │ Atomic widgets: StateBadge, MetricsCard, ReplyPill   │  │
     │  └──────────────────────────────────────────────────────┘  │
     │  ┌──────────────────────────────────────────────────────┐  │
     │  │ MethodChannel bridge: NativeChannel ↔ NativeBridge   │  │
     │  └──────────────────────────────────────────────────────┘  │
     └────────────────────────────────────────────────────────────┘
```

### 2.1 The native daemon boundary

The background pipeline runs entirely in Kotlin inside an isolated `NotificationListenerService`
(`service/NotificationProcessorService.kt`). The Flutter runtime is never booted or held in memory while
alerts are processed. Every preference the user sets in Flutter is written to Android
`SharedPreferences` through the `MethodChannel`; the daemon reads them through
`cache/UserPreferencesHotCache`. Steady state: 15–25 MB resident, 0% idle CPU.

### 2.2 Atomic Flutter architecture

The presentation layer is decomposed into micro-widgets; no file exceeds roughly 150 lines and state is
scoped locally. Widgets fall into atomic foundations (`core/constants/`, `core/theme/`,
`shared/widgets/`), molecule tiles (toggle rows, metric cards, pill previews) and screen templates
(`features/<feature>/screens/`).

---

## 3. The processing pipeline

`service/NotificationProcessorService.kt` runs these stages, in this order.

| # | Stage | Class |
| --- | --- | --- |
| 0 | Ingestion gate | `inspector/NotificationGate.kt`, `guard/SleepWindowGate.kt` |
| 1 | LPTE profanity shield | `filters/ProfanityGuardEngine.kt` |
| 2 | Token / OTP auto-copy | `filters/SmartTokenExtractor.kt` |
| 3 | Inline-reply extraction | `inspector/DynamicNotificationInspector.kt`, `guard/ReadActionResolver.kt` |
| 4 | Delayed reply scheduling | `automation/DelayedReplyScheduler.kt` |
| 5 | Burst debounce | `guard/MessageDebounceBuffer.kt` |
| 6 | Reply generation | `nlp/SmartReplyResolver.kt` → `nlp/EphemeralMLKitEngine.kt` → `nlp/FallbackReplyEngine.kt` → `context/ContextualReplyEnhancer.kt` |
| 7 | Publish and mirror | `publisher/NotificationPublisher.kt`, `wear/WearSyncService.kt`, `metrics/MetricsLedger.kt` |

### 3.1 Ingestion and heuristic validation (`NotificationGate.kt`)

The gate filters alerts before any NLP compute is allocated. A notification must pass all of:

1. No `FLAG_ONGOING_EVENT` — discards media sessions, downloads and background monitors.
2. No `FLAG_GROUP_SUMMARY` — discards parent bundles posted by messaging apps.
3. A `CATEGORY_MESSAGE` tag, an active `MessagingStyle`, or a non-blank `EXTRA_TEXT` payload.

On top of the gate the daemon also checks the master switch, the sleep window
(`guard/SleepWindowGate.kt`) and the per-app whitelist from the preference cache.

### 3.2 LPTE profanity shield (`ProfanityGuardEngine.kt`)

`containsAbusiveContent(context, text, isShieldEnabled)` returns a pair of `(isAbusive, matchedToken)`.
The default dictionary holds 68 unique tokens (`filters/DefaultBlockedWords.kt`; the source lists 71
literals, of which `idiot`, `fraude` and `puta` repeat across two language sections and are collapsed by
`setOf`), merged with the user's own blocklist. On a match the daemon posts a warning through
`NotificationAlertHelper.postAbuseWarning` and stops — no pills are generated.

### 3.3 Token and OTP extraction (`SmartTokenExtractor.kt`)

`scanAndExtract(text, autoCopyTrx, autoCopyOtp)` matches transaction IDs (Apple Pay, Google Pay, PayPal,
Stripe, UPI, Pix, iDEAL, bKash, GrabPay, bank reference SMS) before falling back to 4–8 digit OTP
codes. A match is copied to the clipboard via `copyToClipboard(context, token)` and confirmed with a
silent notification.

### 3.4 Dynamic reflection and `RemoteInput` extraction (`DynamicNotificationInspector.kt`)

To avoid hardcoding package names, `resolveReplyTarget(sbn)` scans the notification's action hierarchy at
runtime — standard `Notification.Action` collections and `WearableExtender` action arrays — for a
`RemoteInput` carrying a non-null `resultKey`. It returns an immutable `DynamicReplyTarget` with the
sender, message body, package, result key and target `PendingIntent`. If no reply target exists the
pipeline stops.

### 3.5 Ephemeral NLP (`EphemeralMLKitEngine.kt`)

Inference uses Google ML Kit Smart Reply. The client is created per call on `Dispatchers.Default`, the
message is analysed inside a structured conversation context, and the client is closed in a `finally`
block whether the call succeeds, returns empty, or hits a language mismatch. The whole call is bounded by
a 2 500 ms timeout.

### 3.6 Multilingual fallback (`FallbackReplyEngine.kt`)

ML Kit is strongest on English, so `resolveFallback(incomingText, userCustomPills, tone, applyChronoBias)`
provides a deterministic path. Priority order:

1. **User custom overrides** — pills configured in the UI are returned verbatim.
2. **Chrono bias** — with `applyChronoBias = true`, local time between 23:00 and 06:59 routes to the
   locale's late-night bank.
3. **Script and keyword routing** — Arabic (`U+0600`–`U+06FF`), Bengali (`U+0980`–`U+09FF`) and
   Devanagari (`U+0900`–`U+097F`) script ranges, plus romanised Banglish/Hinglish keyword matches
   ("kemon", "kothay", "hobe"), select one of 24 banks (10 locales × casual / professional / late-night).

`nlp/LocationPillResolver.kt` supplies the locale-correct wording for the location pill
(Location / Ubicación / Standort / Localização / Position / موقعي / लोकेशन / লোকেশন).

### 3.7 Contextual enhancement (`context/ContextualReplyEnhancer.kt`)

After generation the enhancer injects context pills: a connected car Bluetooth profile prepends a
localised `[🚗 Driving]` pill, and a busy calendar slot prepends `[📅 Meeting until HH:MM]`.

### 3.8 Burst debounce (`guard/MessageDebounceBuffer.kt`)

`enqueueMessage(scope, senderId, messageText, onBatchReady)` coalesces rapid-fire messages from the same
sender: 1 500 ms debounce window, up to 5 buffered messages per sender, cancellation propagated through
the coroutine scope. `activeSenderCount` exposes the live queue depth for the UI.

### 3.9 Action injection and watch mirroring (`publisher/NotificationPublisher.kt`)

`publishPills(...)` posts a companion notification on channel `smart_reply_channel` with
`IMPORTANCE_LOW` — vibration, lights and sound disabled. Up to `pillsPerMessage` pills (default 3, max 5)
plus a read action are attached; `MAX_LIVE_COMPANIONS` is 3, and pill text truncates at 25 characters.
Privacy mode masks the preview text. `wear/WearSyncService.kt` mirrors the same pills to the watch and
`metrics/MetricsLedger.kt` records the dispatch.

### 3.10 Headless dispatch (`receiver/ActionBroadcastReceiver.kt`)

Tapping a pill fires a broadcast to `ActionBroadcastReceiver`, which builds a `RemoteInput` result bundle
with the chosen text, attaches it to the original app's intent with `RemoteInput.addResultsToIntent()`
and calls `PendingIntent.send()`. The reply is dispatched without unlocking the phone or opening the
messaging UI.

---

## 4. Wearable sync protocols

### 4.1 Wear OS

`wear/WearSyncService.kt` pushes the pills over the Wearable Data Layer. A companion client renders
high-contrast chips in a 44 dp stack; tapping a chip messages the phone daemon, which performs the remote
dispatch.

### 4.2 Zepp OS (Amazfit)

Synchronisation runs through a JavaScript micro-app on the watch communicating with the Zepp mobile
bridge, relaying reply tokens to the watch screen.

### 4.3 Universal budget RTOS

For closed-source RTOS devices (boAt, Noise, Fire-Boltt) the system relies purely on Android notification
action mirroring: the injected actions appear on the watch as stock quick replies, with no companion app.

---

## 5. Design system

### 5.1 Colour tokens

`lib/core/constants/app_colors.dart`, `playground/assets/styles.css` `:root` and this table are the same
palette:

| Token | Value | Use |
| --- | --- | --- |
| `surfaceCanvas` | `#0B0E14` | Deep obsidian canvas, minimal OLED draw |
| `surfaceRaised` | `#131823` | Cards |
| `surfaceInteractive` | `#1C2333` | Chips, inputs |
| `borderSubtle` | `#222B3D` | 1 dp card borders |
| `borderAccent` | `#2D3A54` | Focused borders |
| `accentPrimary` | `#00F2FE` | Primary accent |
| `accentMint` | `#38EF7D` | Active / confirmed state |
| `accentWarning` | `#FFB020` | Warnings |
| `accentDanger` | `#FF4C4C` | Destructive actions |
| `textPrimary` | `#F1F5F9` | Headings and body |
| `textSecondary` | `#94A3B8` | Supporting copy |
| `textTertiary` | `#475569` | Muted copy |

### 5.2 Typography

The Flutter app declares no bundled fonts and uses the platform default typeface, so it inherits the OEM
font and needs no extra APK weight. The web playground uses Space Grotesk (display), Inter (body) and
JetBrains Mono (code) from Google Fonts, with system fallbacks.

### 5.3 Kinetic specs and touch ergonomics

- Mobile chips: minimum 48 × 48 dp bounding box. Wearable targets: minimum 44 dp height.
- Press feedback: scale `1.00 → 0.96` over 90 ms, spring back on release, `HapticFeedback.lightImpact()`.
- No blocking spinners: layouts render from local cache and hydrate in place.

---

## 6. Stability and platform compliance

### 6.1 OEM keep-alive

Custom ROMs (Xiaomi HyperOS, Samsung One UI, Oppo ColorOS) kill long-running services. The app counters
this through `repository/OemKeepAliveManager.kt`:

- Onboarding routes the user to `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
- `Build.MANUFACTURER` dispatches to manufacturer autostart screens (Xiaomi Security Center, Huawei
  Startup Manager, …), tolerating uninstalled components.
- `onListenerDisconnected()` triggers `requestRebind()` when the system kills the listener.

### 6.2 Google Play policy compliance

- **Zero-internet build** — the manifest omits `android.permission.INTERNET`, which is architectural proof
  that conversations cannot leave the device.
- **Transparent onboarding** — the first-launch flow discloses exactly why
  `NotificationListenerService` access is required.
- **Data safety** — the Console form can state *no user data collected, no user data shared with third
  parties*.
- **Backup** — `android:allowBackup="false"` plus `data_extraction_rules.xml` excluding every preference
  file from cloud backup and device transfer.

---

## 7. Verification strategy

| Layer | Command | Where it runs |
| --- | --- | --- |
| Dart static analysis | `flutter analyze` | `flutter.yml` |
| Dart tests | `flutter test` | `flutter.yml` |
| Kotlin JUnit (8 classes) | `./gradlew :core-engine:testDebugUnitTest` | `android.yml` |
| Playground parity (53 assertions) | `node --test playground/test/*.mjs` | `flutter.yml` |
| Documentation lint | `npx markdownlint-cli2 "**/*.md"` | `docs.yml` |

The playground port in `playground/assets/engine.js` is regenerated from the Kotlin sources, so a change
to a bank, dictionary or threshold shows up as a parity failure rather than silent drift. See
[`playground/README.md`](playground/README.md).
