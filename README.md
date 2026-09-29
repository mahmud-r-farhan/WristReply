# WristReply Core Engine ⚡⌚

[![Android](https://img.shields.io/badge/Platform-Android%208.0%2B%20(API%2026%2B)-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.1-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Privacy](https://img.shields.io/badge/Privacy-Zero--Cloud%20%7C%20No%20INTERNET-green)](README.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

> **Standalone, on-device smart reply daemon, notification mirroring pipeline, and financial/OTP token extractor for Android and connected wearables.**

WristReply Core Engine provides zero-cloud conversational intelligence for Android applications, bridging inline replies and companion actions to **Wear OS**, **Zepp OS**, and **budget RTOS smartwatches** (boAt, Noise, Fire-Boltt, Amazfit) via native notification action mirroring.

---

## 🌟 Features

- **Pure Headless Daemon**: Runs as an isolated Android `NotificationListenerService`. Operates at **15MB–25MB RAM** and **0% idle CPU**.
- **Dynamic Messaging Resolution**: Discovers direct-reply endpoints at runtime via semantic `RemoteInput` inspection without hardcoded package identifiers. Works with WhatsApp, Telegram, Signal, Slack, Discord, SMS, and any inline-reply enabled chat client.
- **Global Multi-Lingual Fallback**: Native deterministic replies for high-adoption smartwatch markets (**English, Spanish, German, Portuguese, French, Arabic**) plus Indic & regional language support (**Hindi, Bengali/Banglish**).
- **Multi-Regional Clipboard Automation**: Automatically scans and extracts transaction IDs from **Apple Pay, Google Pay, PayPal, Stripe, UPI, Pix, iDEAL, Bank SMS**, and multi-lingual OTP/2FA verification codes.
- **LPTE Profanity Shield**: Modular on-device toxic token filter with decoupled dictionaries and custom blocklists.
- **Delayed Auto-Reply Scheduler**: Schedules exact/inexact delayed responses when busy; automatically cancels if the user reads or dismisses the notification.
- **Zero Internet Requirement**: Production library declares zero network permissions (`android.permission.INTERNET` is not included).

---

## 📦 Installation

### Gradle (JitPack)

Add the JitPack repository to your root `settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

Add the dependency to your app module's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.github.mahmud-r-farhan:wristreply-core-engine:1.0.0")
}
```

### Standalone AAR

Alternatively, drop the pre-built `core-engine-release.aar` into your project's `libs/` directory:

```kotlin
dependencies {
    implementation(files("libs/core-engine-release.aar"))
}
```

---

## 🚀 Quick Start

### 1. Register the Headless Daemon
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

### 2. Extract Dynamic Reply Endpoints Programmatically
```kotlin
val target = DynamicNotificationInspector.resolveReplyTarget(statusBarNotification)
if (target != null) {
    println("Sender: ${target.senderName}, Package: ${target.packageName}")
}
```

### 3. Scan & Auto-Copy Multi-Regional Payment Tokens or OTPs
```kotlin
val token = SmartTokenExtractor.scanAndExtract(messageText)
if (token != null) {
    SmartTokenExtractor.copyToClipboard(context, token)
    println("Detected ${token.type}: ${token.value}")
}
```

### 4. Resolve Contextual Fallback Quick Replies Offline
```kotlin
val suggestions = FallbackReplyEngine.resolveFallback(
    incomingText = "¿Dónde estás ahora?",
    tone = "casual",
    applyChronoBias = true
)
// Returns: ["¡Aquí estoy!", "¡En camino!", "Voy ahora"]
```

---

## 📄 License
Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
