# WristReply Core Engine ⚡⌚

[![Android](https://img.shields.io/badge/Platform-Android%208.0%2B%20(API%2026%2B)-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.4-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Privacy](https://img.shields.io/badge/Privacy-Zero--Cloud%20%7C%20No%20INTERNET-green)](../../README.md#-privacy--zero-cloud-guarantee)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](../../LICENSE)

> **Standalone, on-device smart reply daemon, notification mirroring pipeline, and financial/OTP token
> extractor for Android and connected wearables.**

WristReply Core Engine provides zero-cloud conversational intelligence for Android applications,
bridging inline replies and companion actions to **Wear OS**, **Zepp OS**, and **budget RTOS
smartwatches** (boAt, Noise, Fire-Boltt, Amazfit) via native notification action mirroring.

The module has **zero Flutter dependencies** and builds to a plain AAR.

---

## 🌟 Features

- **Pure headless daemon** — runs as an isolated Android `NotificationListenerService`; the Flutter
  runtime is never booted in the background. Resident footprint **15–25 MB RAM**, **0% idle CPU**.
- **Dynamic messaging resolution** — discovers direct-reply endpoints at runtime by inspecting the
  notification's `RemoteInput` action, with no hardcoded package identifiers. Works with WhatsApp,
  Telegram, Signal, Slack, Discord, SMS and any inline-reply capable client.
- **Global multilingual fallback** — deterministic replies for 10 locales: English, Spanish, German,
  Portuguese, French, Arabic, Hindi (Devanagari), Hindi (Latin), Bengali and Banglish, each in casual,
  professional and late-night variants (24 banks × 3 pills).
- **Multi-regional token automation** — extracts transaction IDs from Apple Pay, Google Pay, PayPal,
  Stripe, UPI, Pix, iDEAL, bKash, GrabPay and bank SMS, plus multilingual OTP/2FA codes.
- **LPTE profanity shield** — on-device toxic-token filter with a 68-token default dictionary and a
  per-user blocklist.
- **Delayed auto-reply scheduler** — schedules delayed responses when the user is busy and cancels
  automatically if the notification is read or dismissed.
- **Silent companion mirroring** — publishes companions on an `IMPORTANCE_LOW` channel: no sound, no
  vibration, no screen wake.
- **Zero internet requirement** — the library declares no network permission at all.

---

## 📦 Installation

### Standalone AAR

Build it from this repository:

```bash
cd android
./gradlew :core-engine:assembleRelease
# → build/core-engine/outputs/aar/core-engine-release.aar
```

Then drop it into your app module's `libs/` directory:

```kotlin
dependencies {
    implementation(files("libs/core-engine-release.aar"))
}
```

### Composite build (for contributors)

```kotlin
// settings.gradle.kts
includeBuild("../WristReply/android/core-engine")
```

---

## 🚀 Quick start

### 1 · Register the headless daemon

Add `NotificationProcessorService` to your `AndroidManifest.xml`:

```xml
<service
    android:name="com.wristreply.core.service.NotificationProcessorService"
    android:label="WristReply Notification Engine"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

Grant the listener permission from Settings, then warm the engine from your `Application` class:

```kotlin
class YourApp : Application() {
    override fun onCreate() {
        super.onCreate()
        com.wristreply.core.EngineBootstrap.initialize(this)
    }
}
```

`EngineBootstrap.initialize` is idempotent, safe to call from multiple processes, and only warms the
preference cache and metrics ledger — the service itself is started by the system.

### 2 · Extract dynamic reply endpoints

```kotlin
val target = DynamicNotificationInspector.resolveReplyTarget(statusBarNotification)
if (target != null) {
    println("Sender: ${target.senderName}, Package: ${target.packageName}")
}
```

### 3 · Scan and auto-copy payment tokens or OTPs

```kotlin
val token = SmartTokenExtractor.scanAndExtract(
    text = messageText,
    autoCopyTrx = true,
    autoCopyOtp = true
)
if (token != null) {
    SmartTokenExtractor.copyToClipboard(context, token)
    println("Detected ${token.type}: ${token.value}")
}
```

### 4 · Resolve contextual fallback quick replies offline

```kotlin
val suggestions = FallbackReplyEngine.resolveFallback(
    incomingText = "¿Dónde estás ahora?",
    userCustomPills = emptyList(),
    tone = "casual",
    applyChronoBias = false
)
// → ["¡Dale, suena bien!", "¡Voy en camino!", "No puedo hablar ahora, te escribo."]
```

With the default `applyChronoBias = true` the engine swaps to the late-night bank between 23:00 and
06:59 local time:

```kotlin
// → ["Ya estoy durmiendo, hablamos mañana", "¿Puede esperar a mañana?", "Buenas noches"]
```

---

## 🧪 Tests

The engine ships a JUnit suite that runs on the JVM — no emulator required:

```bash
cd android
echo "flutter.sdk=$FLUTTER_ROOT" > local.properties   # or run `flutter pub get` once
./gradlew :core-engine:testDebugUnitTest
```

| Test class | Covers |
| --- | --- |
| `FallbackReplyEngineTest` | Per-locale banks, custom pill priority, chrono bias |
| `LocationPillResolverTest` | Locale-aware location pill wording and ordering |
| `SmartTokenExtractorTest` | OTP and transaction ID formats across 10+ payment rails |
| `ProfanityGuardEngineTest` | Default dictionary and user blocklist |
| `NotificationGateTest` | Notification flags, extras and message extraction |
| `MetricsLedgerTest` | Latency ledger averages and reset semantics |
| `MessageDebounceBufferTest` | 1.5 s debounce window and 5-message burst cap |
| `SmartReplyLruCacheTest` | Pure-JVM LRU eviction order |

`.github/workflows/android.yml` runs the same command on every pull request and uploads the
JUnit report as an artifact.

---

## 🧱 Module layout

| Package | Responsibility |
| --- | --- |
| `automation/` | Delayed reply scheduling and cancellation |
| `cache/` | LRU cache, hot preference cache |
| `context/` | Driving, calendar and location signals |
| `filters/` | Profanity guard, smart token extractor |
| `guard/` | Debounce buffer, sleep window, read resolver |
| `inspector/` | Notification gate, dynamic inspector |
| `metrics/` | Metrics ledger |
| `model/` | `PrefKeys`, `DiscoveredAppInfo`, value objects |
| `nlp/` | Ephemeral ML Kit, fallback banks, location pills |
| `publisher/` | Silent companion publisher |
| `receiver/` | `ActionBroadcastReceiver` |
| `repository/` | Installed apps, OEM keep-alive |
| `service/` | `NotificationProcessorService` (the daemon) |
| `wear/` | `WearSyncService` |

---

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](../../LICENSE) for details.
