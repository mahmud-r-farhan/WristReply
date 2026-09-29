# WristReply AI ⚡⌚

> **Offline-first, on-device smart reply engine and wearable companion for Android.**  
> Delivers context-aware, low-latency quick reply actions directly onto notifications—mirroring seamlessly to Wear OS, Zepp OS, and budget RTOS smartwatches.

[![Android CI](https://img.shields.io/badge/Android-Java%2017%20%7C%20Kotlin%202.1-3DDC84?logo=android&logoColor=white)](android/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](lib/)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-green)](#privacy--zero-cloud-guarantee)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

---

## 🌟 Key Architecture & Highlights

- **Pure Headless Kotlin Engine**: The background daemon runs as an Android `NotificationListenerService` inside the decoupled `:core-engine` module. Flutter is **never** spun up in the background, maintaining **15–25 MB RAM** and **0% idle CPU**.
- **Decoupled `:core-engine` Module**: The engine has zero Flutter dependencies and can be compiled into a standalone `.aar` or published directly to Maven / GitHub packages for use in any native Android app.
- **Dynamic Messaging Detection**: Zero hardcoded package lists. The engine automatically inspects active notifications for pending `RemoteInput` reply actions, working immediately with WhatsApp, Telegram, Signal, Slack, Messenger, SMS, and more.
- **Global Multi-Lingual Fallback**: Built for real-world smartwatch demographics:
  - **Tier 1 (High Smartwatch Adoption)**: English (`en`), Spanish (`es`), German (`de`), Portuguese (`pt`), French (`fr`), Arabic (`ar`).
  - **Tier 2 (Indic & Regional Support)**: Hindi (`hi`), Bengali/Banglish (`bn`).
- **On-Device ML Kit Inference**: Ephemeral on-demand Google ML Kit Smart Reply client lifecycle (`close()` immediately after generation) to avoid lingering memory footprint.
- **LPTE Profanity Guard**: Decoupled multi-lingual toxic token filter (`DefaultBlockedWords.kt`) with regex sanitization and customizable user blocklists.
- **Smart Token & OTP Auto-Copy**: Automatically extracts OTP verification codes and banking transaction IDs (Apple Pay, Google Pay, PayPal, Stripe, Pix, iDEAL, UPI, Bank SMS), injecting an instant 1-tap "Copy [Token]" action on your watch.
- **Silent Injected Actions**: Action injections use `IMPORTANCE_LOW` companion groups, ensuring zero duplicate rings, buzzes, or screen wakeups.
- **OLED Dark Utility Cockpit**: High-contrast Flutter UI for managing app whitelists, persona quick-replies, sleep gates, and live notification simulation.

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
└─────────────┬────────────┘           └────────┬─────────┘    └──────┬───────┘
              │ (If ML Kit empty/unsupported)   │                     │
              ▼                                 │                     │
┌──────────────────────────┐                    │                     │
│  FallbackReplyEngine     │                    │                     │
│  - EN / ES / DE / PT /   │                    │                     │
│    FR / AR / HI / BN     │                    │                     │
└─────────────┬────────────┘                    │                     │
              │                                 │                     │
              └─────────────────┬───────────────┘                     │
                                │                                     │
                                ▼                                     │
               ┌─────────────────────────────────┐                    │
               │   NotificationPublisher (Silent)│◄───────────────────┘
               │  - Companion Group Injections   │
               │  - Mirrored to Wear OS / RTOS   │
               └─────────────────────────────────┘
```

---

## 📁 Repository Structure

```
WristReply/
├── android/
│   ├── app/                      # Flutter Android Host Container
│   │   └── src/main/kotlin/...   # MethodChannel Bridge & SharedPreferences
│   └── core-engine/              # 🚀 STANDALONE KOTLIN LIBRARY MODULE
│       ├── build.gradle.kts      # Pure com.android.library (Zero Flutter deps)
│       ├── src/main/kotlin/com/wristreply/core/
│       │   ├── cache/            # LRU Cache & In-Memory Hot Preferences Cache
│       │   ├── filters/          # DefaultBlockedWords & ProfanityGuardEngine
│       │   ├── guard/            # MessageDebounce, SleepWindow, ReadResolver
│       │   ├── inspector/        # DynamicNotificationInspector & RemoteInput Gate
│       │   ├── metrics/          # MetricsLedger (In-memory ring buffer)
│       │   ├── nlp/              # Ephemeral ML Kit & Multi-Lingual Fallback Banks
│       │   ├── publisher/        # Silent Companion Group Notification Publisher
│       │   ├── receiver/         # ActionBroadcastReceiver (Headless Dispatcher)
│       │   ├── repository/       # InstalledApps & OEM Keep-Alive Manager
│       │   └── service/          # NotificationProcessorService (Daemon)
│       └── src/test/             # Fast JUnit unit test suites
└── lib/                          # 📱 FLUTTER COCKPIT (OLED Dark Utility)
    ├── core/                     # Native MethodChannel bridge, tokens & theme
    ├── features/                 # Dashboard, App Whitelist, Persona, Filters
    └── shared/                   # Atomic preview pills, metrics & state badges
```

---

## 🔒 Privacy & Zero-Cloud Guarantee

WristReply AI does not declare the `android.permission.INTERNET` permission in its production manifest.
- **Zero Network Calls**: No telemetry, no cloud analytics, no remote APIs.
- **100% On-Device Processing**: All NLP generation and token extractions execute locally.
- **Ephemeral Lifecycle**: ML Kit models and notification bundles are disposed immediately after rendering suggestions.

---

## 🛠 Building & Running

### Requirements
- **Flutter**: 3.24+ (Dart 3.5+)
- **Android SDK**: API 34+ (Android 14 ready, Min SDK 26)
- **JDK**: Java 17

### 1. Build and Run Flutter Client
```bash
# Install dependencies
flutter pub get

# Run on connected Android device
flutter run
```

### 2. Run Engine Unit Tests
```bash
# Navigate to android directory
cd android

# Run standalone core-engine unit tests
./gradlew :core-engine:testDebugUnitTest
```

### 3. Build Core Engine AAR (Standalone Library)
```bash
cd android
./gradlew :core-engine:assembleRelease
# The standalone AAR will be generated at:
# android/core-engine/build/outputs/aar/core-engine-release.aar
```

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
