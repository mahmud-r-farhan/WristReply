# WristReply AI ⚡⌚

> **Offline-first, on-device smart reply engine and wearable companion for Android.**
> Context-aware, low-latency quick-reply pills injected straight onto notifications —
> mirrored to Wear OS, Zepp OS, and budget RTOS smartwatches.

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](lib/)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.4-7F52FF?logo=kotlin&logoColor=white)](android/core-engine/)
[![Java](https://img.shields.io/badge/JDK-17-ED8B00?logo=openjdk&logoColor=white)](android/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20on--device-green)](#-privacy--zero-cloud-guarantee)
[![INTERNET](https://img.shields.io/badge/INTERNET-not%20declared-critical)](#-privacy--zero-cloud-guarantee)

</div>

[![WristReply AI Video Demo](https://youtube.com)](https://www.youtube.com/watch?v=NNh5jE2VE5g)

---

## 🌟 Key architecture & highlights

- **Pure headless Kotlin engine** — the daemon is an Android `NotificationListenerService` inside the
  decoupled `:core-engine` module. Flutter is never booted in the background: ~15–25 MB resident RAM,
  0% idle CPU.
- **Decoupled `:core-engine` module** — zero Flutter dependencies; builds to a standalone `.aar` and
  embeds into any native app through `EngineBootstrap`.
- **Dynamic messaging detection** — no hardcoded package list. The engine inspects notifications for a
  pending `RemoteInput` reply action, so WhatsApp, Telegram, Signal, Slack, Messenger and SMS all work
  out of the box.
- **Eight-stage pipeline** — gate → profanity shield → OTP/transaction extraction → burst debounce →
  ephemeral ML Kit → multilingual fallback → context enhancement → silent publish.
- **Global multilingual fallback** — 24 curated reply banks across English, Spanish, German, Portuguese,
  French, Arabic, Hindi/Hinglish and Bengali/Banglish, each with casual, professional and late-night
  variants.
- **Ephemeral ML Kit inference** — the Smart Reply client is created per call and closed in a `finally`
  block, behind a 2.5 s timeout.
- **Smart token auto-copy** — extracts OTP codes and transaction IDs (Apple Pay, Google Pay, PayPal,
  Stripe, Pix, iDEAL, UPI, bKash, bank SMS) and pins a one-tap copy action.
- **Silent injected actions** — companions are published on an `IMPORTANCE_LOW` channel: no sound, no
  vibration, no screen wake.
- **Context-aware enhancers** — car Bluetooth injects a localized `[🚗 Driving]` pill, a busy calendar
  slot injects `[📅 Meeting until 3:30 PM]`, and the chrono bias swaps late-night banks between 23:00
  and 06:59.
- **OLED dark utility cockpit** — the Flutter UI manages whitelists, persona pills, sleep gates and a
  live test sandbox that mirrors the Kotlin contract.


---

## 🏛 Architecture overview

```
                 ┌──────────────────────────────────────────────┐
                 │            Active notification feed          │
                 │       (WhatsApp, Telegram, Signal, SMS)      │
                 └──────────────────────┬───────────────────────┘
                                        ▼
                 ┌──────────────────────────────────────────────┐
                 │    NotificationProcessorService (headless)   │
                 │             [android/core-engine]            │
                 └──────┬───────────────────────┬───────────────┘
        ┌───────────────▼─────────┐   ┌─────────▼────────────────┐
        │ NotificationGate        │   │ SmartTokenExtractor      │
        │ (flags, extras, text)   │   │ (OTP / transaction IDs)  │
        └───────────────┬─────────┘   └─────────┬────────────────┘
                        ▼                       │
        ┌────────────────────────────┐          │
        │ ProfanityGuardEngine       │          │
        │ MessageDebounceBuffer      │          │
        └───────────────┬────────────┘          │
                        ▼                       │
        ┌────────────────────────────┐          │
        │ EphemeralMLKitEngine       │          │
        │  ↓ empty / unsupported     │          │
        │ FallbackReplyEngine (8)    │          │
        └───────────────┬────────────┘          │
                        ▼                       ▼
        ┌──────────────────────────────────────────────────────┐
        │ ContextualReplyEnhancer (driving / meeting / chrono) │
        └───────────────────────┬──────────────────────────────┘
                                ▼
        ┌──────────────────────────────────────────────────────┐
        │ NotificationPublisher — silent companion group       │
        │  • Android notification shade                        │
        │  • Wear OS / Zepp OS / RTOS smartwatches             │
        └───────────────────────┬──────────────────────────────┘
                                ▼
        ┌──────────────────────────────────────────────────────┐
        │ ActionBroadcastReceiver → RemoteInput → PendingIntent│
        └──────────────────────────────────────────────────────┘
```

## 📁 Repository structure

```
WristReply/
├── .github/workflows/          # flutter.yml · android.yml · docs.yml · release.yml
├── android/
│   ├── app/                    # Flutter Android host container
│   │   └── src/main/kotlin/…   # MethodChannel bridge + SharedPreferences
│   └── core-engine/            # 🚀 standalone Kotlin library module
│       ├── build.gradle.kts    # com.android.library, zero Flutter deps
│       ├── src/main/kotlin/com/wristreply/core/
│       │   ├── EngineBootstrap.kt     # 5-line public entry point
│       │   ├── automation/            # DelayedReplyScheduler
│       │   ├── cache/                 # LRU cache + hot preference cache
│       │   ├── context/               # Driving, calendar, location helpers
│       │   ├── filters/               # ProfanityGuardEngine, SmartTokenExtractor
│       │   ├── guard/                 # Debounce, sleep window, read resolver
│       │   ├── inspector/             # NotificationGate, DynamicNotificationInspector
│       │   ├── metrics/               # MetricsLedger
│       │   ├── model/                 # PrefKeys, DiscoveredAppInfo, …
│       │   ├── nlp/                   # EphemeralMLKit, Fallback, LocationPill
│       │   ├── publisher/             # Silent companion publisher
│       │   ├── receiver/              # ActionBroadcastReceiver
│       │   ├── repository/            # Installed apps + OEM keep-alive
│       │   ├── service/               # NotificationProcessorService (daemon)
│       │   └── wear/                  # WearSyncService
│       └── src/test/                  # JUnit suite (8 test classes)
├── assets/                     # Onboarding assets
├── lib/                        # 📱 Flutter cockpit (OLED dark utility)
│   ├── core/                   # Native MethodChannel bridge, tokens, theme
│   ├── features/               # Onboarding, dashboard, apps, persona, filters…
│   └── shared/                 # Reply pills, metrics, state badges
└── test/                       # Dart unit + widget tests
```

---

## 🔒 Privacy & zero-cloud guarantee

WristReply AI does not declare `android.permission.INTERNET` in its production manifest.

- **Zero network calls** — no telemetry, no analytics, no remote APIs.
- **100% on-device processing** — all NLP generation and token extraction runs locally.
- **Ephemeral lifecycle** — ML Kit clients and notification bundles are disposed immediately after use.
- **Hardened manifest** — `android:allowBackup="false"` plus a `data_extraction_rules.xml` that excludes
  every preference file from cloud backup and device transfer.

The Play Console Data Safety form can honestly state:
**no user data collected, no user data shared with third parties.**

---

## 🛠 Building & running

### Requirements

- **Flutter** 3.47.6 (Dart 3.13.5) — pinned in `.github/workflows/`, constrained in `pubspec.yaml`
- **JDK** 17
- **Android SDK** API 34+ (min SDK 26, compile SDK 36)

### 1 · Run the Flutter cockpit

```bash
flutter pub get
flutter run
```

### 2 · Run the Dart tests

```bash
flutter test
```

### 3 · Run the Kotlin engine tests

```bash
cd android
echo "flutter.sdk=$FLUTTER_ROOT" > local.properties   # or run `flutter pub get` once
./gradlew :core-engine:testDebugUnitTest
```

### 4 · Build the standalone core-engine AAR

```bash
cd android
./gradlew :core-engine:assembleRelease
# → build/core-engine/outputs/aar/core-engine-release.aar
```

### 5 · Embed the headless engine in your own Android app

```kotlin
class YourApp : Application() {
    override fun onCreate() {
        super.onCreate()
        com.wristreply.core.EngineBootstrap.initialize(this)
    }
}
```

That is it — incoming notifications start receiving reply pills through the WristReply
`NotificationProcessorService`.

---

## 🤖 Build & release

| Workflow | Trigger | What it does |
| --- | --- | --- |
| [`.github/workflows/flutter.yml`](.github/workflows/flutter.yml) | push / PR to `main` | `flutter analyze`, `flutter test` with coverage |
| [`.github/workflows/android.yml`](.github/workflows/android.yml) | push / PR to `main` | `flutter build apk` (debug + release), app bundle, `:core-engine:testDebugUnitTest`, AAR |
| [`.github/workflows/docs.yml`](.github/workflows/docs.yml) | push / PR touching `**.md` | `markdownlint-cli2` over every Markdown file |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | tag `v*.*.*` or manual | AAR + AAB + APK uploaded to a GitHub Release |

To cut a release:

```bash
git tag v0.2.0
git push origin v0.2.0
```

---

## ⌚ Smartwatch compatibility

| Platform | Support type | Method |
| --- | --- | --- |
| **Wear OS** (Pixel Watch, Galaxy Watch) | Full native / direct reply | Notification actions mirror with inline reply; optional Data Layer push |
| **Zepp OS** (Amazfit) | Companion action mirroring | Zepp JS micro-app relays pills over the mobile bridge |
| **RTOS / budget watches** (boAt, Noise, Fire-Boltt) | Action trigger mirroring | Standard notification action mirroring — no companion app |

---

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).

## 📚 Additional documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — engineering etiquette, code conventions, review workflow.
- [`SECURITY.md`](SECURITY.md) — zero-cloud security policy and responsible disclosure.
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — Contributor Covenant v2.1.
- [`CHANGELOG.md`](CHANGELOG.md) — full release history.
- [`engineering.md`](engineering.md) — authoritative architectural blueprint.
- [`aso.md`](aso.md) — store listing and ASO copy.
- [`android/core-engine/README.md`](android/core-engine/README.md) — embedding the Kotlin engine.

