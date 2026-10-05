# Comprehensive Engineering Specification & Architecture Manual: WristReply AI

This document serves as the authoritative blueprint for autonomous AI coding agents, software engineers, and system architects building the WristReply AI application. It consolidates all functional prerequisites, engineering constraints, component modularization rules, operating system boundaries, and zero-leakage privacy contracts.

---

## 1. Executive Product Definition & Architectural Persona

WristReply AI is an on-device, offline-first communication utility engineered for Android and paired smart wearables. The system intercepts incoming conversational alerts across supported messaging platforms, synthesizes high-probability contextual response suggestions locally using Google ML Kit NLP, and exposes them as interactive action pills across the Android notification drawer, budget RTOS smartwatch displays, Zepp OS companion interfaces, and Wear OS clients.

The application adheres strictly to zero-cloud computing principles. The software completely eliminates standard network communication for core text processing, guaranteeing zero privacy leakage, sub-50ms inference latency, and full compliance with Google Play Console policies governing high-privilege Android services.

---

## 2. Low-Level Component Decoupling & Modular Architecture

To guarantee low resident memory overhead and high maintainability, the codebase enforces an absolute architectural separation between the native Android background daemon and the user-facing Flutter presentation layer.

```

```
                ┌──────────────────────────────────────────────┐
                │          Android Notification Event          │
                └──────────────────────┬───────────────────────┘
                                       │
                                       ▼
         ┌────────────────────────────────────────────────────────────┐
         │       Headless Kotlin Daemon (Pure Native Process)         │
         │                                                            │
         │  ┌────────────────────────┐    ┌────────────────────────┐  │
         │  │   NotificationGate     │───►│ DynamicTargetResolver  │  │
         │  └────────────────────────┘    └───────────┬────────────┘  │
         │                                            │               │
         │  ┌────────────────────────┐                ▼               │
         │  │ EphemeralMLKitEngine   │◄───[Extracts RemoteInput]      │
         │  └───────────┬────────────┘                                │
         │              │                                             │
         │              ▼                                             │
         │  ┌────────────────────────┐    ┌────────────────────────┐  │
         │  │  PillInjectionService  │───►│ ActionBroadcastReceiver│  │
         │  └────────────────────────┘    └────────────────────────┘  │
         └────────────────────────────────────────────────────────────┘
                                       │
                    (Reads Preferences via Native Disk)
                                       │
                                       ▼
         ┌────────────────────────────────────────────────────────────┐
         │           Presentation Client (Flutter Framework)          │
         │       [Instantiated ONLY when User Opens App UI]           │
         │                                                            │
         │  ┌──────────────────────────────────────────────────────┐  │
         │  │ Atomic UI Widgets: StateBadge, MetricsCard, PillView │  │
         │  └──────────────────────────────────────────────────────┘  │
         │  ┌──────────────────────────────────────────────────────┐  │
         │  │ Domain Repositories: WhitelistRepo, FallbackRepo     │  │
         │  └──────────────────────────────────────────────────────┘  │
         └────────────────────────────────────────────────────────────┘

```

```

### 2.1 The Native Daemon Boundary
The background execution pipeline runs entirely in native Kotlin inside an isolated `NotificationListenerService`. The Flutter runtime must never be booted or held active in memory during background alert processing. All configuration data set by the user inside Flutter is synchronized directly into native Android `SharedPreferences`. The headless Kotlin service reads this file directly, maintaining a steady-state resident memory profile of 15MB to 25MB and zero CPU usage while idle.

### 2.2 Atomic Flutter Architecture
The presentation layer is decomposed into micro-widgets where no single file exceeds 150 lines of code. State is scoped locally, eliminating unnecessary global rebuilds. Widgets are cataloged into Atomic Foundations (colors, typography tokens, status chips), Molecule Tiles (toggle rows, metric snapshot containers, pill previews), and Screen Templates (onboarding handshake, cockpit dashboard, tone rules engine).

---

## 3. Detailed Modular Engineering Pipeline

### 3.1 Ingestion & Heuristic Validation (`NotificationGate.kt`)
The ingestion pipeline filters incoming Android alerts before allocating NLP compute resources. The component evaluates notifications against three non-negotiable criteria:
1. The alert must not possess the `FLAG_ONGOING_EVENT` bitmask, discarding media player sessions, active downloads, and background system monitors.
2. The alert must not contain the `FLAG_GROUP_SUMMARY` bitmask, discarding parent notification bundles posted by multi-message messaging apps.
3. The notification must carry either a valid `Notification.CATEGORY_MESSAGE` tag, an active `Notification.MessagingStyle` bundle, or an explicit non-blank `EXTRA_TEXT` payload.

### 3.2 Dynamic Reflection & RemoteInput Extraction (`DynamicTargetResolver.kt`)
To avoid hardcoding package names, the resolver scans the notification's action hierarchy at runtime. It searches standard `Notification.Action` collections and `NotificationCompat.WearableExtender` action arrays for instances of `RemoteInput` carrying a non-null `resultKey`. When an actionable input field is discovered, the resolver constructs an immutable target bundle encapsulating the sender identity, message body, package origin, result key, and target `PendingIntent`.

### 3.3 Ephemeral Natural Language Processing (`EphemeralMLKitEngine.kt`)
Inference utilizes Google ML Kit Smart Reply (`com.google.mlkit:smart-reply`). The client instance is initialized on demand on `Dispatchers.Default`. The message is analyzed within a structured conversation context. If the model succeeds, the suggestions are forwarded down the pipeline. Regardless of whether the computation succeeds, yields an empty list, or encounters a language mismatch, the client is closed immediately within a `finally` block to trigger immediate garbage collection.

### 3.4 Multi-Tier Language Fallback Provider (`FallbackEngine.kt`)
Because ML Kit focuses on standard English, the engine falls back to a deterministic rule pipeline when ML Kit returns an empty collection. The fallback engine evaluates incoming strings through three priority gates:
1. **User Custom Overrides:** Static quick-replies configured in the UI are returned first.
2. **Benglish & Transliteration Matcher:** Regular expressions inspect the input for common romanized terms (e.g., "kemon", "kothay", "hobe") and supply relevant replies.
3. **Script-Specific Defaults:** The presence of Bengali Unicode (`U+0980` to `U+09FF`) routes to a curated default Bengali response bank, while standard Latin text defaults to a lightweight English bank.

### 3.5 Action Injection & Watch Mirroring (`PillInjectionService.kt`)
The service publishes a silent, non-intrusive notification containing the generated smart replies mapped to individual `NotificationCompat.Action` buttons. This notification is published to a dedicated channel configured with `IMPORTANCE_LOW`, explicitly disabling vibration, lights, and auditory alerts. The system automatically mirrors these action buttons to connected Wear OS and RTOS smartwatches.

### 3.6 Headless Message Dispatch (`ActionBroadcastReceiver.kt`)
When an action pill is tapped on the watch or in the notification tray, the assigned `PendingIntent` fires a broadcast to `ActionBroadcastReceiver`. The receiver instantiates a new `RemoteInput` result bundle containing the selected text, attaches it to the original messaging app's intent via `RemoteInput.addResultsToIntent()`, and executes `PendingIntent.send()`. The reply is dispatched directly to the messaging server without unlocking the phone or launching the messaging UI.

---

## 4. Multi-Platform Wearable Sync Protocols

### 4.1 Wear OS Full Companion Path
For Wear OS watches, communication bypasses standard notification mirroring in favor of the Google Play Services Wearable Data Layer. The Android phone daemon uses `Wearable.getMessageClient()` to dispatch a compact JSON payload containing the notification identifier and an array of reply strings to the `/smart_replies` path. A lightweight companion app built with Wear Compose renders high-contrast interactive chips across a 44dp vertical stack. Tapping a chip transmits a message back to the phone daemon to trigger remote dispatch.

### 4.2 Zepp OS (Amazfit) Path
For Zepp OS devices, synchronization operates via a JavaScript-based micro-app running on the watch communicating through the Zepp Mobile Bridge. The phone daemon communicates with the local Zepp bridge service over a local loopback port, relaying reply tokens to the watch screen.

### 4.3 Universal Budget RTOS Path
For closed-source RTOS devices (boAt, Noise, Fire-Boltt), the system relies completely on native Android notification mirroring. Because these watches listen to standard notification actions, the custom actions injected into the notification drawer show up directly on the watch display as stock Quick Replies.

---

## 5. UI/UX Design System & Human-Interface Guidelines

### 5.1 Visual Token Architecture
The presentation layer implements an **OLED Dark Utility** design language.
* **Canvas Background:** `#0B0E14` (Deep Obsidian for minimal battery usage).
* **Raised Surface Cards:** `#131823` (Subtle 1dp elevation with `#222B3D` borders).
* **Interactive Elements:** `#1C2333` base pill with `#38EF7D` (Signal Mint) for active status and confirmation indicators.
* **Typography:** `Space Grotesk` for titles, numeric metrics, and primary buttons; `Inter` for settings copy and body text.

### 5.2 Kinetic Specs & Touch Ergonomics
* All mobile interactive chips adhere to a minimum touch bounding box of **48dp × 48dp**, while wearable targets scale to a minimum height of **44dp**.
* Interactive chips respond to user touches with a scale transition from `1.00` down to `0.96` over 90ms, springing back to `1.00` on release accompanied by a brief haptic click (`HapticFeedbackType.lightImpact`).
* Loading screens and spinning progress indicators are excluded from the app design. Layouts render instantly from local cache, while dynamic updates hydrate via subtle shimmer transitions.

---

## 6. Stability, Background Persistence & Platform Compliance

### 6.1 OEM Keep-Alive Strategy
Custom Android ROMs (Xiaomi HyperOS, Samsung One UI, Oppo ColorOS) routinely kill long-running background services. The application counters this by routing users through system-level exemption flows:
* The onboarding flow directs users to `Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` to request exemption from system Doze restrictions.
* An OEM dispatch utility checks device manufacturer strings (`Build.MANUFACTURER`) and launches manufacturer-specific autostart management activities (e.g., Xiaomi Security Center, Huawei Startup Manager).
* In the event that the service is killed by the operating system, the service overrides `onListenerDisconnected()` to trigger an automatic rebind via `requestRebind()`.

### 6.2 Google Play Developer Policy Compliance
The codebase maintains compliance with strict Google Play policies:
* **Zero Internet Build Configuration:** The base manifest excludes `android.permission.INTERNET`, providing architectural proof that user conversations cannot leave the physical device.
* **Transparent Onboarding:** The initial launch flow displays a mandatory disclosure screen explaining that `NotificationListenerService` access is utilized exclusively for generating on-device smart replies.
* **Data Safety Standards:** The Google Play Console Data Safety form can honestly state: **No user data collected, no user data shared with third parties**.

```

---
