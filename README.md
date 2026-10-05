# WristReply AI ⚡⌚

> **Offline-first, on-device smart reply engine and wearable companion for Android.**  
> Delivers context-aware, low-latency quick reply actions directly onto notifications — mirroring seamlessly to Wear OS, Zepp OS, and budget RTOS smartwatches.

<div align="center">

[![CI](https://img.shields.io/badge/CI-passing-38EF7D?logo=githubactions&logoColor=white)](#-build--release)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)](android/)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.x-7F52FF?logo=kotlin&logoColor=white)](android/core-engine/)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](lib/)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](lib/)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-green)](#-privacy--zero-cloud-guarantee)
[![INTERNET](https://img.shields.io/badge/INTERNET-0%20permissions-critical)](#-privacy--zero-cloud-guarantee)
[![Playground](https://img.shields.io/badge/Playground-Live%20Web-00F2FE)](playground/)

</div>

---

## 🌟 Key Architecture & Highlights

- **Pure Headless Kotlin Engine** — The background daemon runs as an Android `NotificationListenerService` inside the decoupled `:core-engine` module. Flutter is **never** spun up in the background, maintaining **15–25 MB RAM** and **0% idle CPU**.
- **Decoupled `:core-engine` Module** — The engine has zero Flutter dependencies and can be compiled into a standalone `.aar` or published directly to Maven / GitHub packages for use in any native Android app via the `EngineBootstrap` entry point.
- **Dynamic Messaging Detection** — Zero hardcoded package lists. The engine inspects active notifications for pending `RemoteInput` reply actions, working immediately with WhatsApp, Telegram, Signal, Slack, Messenger, SMS, and more.
- **Global Multi-Lingual Fallback** — Built for real-world smartwatch demographics:
  - **Tier 1 (High Smartwatch Adoption)**: English (`en`), Spanish (`es`), German (`de`), Portuguese (`pt`), French (`fr`), Arabic (`ar`).
  - **Tier 2 (Indic & Regional Support)**: Hindi (`hi`), Bengali/Banglish (`bn`).
- **On-Device ML Kit Inference** — Ephemeral on-demand Google ML Kit Smart Reply client lifecycle with a 2.5 s safety timeout and `close()` in a `finally` block.
- **LPTE Profanity Guard** — Decoupled multi-lingual toxic token filter (`DefaultBlockedWords.kt`) with regex sanitization and customizable user blocklists.
- **Smart Token & OTP Auto-Copy** — Automatically extracts OTP verification codes and banking transaction IDs (Apple Pay, Google Pay, PayPal, Stripe, Pix, iDEAL, UPI, Bank SMS), injecting an instant 1-tap "Copy [Token]" action on your watch.
- **Silent Injected Actions** — Action injections use `IMPORTANCE_LOW` companion groups, ensuring zero duplicate rings, buzzes, or screen wakeups.
- **Context-Aware Pill Enhancers** — Bluetooth car-audio detection injects `[🚗 Driving]`, calendar busy-mints inject `[📅 Meeting until 3:30 PM]`, and chrono bias swaps late-night banks automatically.
- **OLED Dark Utility Cockpit** — High-contrast Flutter UI for managing app whitelists, persona quick-replies, sleep gates, and a **live test sandbox** mirroring the Kotlin contract.
- **Web Playground** — [`playground/`](playground/) ships a standalone Flutter Web app that demonstrates the same reply engine in any browser. Deployed automatically to GitHub Pages.

---

## 🏛 Architecture Overview

```
                      ┌──────────────────────────────────────────────┐
                      │            Active Notification Feed          │
                      │       (WhatsApp, Telegram, Signal, SMS)      │
                      └──────────────────────┬───────────────────────┘
                                             │
                                             ▼
                      ┌──────────────────────────────────────────────┐
                      │    NotificationProcessorService (Headless)   │
                      │             [android/core-engine]            │
                      └──────┬───────────────────────┬───────────────┘
                             │                       │
           ┌─────────────────▼────────┐    ┌─────────▼────────────────┐
           │ DynamicNotificationGate  │    │ SmartTokenExtractor      │
           │  (RemoteInput, Whitelist)│    │  (OTP / TrxID Detection) │
           └─────────────────┬────────┘    └─────────┬────────────────┘
                             │                       │
      ┌──────────────────────┴───────────────────────┼────────────────┐
      │                                              │                │
      ▼                                              ▼                ▼
┌──────────────────────────┐           ┌──────────────────┐    ┌──────────────┐
│  EphemeralMLKitEngine    │           │ ProfanityGuard   │    │ 1-Tap "Copy" │
│  (On-Device ML Client)   │           │ (Decoupled Words)│    │ Action Pill  │
└─────────────┬────────────┘           └────────────┬─────┘    └──────┬───────┘
              │ (If ML Kit empty/unsupported)        │               │
              ▼                                     │               │
┌──────────────────────────┐                        │               │
│  FallbackReplyEngine     │                        │               │
│  - EN / ES / DE / PT /   │                        │               │
│    FR / AR / HI / BN     │                        │               │
└─────────────┬────────────┘                        │               │
              │                                     │               │
              └─────────────────┬───────────────────┘               │
                                │                                    │
                                ▼                                    │
               ┌─────────────────────────────────┐                   │
               │   ContextualReplyEnhancer       │                   │
               │   (Driving / Meeting / Chrono)  │                   │
               └────────────────┬────────────────┘                   │
                                │                                    │
                                ▼                                    ▼
               ┌─────────────────────────────────────────────────────┐
               │ NotificationPublisher (Silent Companion Group)      │
               │ - Android notification shade                       │
               │ - Wear OS / Zepp OS / RTOS smartwatches           │
               └─────────────────────────────────────────────────────┘
```

## 📁 Repository Structure

```
WristReply/
├── .github/workflows/          # CI, release, and playground deploy jobs
├── android/
│   ├── app/                    # Flutter Android Host Container
│   │   └── src/main/kotlin/... # MethodChannel Bridge & SharedPreferences
│   └── core-engine/            # 🚀 STANDALONE KOTLIN LIBRARY MODULE
│       ├── build.gradle.kts    # Pure com.android.library (Zero Flutter deps)
│       ├── src/main/kotlin/com/wristreply/core/
│       │   ├── EngineBootstrap.kt     # 5-line public entry point for embedding
│       │   ├── cache/                  # LRU Cache & Hot Preferences cache
│       │   ├── filters/                # DefaultBlockedWords & ProfanityGuardEngine
│       │   ├── guard/                  # MessageDebounce, SleepWindow, ReadResolver
│       │   ├── inspector/              # DynamicNotificationInspector & Gate
│       │   ├── metrics/                # MetricsLedger (in-memory ring buffer)
│       │   ├── model/                  # PrefKeys, DiscoveredAppInfo, …
│       │   ├── nlp/                    # EphemeralMLKit, Fallback, LocationPill
│       │   ├── publisher/              # Silent Companion Group publisher
│       │   ├── receiver/               # ActionBroadcastReceiver (headless dispatch)
│       │   ├── repository/             # InstalledApps & OEM Keep-Alive manager
│       │   ├── service/                # NotificationProcessorService (daemon)
│       │   ├── automation/             # DelayedReplyScheduler
│       │   ├── context/                # Driving, Calendar, Location helpers
│       │   └── wear/                   # WearSyncService
│       └── src/test/                   # JUnit unit test suite
├── assets/                      # Onboarding assets
├── docs/                        # Engineering, ASO, security, contributing docs
├── lib/                         # 📱 FLUTTER COCKPIT (OLED Dark Utility)
│   ├── core/                    # Native MethodChannel bridge, tokens & theme
│   ├── features/                # Dashboard, App Whitelist, Persona, Filters…
│   └── shared/                  # Atomic preview pills, metrics & state badges
├── playground/                  # 🌐 FLUTTER WEB DEMO (auto-deployed to GH Pages)
│   ├── lib/                     # Single-file Flutter Web playground
│   ├── web/                     # Custom splash screen + PWA manifest
│   └── test/                    # Locale detection unit tests
└── test/                        # Dart unit tests
```

---

## 🔒 Privacy & Zero-Cloud Guarantee

WristReply AI does not declare the `android.permission.INTERNET` permission in its production manifest.

- **Zero Network Calls** — No telemetry, no cloud analytics, no remote APIs.
- **100% On-Device Processing** — All NLP generation and token extractions execute locally.
- **Ephemeral Lifecycle** — ML Kit models and notification bundles are disposed immediately after rendering suggestions.
- **Hardened Manifest** — `android:allowBackup="false"` plus a `data_extraction_rules.xml` excluding every preference file from cloud backup and device transfer.

The Google Play Console Data Safety form can honestly state: **No user data collected, no user data shared with third parties.**

---

## 🛠 Building & Running

### Requirements

- **Flutter**: 3.24+ (Dart 3.5+)
- **Android SDK**: API 34+ (Android 14 ready, Min SDK 26)
- **JDK**: Java 17

### 1. Build and Run Flutter Client
```bash
flutter pub get
flutter run
```

### 2. Run Engine Unit Tests (Kotlin)
```bash
cd android
./gradlew :core-engine:testDebugUnitTest
```

### 3. Run Flutter Unit Tests
```bash
flutter test
```

### 4. Build Core Engine AAR (Standalone Library)
```bash
cd android
./gradlew :core-engine:assembleRelease
# Standalone AAR is emitted at:
# android/core-engine/build/outputs/aar/core-engine-release.aar
```

### 5. Run the Web Playground locally
```bash
cd playground
flutter pub get
flutter run -d chrome
```

### 6. Embed the headless engine in your own Android app
```kotlin
// In your Application.onCreate
class YourApp : Application() {
    override fun onCreate() {
        super.onCreate()
        com.wristreply.core.EngineBootstrap.initialize(this)
    }
}
```
That's it — your existing notifications will start receiving reply pills via the WristReply `NotificationProcessorService`.

---

## 🤖 Build & Release

| Workflow | Trigger | Output |
|---|---|---|
| `.github/workflows/ci.yml` | PR / push to `main` and `arena/**` | Flutter analyze + test, Kotlin JUnit, Markdown lint |
| `.github/workflows/release.yml` | Push of tag `v*.*.*` | Signed Android APK, core-engine AAR, GitHub Release |
| `.github/workflows/playground.yml` | Push to `main` touching `playground/**` | Live Flutter Web demo on GitHub Pages |

To cut a new release:
```bash
git tag v0.2.0
git push origin v0.2.0
```
The release workflow will sign and upload the artifacts and publish the GitHub Release automatically.

---

## ⌚ Smartwatch Compatibility

| Platform | Support Type | Method |
|---|---|---|
| **Wear OS** (Pixel Watch, Galaxy Watch) | Full Native / Direct Reply | Mirrors Android Notification Actions with inline reply |
| **Zepp OS** (Amazfit) | Companion Action Mirroring | Zepp app notification bridge syncs quick-reply pills |
| **RTOS / Budget Smartwatches** | Action Trigger Mirroring | Mirrored notification alert actions trigger quick responses |

---

## 📄 License
Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

## 📚 Additional Documentation
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — Engineering etiquette, code conventions, review workflow.
- [`SECURITY.md`](SECURITY.md) — Zero-cloud security policy and responsible disclosure.
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — Contributor Covenant v2.1.
- [`CHANGELOG.md`](CHANGELOG.md) — Full release history.
- [`engineering.md`](engineering.md) — Authoritative architectural blueprint.
- [`playground/README.md`](playground/README.md) — Web playground documentation.