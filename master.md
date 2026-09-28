# WristReply AI — Master Build Document (Single Source of Truth)

> **Status:** Authoritative specification · **Version:** 1.0.0 · **Last consolidated:** 2026-09-28
> **Audience:** Senior Android/Flutter engineers, autonomous AI coding agents, release managers, and product owners.
> **Purpose:** One document that contains every requirement, process, guide, code reference, implementation detail, store-facing copy, and quality gate needed to build, test, and ship WristReply AI.
> **Companion docs:** `engineering.md`, `agents.md`, `Technical Architecture.md`, `dynamic_app_detection.md`, `smart_parser_and_filter.md`, `system_feasibility_and_optimization.md`, `ui-ux.md`, `gradle.md`, `aso.md`, `PESG.md`, `followup.md`, `HUMAN_TASKS.md` (human-only), `prompt.txt` (build directive).

---

## 0. How To Use This Document

### 0.1 Precedence Order (Conflict Resolution)

When two documents disagree, resolve in this exact order — highest wins:

| Rank | Source | Governs |
| :--- | :--- | :--- |
| 1 | `prompt.txt` (build directive) | Core architectural rules, non-negotiables |
| 2 | `master.md` (this file) | Consolidated requirements, IDs, gates, acceptance criteria |
| 3 | `engineering.md` | Low-level component engineering & optimization |
| 4 | `agents.md` / `Technical Architecture.md` | Concrete Kotlin/Flutter reference implementations |
| 5 | `dynamic_app_detection.md` | App discovery & RemoteInput resolution |
| 6 | `smart_parser_and_filter.md` | LPTE profanity shield + OTP/TrxID clipboard engine |
| 7 | `system_feasibility_and_optimization.md` | Roadmap, fallbacks, market positioning |
| 8 | `ui-ux.md` | Visual tokens, motion, screens |
| 9 | `gradle.md` | Build system configuration |
| 10 | `aso.md` | Store copy |
| 11 | `HUMAN_TASKS.md` | **Human-only tasks — never executed by an agent** |

> **Agent directive (verbatim from `prompt.txt`):** Ignore `HUMAN_TASKS.md` during automated code generation. It exists solely for the human developer.

### 0.2 Note On Code Blocks In This Document

Every Kotlin/Dart/XML/Groovy block below is a **reference specification**, not a file already present on disk. This document is documentation-only; it defines what the implementation must contain. The repository currently holds documentation and no application source tree.

### 0.3 Requirement ID Scheme

* `FR-x.y` — Functional requirement
* `NFR-x.y` — Non-functional requirement
* `CR-x.y` — Compliance/regulatory requirement
* `AC-…` — Acceptance criterion attached to a deliverable
* `GATE-x` — Phase exit gate (must all pass before advancing)

---

## 1. Product Identity & ASO Pack

### 1.1 Friendly Name & Branding

| Field | Value | Notes |
| :--- | :--- | :--- |
| **Friendly name (internal & in-app)** | **WristReply AI** | Used in UI, code (`com.wristreply.app`), and this document |
| **Store title (Play, ≤30 chars)** | **`WristReply: Smart AI Auto Text`** | 30/30 characters — at the hard limit, do not extend |
| **Alternate store title B** | `WristReply: Watch Quick Reply` | 30/30 — use if keyword testing favors "Quick Reply" |
| **Alternate store title C** | `WristReply AI: Offline Replies` | 30/30 — use if "Offline" tests better |
| **Short name (launcher)** | `WristReply` | ≤12 chars, no truncation on launcher |
| **Package / applicationId** | `com.wristreply.app` | Immutable once published |
| **Flutter project name** | `wrist_reply` | `pubspec.yaml`, import prefix `package:wrist_reply/` |
| **Tagline** | *"Reply from your wrist. Not from the cloud."* | Marketing / feature graphic |
| **Secondary tagline** | *"On-device smart replies for phones and every smartwatch."* | Onboarding hero copy |

**Naming rules**

1. Never write "WristReplyAI" (missing space) or "Wrist Reply" (split word) in user-visible copy.
2. Keep "AI" only where character budget allows; the product works fully offline and the name must not imply a cloud LLM.
3. Do not claim "works with Apple Watch" anywhere — the platform path does not exist.

### 1.2 Short Description (Play Store, ≤80 chars)

```
Instant offline smart replies for WhatsApp & Telegram on your phone and watch.
```

*Character count: 78/80 — verified.*

**Alternate short descriptions**

| Variant | Text | Purpose |
| :--- | :--- | :--- |
| A (default) | `Instant offline smart replies for WhatsApp & Telegram on your phone and watch.` | Balanced keyword + benefit |
| B | `One-tap smart replies for any smartwatch. 100% offline, zero cloud, no tracking.` | Privacy-forward |
| C | `Turn any budget smartwatch into a quick-reply machine. Offline AI suggestions.` | Budget-watch angle |
| D | `Auto text suggestions in your notification tray and on your Wear OS watch.` | Feature-literal |

### 1.3 Long Description (Play Store, ≤4000 chars)

```text
Tired of typing the same repetitive responses? WristReply brings on-device,
lightning-fast smart suggestions to all your incoming messages.

Whether you are using your Android phone or your connected smartwatch,
WristReply generates contextual, intelligent reply pills in real time without
ever compromising your privacy.

⚡ 100% PRIVATE & OFFLINE
Powered by Google ML Kit, all message processing happens locally on your
chipset. No internet connection required, no cloud servers, and zero data
tracking.

✨ KEY FEATURES:
• Instant Smart Replies: contextual response pills for WhatsApp, Telegram,
  Signal, SMS and any app that supports native quick reply.
• Works With Any Watch: Wear OS gets a native companion app; budget RTOS
  watches (boAt, Noise, Fire-Boltt, Mi Band) get the reply buttons through
  standard notification mirroring — no companion app required.
• One-Tap Dispatch: tap a suggested pill on your watch or in the notification
  tray to reply instantly, without unlocking your phone or opening the chat app.
• Smart Personas: Casual, Professional and Benglish/regional style banks so
  replies sound like you, not like a robot.
• Regional Language Fallback: if on-device AI cannot parse the message, a
  curated fallback bank (English, Bengali, Banglish) still gives you useful pills.
• Inappropriate Language Shield: optional on-device filter that flags abusive
  messages instead of generating cheerful replies.
• Smart Clipboard Automation: optional auto-copy of OTP codes and transaction
  IDs (bKash, Nagad, bank SMS and other payment formats) with a confirmation pill.
• Zero Battery Drain: the background engine runs in headless native code with
  a 15–25 MB steady-state footprint and 0% idle CPU.
• Full Control: choose which apps are monitored, edit your own quick replies,
  and toggle every feature from one console.

🔒 PERMISSIONS & PRIVACY DISCLOSURE
WristReply uses Android Notification Access to detect incoming chat messages so
it can attach smart reply actions to them. Your conversations are processed
strictly on-device. They are never stored, collected, uploaded, or sold. The
core build does not request the internet permission at all, which makes silent
data exfiltration technically impossible.

No account. No sign-up. No ads.
```

### 1.4 Keyword & Discovery Strategy

**Primary keywords (play a role in title or short description):**
`smart reply`, `wear os quick reply`, `auto reply offline`, `whatsapp smart reply`, `ml kit text`, `quick responses`, `android notification reply`

**Secondary / long-tail keywords (weave into long description naturally):**
`quick reply for budget smartwatch`, `boat watch quick reply`, `noise watch whatsapp reply`, `offline auto text`, `notification listener smart reply`, `bengali smart reply`, `banglish keyboard reply`, `wear os notification reply app`, `otp auto copy android`, `trxid auto copy bkash`

**ASO operating rules**

1. Never stuff keywords; Play penalizes repetition and the reviewer reads the copy.
2. The first 2 lines of the long description carry the most indexing weight — keep them benefit-led.
3. Every claim in the listing must be reproducible by a reviewer in under 60 seconds.
4. Update the listing screenshot set whenever the UI token palette changes (screenshots must match shipped UI).
5. Localize listing copy (Bengali first, then Hindi/Indonesian) only after the UI itself is localized.

### 1.5 Store Asset Checklist

| Asset | Spec | Required |
| :--- | :--- | :--- |
| App icon | 512×512 PNG, 32-bit, no alpha | ✔ |
| Feature graphic | 1024×500 JPG/PNG | ✔ |
| Phone screenshots | ≥4, 1080×1920+ (16:9, no device frames required) | ✔ |
| Wear OS screenshots | ≥2 if shipping the Wear companion module | Optional |
| 7-inch / 10-inch tablet screenshots | Not targeted — skip | ✖ |
| Promo video | 30s, unlisted YouTube (also used for the permission declaration) | ✔ (compliance) |
| Privacy policy URL | Publicly hosted, states 100% on-device processing | ✔ |

---

## 2. Executive Summary & Product Definition

**WristReply AI is an on-device, offline-first communication utility for Android and paired smart wearables.**

It listens for incoming conversational notifications, extracts the message context and the app's own direct-reply endpoint (`RemoteInput` + `PendingIntent`), generates high-probability contextual suggestions locally with Google ML Kit, and then exposes those suggestions as one-tap action buttons in the phone notification shade and on the user's watch. Tapping a suggestion dispatches the reply through the messaging app's own reply channel — no unlock, no app launch, no cloud round-trip.

**Core value propositions**

1. **Privacy by construction** — no conversation content ever leaves the device; the core build has no internet permission.
2. **Universal wearable coverage** — one engine covers Wear OS, Zepp OS, and closed RTOS watches via native notification action mirroring.
3. **Zero-battery background** — a headless Kotlin daemon with a 15–25 MB footprint; Flutter is never booted in the background.
4. **Resilience in real languages** — deterministic fallback banks (English, Bengali, Banglish) whenever the ML model returns nothing.

**Product personas (design targets)**

| Persona | Need | Winning feature |
| :--- | :--- | :--- |
| Budget-watch owner (boAt/Noise/Fire-Boltt) | Watch has no keyboard and no smart replies | RTOS notification mirroring path |
| Commuter / delivery rider | Reply without stopping or unlocking | One-tap pill dispatch, 48dp targets |
| Privacy-conscious professional | Doesn't trust cloud reply bots | Zero-internet build, on-device ML |
| Bengali/Banglish speaker | ML Kit gives poor or empty results | Fallback + persona banks |
| Wear OS power user | Wants a native on-watch UI | Wear Compose companion module |

---

## 3. Scope

### 3.1 In Scope — MVP (Phase 1)

| # | Capability |
| :--- | :--- |
| 1 | `NotificationListenerService` ingestion with notification gating |
| 2 | Dynamic app discovery & `RemoteInput` extraction (no hardcoded package lists) |
| 3 | On-device ML Kit Smart Reply generation (ephemeral lifecycle) |
| 4 | Silent companion notification with 1–3 action pills |
| 5 | Background dispatch via `PendingIntent` + `RemoteInput.addResultsToIntent()` |
| 6 | Per-app whitelist, master enable/disable, permission handshake (Flutter) |
| 7 | Fallback reply bank (English / Bengali / Banglish) |
| 8 | Console dashboard with live status + sandbox tester |
| 9 | OEM battery-optimization guidance + listener auto-rebind |
| 10 | Zero-internet release build flavour |

### 3.2 In Scope — V1.1 / Phase 2

| # | Capability |
| :--- | :--- |
| 1 | Wear OS companion module (Wear Compose chips + `MessageClient` round trip) |
| 2 | Persona & tone engine (Casual / Professional / Benglish) |
| 3 | Custom user-defined pills, reorderable |
| 4 | Chrono-aware suggestions (late night / work hours / driving) |
| 5 | Inappropriate Language Shield (LPTE) |
| 6 | OTP & transaction-ID auto-copy engine |
| 7 | Local metrics (replies generated, latency, dispatch source) with no PII |

### 3.3 Out of Scope (explicitly)

1. iOS, iPadOS, or Apple Watch support of any kind.
2. Any cloud LLM, account system, sign-in, sync, or backup.
3. Server-side message processing or analytics of message content.
4. `AccessibilityService`-based text injection into other apps' editor fields (Play-policy risk).
5. Ads, in-app purchases, or data monetization (also a Play-policy prohibition given the notification-listener permission).
6. Group-chat summarization or conversation-history persistence beyond the in-memory inference window.
7. Reading notifications from work-profile apps unless the profile explicitly grants listener access.

---

## 4. Functional Requirements

### 4.1 Ingestion & Gating

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-1.1 | The service must register as an `android.service.notification.NotificationListenerService` with `BIND_NOTIFICATION_LISTENER_SERVICE`. | P0 | Listener appears in *Settings → Notification access* with label "WristReply Notification Engine". |
| FR-1.2 | The engine must discard notifications with `FLAG_ONGOING_EVENT` or `FLAG_GROUP_SUMMARY`. | P0 | Media players, downloads and WhatsApp group summaries never produce pills. |
| FR-1.3 | The engine must ignore blank/missing `EXTRA_TEXT`. | P0 | Silent/empty notifications produce no UI, no log noise, no CPU burn. |
| FR-1.4 | The engine must ignore any notification it published itself (loop guard via an `IS_WRIST_REPLY_INJECTED` extra). | P0 | No infinite injection loop; verified with 500-message stress test. |
| FR-1.5 | The engine must not process more than one candidate per notification key at a time (in-flight de-dup). | P1 | Duplicate `onNotificationPosted` callbacks for the same key yield one companion notification. |
| FR-1.6 | Processing must be cancelled if the source notification is removed before inference completes. | P1 | `onNotificationRemoved` before completion leaves no orphan companion notification. |

### 4.2 Dynamic Discovery (No Hardcoded Packages)

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-2.1 | App eligibility must be determined by capability inspection, not by a package allowlist. | P0 | A freshly installed, unknown messenger with quick reply gets pills with zero code change. |
| FR-2.2 | The resolver must accept a notification with `CATEGORY_MESSAGE`, or a `MessagingStyle` bundle, or a non-blank text payload. | P0 | All three heuristics validated by instrumentation tests. |
| FR-2.3 | The resolver must scan standard `notification.actions` first, then `NotificationCompat.WearableExtender` actions. | P0 | Wearable-only reply endpoints (e.g., some OEM clients) resolve correctly. |
| FR-2.4 | A valid target requires a non-null `RemoteInput.resultKey` **and** a non-null `action.actionIntent`. | P0 | Malformed actions are rejected without crash. |
| FR-2.5 | If no reply endpoint exists, the app must not post pills and must not crash. | P0 | Non-reply notifications are silently skipped. |
| FR-2.6 | Users may block individual packages through a whitelist/blacklist UI; default is allowed for discovered messaging apps. | P0 | Toggle state persists across reboot and is read by the native daemon without Dart. |

### 4.3 Inference (ML Kit Smart Reply)

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-3.1 | Inference must use `com.google.mlkit:smart-reply` fully on-device. | P0 | Airplane-mode device generates pills. |
| FR-3.2 | The ML Kit client must be created on demand and `close()`d in a `finally` path. | P0 | No static client retention; heap returns to baseline after every message (LeakCanary clean). |
| FR-3.3 | Inference must run on `Dispatchers.Default` and never on the main thread. | P0 | `StrictMode` shows no main-thread disk/network; UI jank metric = 0 frames dropped. |
| FR-3.4 | Conversation context must include the remote sender id and message timestamp. | P1 | Multi-message sequences produce coherent suggestions. |
| FR-3.5 | If ML Kit returns zero suggestions, fails, or the language is unsupported, the fallback engine must supply pills. | P0 | Bengali/Banglish message still yields 3 pills. |
| FR-3.6 | Inference budget: ≤ 250 ms p90 from `onNotificationPosted` to pills posted. | P1 | Macrobenchmark + on-device trace validated. |

### 4.4 Presentation (Pills)

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-4.1 | Pills must be delivered as `NotificationCompat.Action` entries on a silent channel. | P0 | Actions appear in the shade and mirror to the watch. |
| FR-4.2 | The pill channel must be `IMPORTANCE_LOW` with no sound, vibration, or lights. | P0 | Arriving message produces exactly one chime (from the original app). |
| FR-4.3 | Companion notifications must be grouped under the source notification's group key when present. | P1 | No shade clutter; the pair stacks as one group. |
| FR-4.4 | At most **3** pills per message, ≤ 25 characters each, label truncated with an ellipsis. | P0 | Long suggestions never break the watch layout. |
| FR-4.5 | The engine must keep at most **3** live companion notifications; older ones are evicted LRU. | P1 | Shade never exceeds the per-app notification budget. |
| FR-4.6 | Companion notifications must be cancelled when the source notification is dismissed or replaced. | P0 | Swiping the chat away leaves nothing behind. |
| FR-4.7 | An optional privacy mode must mask message text in the companion notification. | P2 | Text renders as `•••••••` while pills stay readable. |

### 4.5 Dispatch

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-5.1 | Tapping a pill must dispatch the reply without unlocking the device or opening the chat app. | P0 | Verified on a locked, non-secure-lock test device and via ADB. |
| FR-5.2 | Dispatch must build the `RemoteInput` result bundle with the original `resultKey`. | P0 | Message appears in the target app's thread. |
| FR-5.3 | Dispatch must set the results source to `SOURCE_FREE_FORM_INPUT` on API 28+. | P1 | Apps that validate source accept the reply (no "couldn't send" toast). |
| FR-5.4 | Dispatch failures must be surfaced (silent-fail logging + optional local notice) and must never crash the receiver. | P0 | Airplane-mode dispatch failure shows a non-blocking error path. |
| FR-5.5 | On success, the companion notification must be cancelled immediately. | P0 | No stale pill lingers after a successful send. |

### 4.6 Fallback, Persona & Heuristics

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-6.1 | Fallback priority order: user overrides → Banglish/transliteration matcher → script-specific defaults (Bengali Unicode / Latin). | P0 | Each tier independently unit-tested. |
| FR-6.2 | Persona banks (Casual / Professional / Benglish) must be selectable from settings. | P1 | Bank choice changes pill output deterministically. |
| FR-6.3 | Chrono-aware ranking must apply late-night (23:00–06:00) and work-hours (09:00–17:00) biases. | P2 | Clock-stubbed unit tests confirm the ranking flip. |
| FR-6.4 | A "where are you?" / "kothay?" query must offer an optional location-pin pill. | P2 | Pill constructs a `maps.google.com/?q=lat,lng` payload; requires location permission consent. |

### 4.7 Parser & Filter Modules

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-7.1 | LPTE shield must flag abusive tokens using a normalized dictionary + user custom words. | P1 | Flagged messages produce a warning notice and suppress cheerful pills. |
| FR-7.2 | Shield normalization must strip punctuation and handle Bengali Unicode ranges. | P1 | Zero false negatives on the curated regression corpus. |
| FR-7.3 | Transaction-ID / OTP extraction must auto-copy the token to the clipboard when enabled. | P1 | `TrxID: ABC123XYZ` copies `ABC123XYZ` and posts a "Copied!" confirmation pill. |
| FR-7.4 | Clipboard automation must be individually togglable for OTP and for financial tokens. | P1 | Both switches persist and are honoured by the native path. |
| FR-7.5 | Coverage must include the documented payment ecosystems (bKash, Nagad, Rocket, bank SMS, PayPal, Stripe, UPI/PhonePe/Paytm, Apple/Google Pay, GrabPay, iDEAL, SberPay, OPay/PalmPay, Binance and similar). | P2 | Regex corpus test suite passes for each listed provider pattern. |

### 4.8 Settings & Console (Flutter)

| ID | Requirement | Priority | Acceptance Criteria |
| :--- | :--- | :--- | :--- |
| FR-8.1 | Every engine behaviour must be configurable from the settings UI (no hidden flags). | P0 | Config matrix below is fully reachable in ≤3 taps from home. |
| FR-8.2 | Settings must be written directly to `SharedPreferences` consumed by the daemon (no Dart VM in background). | P0 | Killing the app UI leaves the engine fully functional. |
| FR-8.3 | Dashboard must show engine state, permission state, reply counter and average latency. | P1 | Values refresh on resume; no polling while paused. |
| FR-8.4 | A live sandbox must let the user type a test message and preview pills. | P1 | Sandbox never dispatches to a real app. |
| FR-8.5 | The onboarding must present a prominent disclosure before opening system notification-access settings. | P0 | Google Play prominent-disclosure requirement satisfied. |

**Settings surface (must exist exactly as configured, all persisted natively):**

| Group | Control | Type | Default |
| :--- | :--- | :--- | :--- |
| Engine | Master switch | Switch | On |
| Engine | Pills per message | Stepper 1–3 | 3 |
| Engine | Replace original notification mode | Switch | Off (Companion mode) |
| Engine | Privacy mode (mask text) | Switch | Off |
| Apps | Discovered apps list | Toggles | All on |
| Apps | Add app manually (package picker) | Action | — |
| Replies | Conversation tone | Segmented (Casual/Professional/Benglish) | Casual |
| Replies | Custom fallback pills | Editable list | 3 seeded |
| Replies | Late-night / work-hours bias | Switch | On |
| Replies | Location pin pill | Switch | Off |
| Filters | Inappropriate Language Shield | Switch | On |
| Filters | Custom blocked words | Editable list | empty |
| Clipboard | Auto-copy OTP | Switch | Off |
| Clipboard | Auto-copy transaction IDs | Switch | Off |
| System | Battery optimization exemption | Action | — |
| System | OEM autostart helper | Action | — |
| System | Diagnostics (local only) | Switch | On |

---

## 5. Non-Functional Requirements

| ID | Requirement | Target | Verification |
| :--- | :--- | :--- | :--- |
| NFR-1.1 | Steady-state resident memory of the native daemon | 15–25 MB | `dumpsys meminfo` after 30 min idle |
| NFR-1.2 | Idle CPU usage | 0% (0 wakeups/min) | Battery Historian, 8 h idle trace |
| NFR-1.3 | End-to-end latency (notification → pills) | p50 ≤ 120 ms, p90 ≤ 250 ms | On-device trace instrumentation |
| NFR-1.4 | Cold-start of settings UI | ≤ 900 ms to first frame | Flutter DevTools timeline |
| NFR-1.5 | Battery impact | ≤ 1% per 24 h for 100 messages/day | Battery Historian comparison |
| NFR-1.6 | APK size (universal, release) | ≤ 12 MB (ML Kit adds ~1.5 MB) | Gradle `analyze` report |
| NFR-2.1 | Minimum SDK | API 26 (Android 8.0) | `build.gradle` |
| NFR-2.2 | Target/compile SDK | Latest Play-mandated level (API 35+, verify current requirement before each release) | `build.gradle` |
| NFR-2.3 | Supported ABIs | `armeabi-v7a`, `arm64-v8a`, `x86_64` | `abiFilters` |
| NFR-2.4 | Flutter engine must never be instantiated in a background/headless service | Enforced by code review + lint rule | grep audit in CI |
| NFR-3.1 | Every source file ≤ 150 lines | 100% of files | CI line-count check |
| NFR-3.2 | No hardcoded package names in engine logic | 0 occurrences outside test fixtures | CI grep gate |
| NFR-3.3 | No message content in logs, analytics, or crash reports | 0 leaks | Log-scrubbing unit test + review |
| NFR-4.1 | Touch targets: mobile ≥ 48dp, wearable ≥ 44dp | 100% of interactive elements | Accessibility scanner |
| NFR-4.2 | Text contrast | ≥ 4.5:1 body, ≥ 7:1 for the primary token pair (16.2:1 measured) | WCAG AA/AAA audit |
| NFR-4.3 | Screen-reader labels on every pill | 100% | TalkBack pass |
| NFR-5.1 | No ANRs, no crashes in the listener path | Crash-free sessions ≥ 99.5% | Play vitals / Crashlytics (if enabled) |
| NFR-5.2 | Robust against OEM process kills | Listener rebinds automatically; result within 5 s of killed state | `onListenerDisconnected` + `requestRebind()` test |
| NFR-6.1 | Offline capability | 100% of core features work in airplane mode | Manual test matrix |
| NFR-6.2 | Localization-ready strings | 100% externalized; Bengali shipped as second locale in Phase 2 | ARB audit |

---

## 6. Ecosystem & Platform Capability Matrix

| Ecosystem | Device examples | Integration method | Real-world behaviour | Phase |
| :--- | :--- | :--- | :--- | :--- |
| **Wear OS** | Galaxy Watch 4+, Pixel Watch, Xiaomi Watch 2 | Jetpack/Wear Compose app + `Wearable.MessageClient` (`/smart_replies`) | Full standalone UI, custom pill stack, bidirectional BLE | 2 |
| **Zepp OS** | Amazfit Balance, Cheetah, GTR/GTS 4 | Zepp OS JS micro-app + Zepp Mobile Bridge (loopback service on the phone) | Custom pill screen; response token relayed back to phone daemon | 2 (optional) |
| **Budget RTOS** | boAt, Noise, Fire-Boltt, Mi Band | **Native notification action mirroring only** | Watch mirrors our silent companion notification's action buttons; tap fires the phone `PendingIntent` | 1 (primary) |
| **Phone only (no watch)** | Any Android 8+ | Notification-shade pills (+ optional floating assistive bubble) | Suggestions usable directly in the tray; reply without opening the chat app | 1 |

**Why the RTOS path works:** cheap watches receive plain mirrored notifications and render `NotificationCompat.Action` labels as stock "Quick Reply" buttons. Because our companion notification carries the actions, no vendor SDK, pairing API, or reverse engineering is required — the OS does the mirroring.

**Critical constraint (documented honestly):** a `NotificationListenerService` **cannot mutate another app's notification**. There is no supported API to inject actions into someone else's posted notification. The compliant implementation therefore publishes a *companion* notification that carries the pills, typically grouped with the original. "Replace mode" (cancel the original via `cancelNotification(key)` and repost a clone with merged actions) is offered as an opt-in user setting because it can break app behaviour and some OEM guards.

---

## 7. Architecture

### 7.1 Layered Topology

```text
┌─────────────────────────────────────────────────────────────────────┐
│                       Android System Notification Stream             │
└───────────────────────────────┬─────────────────────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│            HEADLESS NATIVE DAEMON (Kotlin, no Flutter, no Dart)      │
│                                                                     │
│  NotificationGate ──► DynamicTargetResolver ──► EphemeralMLKitEngine │
│        │                       │                        │           │
│        │                       │                        ▼           │
│        │                       │              FallbackReplyEngine    │
│        │                       │                        │           │
│        ▼                       ▼                        ▼           │
│  ProfanityGuard /      NotificationPublisher ──► MetricsLedger       │
│  SmartTokenExtractor          │                                     │
│                               ▼                                     │
│                     ActionBroadcastReceiver  (RemoteInput dispatch)  │
│                               │                                     │
│                     WearSyncService (Wear OS / Zepp / RTOS bridge)   │
└───────────────────────────────┬─────────────────────────────────────┘
                                │ reads/writes directly
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SharedPreferences (single config truth)          │
│        wrist_reply_prefs · wrist_reply_filters · whitelist keys     │
└───────────────────────────────┬─────────────────────────────────────┘
                                ▲ writes on user action only
┌─────────────────────────────────────────────────────────────────────┐
│         PRESENTATION CLIENT (Flutter — booted ONLY on app open)      │
│  Onboarding · Console Dashboard · App Whitelist · Persona · Filters │
│  MethodChannel: com.wristreply.app/engine   EventChannel: …/events  │
└─────────────────────────────────────────────────────────────────────┘
```

### 7.2 The Three Non-Negotiable Architecture Rules

1. **Never boot Flutter in the background.** A background `FlutterEngine` costs 50–80 MB RSS. Configuration crosses the boundary as plain data in `SharedPreferences`; the daemon reads the XML directly.
2. **Never hardcode app identities.** Eligibility is decided by inspecting the notification's capability contract (`CATEGORY_MESSAGE` / `MessagingStyle` / actions with `RemoteInput`).
3. **Never leak content.** No message text into logs, analytics params, crash breadcrumbs, or network calls. The release manifest omits `INTERNET`.

### 7.3 Runtime Data Flow (sequence)

```text
1. Messaging app posts notification
2. System → NotificationProcessorService.onNotificationPosted(sbn)
3. Gate: summary? ongoing? blank? self-injected? → reject, done
4. Whitelist check (package-level, from SharedPreferences) → reject if disabled
5. ProfanityGuard: abusive? → post warning, stop (no cheerful pills)
6. SmartTokenExtractor: OTP/TrxID and auto-copy on? → clipboard + "Copied!" pill
7. DynamicTargetResolver: find RemoteInput + PendingIntent → reject if absent
8. EphemeralMLKitEngine.suggestReplies(context)  [Dispatchers.Default]
9. Empty/failed? → FallbackReplyEngine (user → Banglish → script defaults)
10. NotificationPublisher: silent companion notification with ≤3 actions
11. WearSyncService (Phase 2): payload to /smart_replies for Wear OS companions
12. User taps pill (phone or watch) → ActionBroadcastReceiver
13. Receiver builds RemoteInput results bundle → original PendingIntent.send()
14. Cancel companion notification · increment local metrics (no PII)
```

### 7.4 Threading & Memory Model

| Concern | Decision |
| :--- | :--- |
| Threading | One `CoroutineScope(SupervisorJob() + Dispatchers.Default)` per service instance |
| ML client | Created per call, closed in `finally`; never a long-lived field |
| Cancellation | Job keyed by `sbn.key`; cancelled in `onNotificationRemoved` |
| Back-pressure | In-flight map bounded (max 5 concurrent); oldest job cancelled on overflow |
| Config reads | `SharedPreferences` read on demand (cached in a `StateFlow` invalidated by `OnSharedPreferenceChangeListener`) |
| Flutter | Instantiated only by `MainActivity`; destroyed with the Activity |

### 7.5 Notification Strategy (Companion vs Replace)

| Mode | Mechanism | Pros | Cons | Default |
| :--- | :--- | :--- | :--- | :--- |
| **Companion** | Post a second, silent, `IMPORTANCE_LOW` notification grouped with the original (`setGroup(originalGroupKey)` + `setGroupAlertBehavior(GROUP_ALERT_CHILDREN)`) | Safe, no app breakage, guaranteed silent, watch mirrors it | Two entries in the shade (grouped) | ✔ On |
| **Replace** | `cancelNotification(key)` then repost a clone built from the original's extras + our actions | Clean single entry | Can break apps with custom logic; original `deleteIntent`/tag semantics lost; some OEMs re-post | Off (opt-in) |

**Rules that apply to both modes**

* Use a dedicated channel `smart_reply_channel` created with `IMPORTANCE_LOW`, `setSound(null, null)`, `enableVibration(false)`, `setShowBadge(false)`.
* Mark every self-published notification with `IS_WRIST_REPLY_INJECTED = true`.
* Never set `PRIORITY_HIGH` for the companion (that is what causes the double-chime bug); use `PRIORITY_LOW`/`MIN`.
* Cancel companions when the source is dismissed (`onNotificationRemoved`), when the source is replaced (`onNotificationPosted` with `FLAG_ONLY_ALERT_ONCE`/same key and no reply endpoint), or when the LRU budget overflows.
* On Android 13+ the app must hold `POST_NOTIFICATIONS` to publish the companion at all — request it in onboarding, and degrade gracefully (engine still computes; nothing is posted) if denied.

### 7.6 Target Repository Layout

```text
wrist_reply/
├── android/
│   └── app/
│       ├── build.gradle
│       ├── proguard-rules.pro
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/com/wristreply/app/
│               ├── MainActivity.kt                     (<150 lines)
│               ├── bridge/
│               │   ├── NativeBridgeHandler.kt          (MethodChannel methods)
│               │   └── PreferenceRepository.kt         (SharedPreferences writer)
│               ├── engine/
│               │   ├── NotificationGate.kt
│               │   ├── DynamicTargetResolver.kt
│               │   ├── EphemeralMLKitEngine.kt
│               │   ├── FallbackReplyEngine.kt
│               │   ├── ReplyTarget.kt                  (immutable data class)
│               │   ├── ReplyBudget.kt                  (LRU / in-flight map)
│               │   ├── MetricsLedger.kt                (local, no PII)
│               │   └── oem/OemKeepAliveManager.kt
│               ├── filters/
│               │   ├── ProfanityGuardEngine.kt
│               │   └── SmartTokenExtractor.kt
│               ├── services/
│               │   ├── NotificationProcessorService.kt (thin orchestrator)
│               │   ├── NotificationPublisher.kt
│               │   ├── NotificationWarnings.kt         (abuse + clipboard notices only)
│               │   └── WearSyncService.kt
│               └── receivers/
│                   └── ActionBroadcastReceiver.kt
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/{app_colors.dart, app_strings.dart, app_keys.dart}
│   │   ├── platform/native_channel.dart
│   │   ├── theme/app_theme.dart
│   │   └── routing/app_router.dart
│   ├── features/
│   │   ├── onboarding/screens/{disclosure_screen.dart, permission_screen.dart}
│   │   ├── dashboard/{models/, providers/, screens/dashboard_screen.dart, widgets/}
│   │   ├── apps/{providers/app_whitelist_provider.dart, screens/app_list_screen.dart}
│   │   ├── persona/{screens/persona_screen.dart, widgets/tone_selector.dart}
│   │   └── filters/{screens/filters_screen.dart, widgets/custom_word_editor.dart}
│   └── shared/widgets/{state_badge.dart, reply_pill_preview.dart, metrics_card.dart,
│                       permission_banner.dart, toggle_switch_tile.dart, section_header.dart}
├── test/            (Dart unit + widget tests)
├── android/app/src/test/       (Kotlin unit tests)
├── android/app/src/androidTest/ (instrumentation tests)
└── pubspec.yaml
```

### 7.7 Naming & Code Conventions

| Concern | Convention |
| :--- | :--- |
| Kotlin packages | `com.wristreply.app.<layer>` — `engine`, `services`, `receivers`, `filters`, `bridge` |
| Kotlin classes | `PascalCase`; engine units are stateless `object`s or single-responsibility classes |
| File size | **Hard limit 150 lines** (CI-enforced); 60–120 lines is the target |
| Flutter widgets | Atomic naming: `StateBadge`, `MetricsCard`, `ReplyPillPreview`, `ToggleSwitchTile`, `PermissionBanner`, `SectionHeader` |
| Dart providers | `<Feature>Provider` in `providers/`; one provider per file |
| SharedPreferences keys | `wr_` prefix, snake_case, declared once in `app_keys.dart` **and** mirrored in a Kotlin `PrefKeys.kt` constant object |
| Intent extras | `KEY_` prefix, declared as `const val` (never raw string literals in two places) |
| Channel names | `com.wristreply.app/engine` (methods), `com.wristreply.app/events` (events) |
| Channel ids | `smart_reply_channel`, `wrist_reply_alerts` |
| Commits | `feat(engine):`, `fix(dispatch):`, `docs:`, `chore(build):` |

---

## 8. Build Environment & Process (Step-By-Step)

### 8.1 Toolchain Versions

| Tool | Version | Notes |
| :--- | :--- | :--- |
| Android Studio | Hedgehog (2023.1) or newer, Iguana recommended | Wear OS emulator support |
| JDK | 17 | `sourceCompatibility`/`jvmTarget` = 17 |
| Android Gradle Plugin | 8.3.2+ | `gradle.md` baseline |
| Gradle wrapper | 8.4+ | Match AGP compatibility matrix |
| Kotlin | 1.9.23+ (or 2.0.x with AGP 8.5+) | Keep AGP/Kotlin compatibility table in mind |
| Flutter | 3.19+ (stable) | `withValues(alpha:)` API is used in widgets, requires ≥3.27; otherwise use `withOpacity` |
| Compose (Wear module) | Compose BOM 2024.05+ | Phase 2 only |
| Android SDK platform | API 34/35 installed | Latest Play-mandated target |

### 8.2 Build Configuration

**`android/settings.gradle`** — plugin management and Flutter loader:

```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null : "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories { google(); mavenCentral(); gradlePluginPortal() }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.3.2" apply false
    id "org.jetbrains.kotlin.android" version "1.9.23" apply false
}

include ":app"
```

**`android/app/build.gradle`** — module configuration:

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.wristreply.app"
    compileSdk 37
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    defaultConfig {
        applicationId "com.wristreply.app"
        minSdk 26          // NotificationChannel + modern RemoteInput rebinding
        targetSdk 37       // bump to the latest Play requirement each release
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        ndk { abiFilters "armeabi-v7a", "arm64-v8a", "x86_64" }
    }

    buildFeatures { buildConfig true }

    flavorDimensions "privacy"
    productFlavors {
        vanilla { dimension "privacy" }   // zero INTERNET permission — Play build
        full    { dimension "privacy" }   // crash reporting enabled
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
        debug { applicationIdSuffix ".debug" }
    }
}

flutter { source "../.." }

dependencies {
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.8.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.8.0"
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
    implementation "com.google.mlkit:smart-reply:17.0.4"   // 100% on-device model
}
```

**`android/app/proguard-rules.pro`** — protect reflective ML Kit + notification APIs:

```proguard
-keep class com.google.mlkit.nl.smartreply.** { *; }
-keep interface com.google.mlkit.nl.smartreply.** { *; }

-keepclassmembers class * extends android.service.notification.NotificationListenerService { <methods>; }

-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.RemoteInput** { *; }
```

### 8.3 Manifest Contract

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Core capability: notification interception (policy-restricted, see §15) -->
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
        tools:ignore="ProtectedPermissions" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />   <!-- API 33+ -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />   <!-- API 31+, Wear only -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" /> <!-- floating bubble, optional -->
    <!-- INTERNET is intentionally ABSENT in the `vanilla` flavour -->
    <!-- QUERY_ALL_PACKAGES is intentionally ABSENT — use the <queries> block below -->

    <queries>
        <intent>
            <action android:name="android.intent.action.SENDTO" />
            <data android:scheme="smsto" />
        </intent>
        <intent><action android:name="android.intent.action.MAIN" />
            <category android:name="android.intent.category.LAUNCHER" /></intent>
    </queries>

    <application android:label="WristReply" android:icon="@mipmap/ic_launcher"
                 android:allowBackup="false" android:dataExtractionRules="@xml/data_extraction_rules">

        <activity android:name=".MainActivity" android:exported="true"
                  android:launchMode="singleTop" android:theme="@style/LaunchTheme"
                  android:windowSoftInputMode="adjustResize" />

        <service android:name=".services.NotificationProcessorService"
                 android:label="WristReply Notification Engine"
                 android:exported="true"
                 android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>

        <receiver android:name=".receivers.ActionBroadcastReceiver" android:exported="false" />

        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```

> `POST_NOTIFICATIONS`, the `<queries>` block, and `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` are **mandatory additions** to the baseline docs — without them the companion notification cannot be posted on Android 13+, `queryIntentActivities` returns nothing on Android 11+, and the Doze-exemption flow silently fails.

### 8.4 Environment Bootstrap Commands

```bash
# 1. Verify toolchain
flutter --version && java -version && sdkmanager --list_installed

# 2. Resolve dependencies
flutter pub get
cd android && ./gradlew --refresh-dependencies tasks && cd ..

# 3. Static analysis gates (must be clean before commit)
flutter analyze
cd android && ./gradlew :app:lintVanillaRelease && ./gradlew :app:testDebugUnitTest && cd ..

# 4. Debug run on a paired phone emulator
flutter run --flavor vanilla --dart-define=FLAVOR=vanilla

# 5. Release build of the zero-internet flavour
flutter build appbundle --flavor vanilla --release \
  --dart-define=FLAVOR=vanilla --obfuscate --split-debug-info=build/symbols
```

### 8.5 Emulator & Device Setup

1. **SDK Manager** → install Android 14/15 platform, Build-Tools, Platform-Tools, Google Play services.
2. **Wear emulator:** Device Manager → Create Virtual Device → Wear OS Small/Large Round → Wear OS 4/5 image **with Play Store**.
3. **Phone emulator:** Pixel 7, API 34 with Play Store.
4. **Pair:** Device Manager → watch ⋮ → *Pair Wearable* → follow prompts (required for the Phase-2 data layer).
5. **Notification access:** `adb shell cmd notification allow_listener com.wristreply.app/com.wristreply.app.services.NotificationProcessorService` (fast path) — the manual settings path is in `HUMAN_TASKS.md`.
6. **Battery exemption:** `adb shell dumpsys deviceidle whitelist +com.wristreply.app`.

### 8.6 Hardware-Free Simulation (ADB)

```bash
# Post a realistic messaging notification (messaging style so RemoteInput is attached)
adb shell cmd notification post -S messaging --conversation "Tester" \
  -t "Farhan" "Hey, are you free for a quick call right now?"

# Inspect what the listener is receiving
adb logcat -s WristReply:V NotificationService:V

# Verify the companion notification and its actions
adb shell dumpsys notification --noredact | grep -A 40 wristreply

# Pull the rendered shade screenshot for review
adb exec-out screencap -p > shade.png
```

**Expected result:** exactly one extra silent notification appears, showing up to three pill actions; tapping a pill logs a successful `PendingIntent.send()` and cancels the companion.

---

## 9. Native Engine Implementation Guide (Kotlin)

Every block below is a **component contract**. Production code must keep each file under 150 lines; split by responsibility when a component grows.

### 9.1 Immutable Data Contracts

```kotlin
package com.wristreply.app.engine

import android.app.PendingIntent
import android.app.RemoteInput

/** Everything required to answer one conversation, captured immutably. */
data class ReplyTarget(
    val notificationKey: String,
    val notificationId: Int,
    val groupKey: String?,
    val packageName: String,
    val appLabel: String,
    val senderName: String,
    val messageText: String,
    val timestampMs: Long,
    val resultKey: String,
    val remoteInput: RemoteInput,
    val replyPendingIntent: PendingIntent
)

/** A single suggestion rendered as a pill and dispatched on tap. */
data class ReplySuggestion(
    val text: String,
    val source: Source
) {
    enum class Source { ML_KIT, USER_OVERRIDE, BENGLISH, SCRIPT_DEFAULT, CHRONO, ACTION }
}
```

### 9.2 NotificationGate — zero-CPU idle filter

```kotlin
package com.wristreply.app.engine

import android.app.Notification
import android.service.notification.StatusBarNotification

object NotificationGate {
    const val EXTRA_SELF_INJECTED = "IS_WRIST_REPLY_INJECTED"

    fun shouldInspect(sbn: StatusBarNotification): Boolean {
        val n = sbn.notification ?: return false
        if (n.extras.getBoolean(EXTRA_SELF_INJECTED, false)) return false            // loop guard
        if (n.flags and Notification.FLAG_ONGOING_EVENT != 0) return false            // media / progress
        if (n.flags and Notification.FLAG_GROUP_SUMMARY != 0) return false            // group parent
        val text = n.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        return !text.isNullOrBlank()
    }
}
```

### 9.3 DynamicTargetResolver — capability inspection, never a package list

```kotlin
package com.wristreply.app.engine

import android.app.Notification
import android.app.PendingIntent
import android.app.RemoteInput
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat

object DynamicTargetResolver {

    fun resolve(sbn: StatusBarNotification): ReplyTarget? {
        val n = sbn.notification ?: return null
        val extras = n.extras
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim().orEmpty()
        if (text.isEmpty()) return null

        // A live reply endpoint + non-blank text is the strongest possible signal. The
        // conversational heuristics are recorded for ranking/telemetry but are NOT a hard
        // requirement: several clients omit CATEGORY_MESSAGE yet fully support inline reply.
        val endpoint = findEndpoint(n.actions.orEmpty())
            ?: findEndpoint(NotificationCompat.WearableExtender(n).actions)
            ?: return null

        val conversational =
            n.category == Notification.CATEGORY_MESSAGE ||
            extras.containsKey(Notification.EXTRA_MESSAGING_STYLE_USER) ||
            extras.containsKey(Notification.EXTRA_CONVERSATION_TITLE) ||
            extras.containsKey(Notification.EXTRA_MESSAGES)

        val sender = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
            ?: extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString()
            ?: "Unknown"

        return ReplyTarget(
            notificationKey = sbn.key,
            notificationId = sbn.id,
            groupKey = n.group,
            packageName = sbn.packageName,
            appLabel = AppLabelCache.labelFor(sbn.packageName),   // cached; no PackageManager hit per event
            senderName = sender,
            messageText = text.take(400),                          // bound the payload; bundles are size-limited
            timestampMs = sbn.postTime.takeIf { it > 0 } ?: System.currentTimeMillis(),
            conversational = conversational,
            resultKey = endpoint.first,
            remoteInput = endpoint.second,
            replyPendingIntent = endpoint.third
        )
    }

    /** Returns (resultKey, RemoteInput, PendingIntent) for the first usable reply endpoint. */
    private fun findEndpoint(actions: List<Notification.Action>): Triple<String, RemoteInput, PendingIntent>? {
        for (action in actions) {
            val intent = action.actionIntent ?: continue
            for (input in action.remoteInputs.orEmpty()) {
                val key = input.resultKey ?: continue
                if (key.isNotBlank()) return Triple(key, input, intent)   // free-form OR canned choices
            }
        }
        return null
    }
}
```

> `EXTRA_MESSAGING_STYLE_USER` / `EXTRA_MESSAGES` are cheap presence checks for a `MessagingStyle` payload. The canonical alternative is `NotificationCompat.MessagingStyle.extractMessagingStyleFromNotification(n)`; choose one approach and unit-test it against fixtures from at least three different messengers.

### 9.4 EphemeralMLKitEngine — infer, then release immediately

```kotlin
package com.wristreply.app.engine

import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.TextMessage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume

class EphemeralMLKitEngine {

    private val history = ArrayDeque<TextMessage>()   // in-memory only, capped

    suspend fun suggest(target: ReplyTarget): List<String> = withContext(Dispatchers.Default) {
        history.addLast(
            TextMessage.createForRemoteUser(target.messageText, target.timestampMs, target.senderName)
        )
        while (history.size > MAX_CONTEXT) history.removeFirst()

        val client = SmartReply.getClient()
        try {
            suspendCancellableCoroutine { cont ->
                client.suggestReplies(history.toList())
                    .addOnSuccessListener { result ->
                        if (cont.isActive) cont.resume(result.suggestions.map { it.text }.distinct().take(3))
                    }
                    .addOnFailureListener { if (cont.isActive) cont.resume(emptyList()) }
            }
        } finally {
            client.close()          // always release the native model handles, even on failure/cancel
        }
    }

    fun reset() = history.clear()

    private companion object { const val MAX_CONTEXT = 10 }   // ML Kit's documented ceiling
}
```

**Rules:** never store the client in a field; clear `history` when the conversation key changes or the service is destroyed; treat an empty result as a signal to run the fallback engine, not as an error.

### 9.5 FallbackReplyEngine — region-aware deterministic pills

```kotlin
package com.wristreply.app.engine

object FallbackReplyEngine {

    private val BENGLISH = mapOf(
        "kemon acho" to listOf("Bhalo achi!", "Bhalo, tumi kemon?"),
        "kothay"     to listOf("Astechi 5 min e", "Ekhon ektu busy achi"),
        "hobe"       to listOf("Hobe, cholbe!", "Hmm, ektu pore bolo")
    )
    private val LATIN = listOf("Okay!", "On my way.", "Can we talk later?")
    private val BENGALI = listOf("ঠিক আছে!", "একটু পরে বলি", "এখন ব্যস্ত আছি")

    fun reply(target: ReplyTarget, userOverrides: List<String>, persona: UserPersona): List<ReplySuggestion> {
        if (userOverrides.isNotEmpty()) return userOverrides.take(3).map { ReplySuggestion(it, ReplySuggestion.Source.USER_OVERRIDE) }
        val lower = target.messageText.lowercase()
        BENGLISH.entries.firstOrNull { lower.contains(it.key) }?.let {
            return it.value.take(3).map { t -> ReplySuggestion(t, ReplySuggestion.Source.BENGLISH) }
        }
        val bank = if (lower.any { it.code in 0x0980..0x09FF }) BENGALI else persona.bank(LATIN)
        return bank.take(3).map { ReplySuggestion(it, ReplySuggestion.Source.SCRIPT_DEFAULT) }
    }
}

enum class UserPersona { CASUAL, PROFESSIONAL, BENGLISH;
    fun bank(fallback: List<String>) = when (this) {
        CASUAL -> fallback
        PROFESSIONAL -> listOf("Understood, will revert shortly.", "In a meeting, will check soon.")
        BENGLISH -> listOf("Astechi 5 min e", "Ekhon busy achi, pore bolbo")
    }
}
```

**Fallback priority (must be tested in this order):** user overrides → Banglish/transliteration matcher → script-specific defaults (Bengali Unicode range `U+0980–U+09FF` → Bengali bank; otherwise Latin/persona bank).

### 9.6 Chrono & Context Heuristics

```kotlin
package com.wristreply.app.engine

import java.util.Calendar

object ChronoHeuristics {
    fun bias(hour: Int): List<String> = when (hour) {
        23, in 0..5 -> listOf("Asleep — talk tomorrow?", "Can it wait till morning?")
        in 9..17 -> listOf("In office, text only", "Will check in a bit")
        else -> emptyList()
    }

    fun wantsLocation(text: String): Boolean {
        val t = text.lowercase()
        return t.contains("where are you") || t.contains("kothay") || t.contains("location")
    }

    fun currentHour(): Int = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
}
```

### 9.7 NotificationPublisher — silent pills, LRU budget, grouping

```kotlin
package com.wristreply.app.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.wristreply.app.engine.NotificationGate
import com.wristreply.app.engine.ReplySuggestion
import com.wristreply.app.engine.ReplyTarget
import com.wristreply.app.receivers.ActionBroadcastReceiver

class NotificationPublisher(private val context: Context) {

    /** LRU ledger: notification key → posted id, so cancel(key) always matches publish(key). */
    private val ledger = object : LinkedHashMap<String, Int>(MAX_LIVE, 0.75f, true) {}
    private var nextId = 1000

    @Synchronized
    private fun idFor(key: String): Int {
        ledger[key]?.let { return it }
        if (ledger.size >= MAX_LIVE) {
            ledger.keys.firstOrNull()?.let { oldest -> NotificationManagerCompat.from(context).cancel(ledger.remove(oldest)!!) }
        }
        return (nextId++).also { ledger[key] = it }
    }

    fun cancel(key: String) {
        val id = synchronized(ledger) { ledger.remove(key) } ?: return
        NotificationManagerCompat.from(context).cancel(id)
    }

    fun ensureChannel() {
        val channel = NotificationChannel(CHANNEL_ID, "Smart reply pills", NotificationManager.IMPORTANCE_LOW).apply {
            description = "Silent quick-reply suggestions attached to incoming messages"
            setSound(null, null)
            enableVibration(false)
            enableLights(false)
            setShowBadge(false)
        }
        NotificationManagerCompat.from(context).createNotificationChannel(channel)
    }

    fun publish(target: ReplyTarget, suggestions: List<ReplySuggestion>, privacyMode: Boolean) {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setContentTitle(target.senderName)
            .setContentText(if (privacyMode) "•••••••" else target.messageText)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setAutoCancel(true)
            .setTimeoutAfter(TIMEOUT_MS)
            .addExtras(Bundle().apply { putBoolean(NotificationGate.EXTRA_SELF_INJECTED, true) })

        target.groupKey?.let { builder.setGroup(it).setGroupAlertBehavior(NotificationCompat.GROUP_ALERT_CHILDREN) }

        suggestions.take(3).forEachIndexed { index, suggestion ->
            builder.addAction(
                NotificationCompat.Action.Builder(0, suggestion.text.take(25), pillIntent(target, suggestion.text, index)).build()
            )
        }
        NotificationManagerCompat.from(context).notify(idFor(target.notificationKey), builder.build())
    }

    private fun pillIntent(target: ReplyTarget, text: String, index: Int): PendingIntent {
        val intent = Intent(context, ActionBroadcastReceiver::class.java).apply {
            putExtra(KEY_REPLY_TEXT, text)
            putExtra(KEY_RESULT_KEY, target.resultKey)
            putExtra(KEY_ORIGINAL_INTENT, target.replyPendingIntent)
            putExtra(KEY_NOTIFICATION_KEY, target.notificationKey)
        }
        return PendingIntent.getBroadcast(
            context, (target.notificationKey.hashCode() * 31) + index, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE   // MUTABLE is required for RemoteInput results
        )
    }

    private companion object {
        const val CHANNEL_ID = "smart_reply_channel"
        const val MAX_LIVE = 3                       // never exceed the shade budget
        const val TIMEOUT_MS = 10 * 60 * 1000L
        const val KEY_REPLY_TEXT = "KEY_REPLY_TEXT"
        const val KEY_RESULT_KEY = "KEY_RESULT_KEY"
        const val KEY_ORIGINAL_INTENT = "KEY_ORIGINAL_INTENT"
        const val KEY_NOTIFICATION_KEY = "KEY_NOTIFICATION_KEY"
    }
}
```

**Publisher rules:** `PRIORITY_LOW` + `setSilent(true)` prevents the double-chime; `FLAG_MUTABLE` is mandatory on API 31+ for `RemoteInput` fill-in; `setTimeoutAfter` prevents stale pills from accumulating on a forgotten phone; the ≤3 live-companion budget is enforced by the LRU ledger above and by `ReplyBudget` below.

#### 9.7.1 ReplyBudget — bounded concurrency + in-flight ledger

```kotlin
package com.wristreply.app.engine

/** Bounded in-flight tracker: at most [maxConcurrent] notifications are inferred at once. */
class ReplyBudget(private val maxConcurrent: Int = 5) {
    private val active = LinkedHashSet<String>()

    @Synchronized fun offer(key: String): Boolean {
        if (key in active) return false
        if (active.size >= maxConcurrent) active.firstOrNull()?.let(active::remove)
        return active.add(key)
    }

    @Synchronized fun release(key: String) { active.remove(key) }

    @Synchronized fun isBusy(key: String) = key in active
}
```

#### 9.7.2 NotificationWarnings — shield alerts and clipboard confirmations

Two channels only, and both are created lazily on first use:

```kotlin
package com.wristreply.app.services

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.wristreply.app.filters.SmartTokenExtractor

object NotificationWarnings {
    private const val CH_ALERTS = "wrist_reply_alerts"      // IMPORTANCE_DEFAULT — user safety only
    private const val CH_CONFIRM = "smart_reply_channel"     // IMPORTANCE_LOW  — silent confirmations

    fun postAbuse(context: Context, sender: String) {
        ensure(context, CH_ALERTS, "Safety alerts", NotificationManager.IMPORTANCE_DEFAULT)
        notify(context, CH_ALERTS, ID_ABUSE,
            "Possible abusive message",
            "$sender sent language that was flagged. Reply suggestions were suppressed.")
    }

    fun postCopied(context: Context, token: SmartTokenExtractor.Token) {
        ensure(context, CH_CONFIRM, "Smart reply pills", NotificationManager.IMPORTANCE_LOW)
        notify(context, CH_CONFIRM, ID_COPIED,
            "Copied ${if (token.type.name == "OTP") "verification code" else "reference"}",
            "The value is on your clipboard. It stays on this device.")
    }

    private const val ID_ABUSE = 9001
    private const val ID_COPIED = 9002

    private fun ensure(context: Context, id: String, name: String, importance: Int) {
        val channel = NotificationChannel(id, name, importance).apply {
            enableVibration(importance >= NotificationManager.IMPORTANCE_DEFAULT)
            setShowBadge(false)
        }
        NotificationManagerCompat.from(context).createNotificationChannel(channel)
    }

    private fun notify(context: Context, channel: String, id: Int, title: String, body: String) {
        val n = NotificationCompat.Builder(context, channel)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setContentTitle(title).setContentText(body)
            .setAutoCancel(true).setSilent(channel == CH_CONFIRM)
            .build()
        runCatching { NotificationManagerCompat.from(context).notify(id, n) }   // fails soft without POST_NOTIFICATIONS
    }
}
```

> These are the **only** notifications the app creates on its own initiative, and both are strictly user-facing (a safety alert and a clipboard confirmation). Neither ever contains message bodies or third-party content beyond the flagged sender name.

#### 9.7.3 MetricsLedger — local-only counters (no PII)

```kotlin
package com.wristreply.app.engine

import android.content.Context

/** Aggregate counters only. Never stores message text, sender names, or per-contact data. */
object MetricsLedger {
    private const val PREFS = "wrist_reply_metrics"

    fun record(context: Context, source: String, latencyMs: Long) {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val count = p.getInt("count", 0) + 1
        val avg = ((p.getInt("avg_latency", 0) * (count - 1)) + latencyMs) / count
        p.edit()
            .putInt("count", count)
            .putInt("avg_latency", avg.toInt())
            .putLong("last_$source", System.currentTimeMillis())
            .apply()
    }

    fun recordDispatch(context: Context, source: String) {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        p.edit()
            .putInt("dispatched", p.getInt("dispatched", 0) + 1)
            .putLong("last_$source", System.currentTimeMillis())
            .apply()
    }

    fun snapshot(context: Context): Map<String, Any> {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return mapOf(
            "generated" to p.getInt("count", 0),
            "dispatched" to p.getInt("dispatched", 0),
            "avgLatencyMs" to p.getInt("avg_latency", 0)
        )
    }

    fun clear(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().clear().apply()
}
```

> `snapshot()` is exactly what the `getEngineStats` platform method returns to the Flutter dashboard. Counters are per dispatch source (`watch_wear_os`, `watch_rtos_mirror`, `notification_tray`) and carry no message content, no sender names, and no per-contact data. The `ramMb` field in the channel contract is measured by the bridge on request via `ActivityManager.getProcessMemoryInfo()` — it is never stored.

#### 9.7.4 AppLabelCache — one PackageManager hit per package

```kotlin
package com.wristreply.app.engine

import android.content.pm.PackageManager
import java.util.concurrent.ConcurrentHashMap

object AppLabelCache {
    private val cache = ConcurrentHashMap<String, String>()
    private lateinit var pm: PackageManager

    fun init(packageManager: PackageManager) { pm = packageManager }

    fun labelFor(packageName: String): String = cache.getOrPut(packageName) {
        runCatching { pm.getApplicationLabel(pm.getApplicationInfo(packageName, 0)).toString() }
            .getOrDefault(packageName)
    }
}
```

### 9.8 ActionBroadcastReceiver — headless dispatch

```kotlin
package com.wristreply.app.receivers

import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat

class ActionBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val replyText = intent.getStringExtra("KEY_REPLY_TEXT") ?: return
        val resultKey = intent.getStringExtra("KEY_RESULT_KEY") ?: return
        val notificationKey = intent.getStringExtra("KEY_NOTIFICATION_KEY")
        @Suppress("DEPRECATION")
        val original = intent.getParcelableExtra<PendingIntent>("KEY_ORIGINAL_INTENT") ?: return

        val results = Bundle().apply { putCharSequence(resultKey, replyText) }
        val fillIn = Intent().apply {
            RemoteInput.addResultsToIntent(arrayOf(RemoteInput.Builder(resultKey).build()), this, results)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                RemoteInput.setResultsSource(this, RemoteInput.SOURCE_FREE_FORM_INPUT)
            }
        }

        runCatching { original.send(context, 0, fillIn) }
            .onSuccess { notificationKey?.let { NotificationManagerCompat.from(context).cancel(it.hashCode()) } }
            .onFailure { /* log a scrubbed, content-free failure; never crash the receiver */ }
    }
}
```

### 9.9 NotificationProcessorService — the thin orchestrator

```kotlin
package com.wristreply.app.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.wristreply.app.engine.*
import com.wristreply.app.filters.ProfanityGuardEngine
import com.wristreply.app.filters.SmartTokenExtractor
import kotlinx.coroutines.*

class NotificationProcessorService : NotificationListenerService() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var config: EngineConfig
    private lateinit var publisher: NotificationPublisher
    private val ml = EphemeralMLKitEngine()
    private val inFlight = ReplyBudget(maxConcurrent = 5)
    private val jobs = mutableMapOf<String, Job>()

    override fun onCreate() {
        super.onCreate()
        config = EngineConfig(applicationContext)
        publisher = NotificationPublisher(applicationContext).also { it.ensureChannel() }
        AppLabelCache.init(packageManager)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        val active = sbn ?: return
        if (!NotificationGate.shouldInspect(active)) return
        if (!config.isEnabled() || !config.isPackageAllowed(active.packageName)) return
        if (jobs[active.key]?.isActive == true) return          // de-dup BEFORE taking a budget slot
        if (!inFlight.offer(active.key)) return                // bounded concurrency (max 5)

        jobs[active.key] = scope.launch {
            try {
                val target = DynamicTargetResolver.resolve(active) ?: return@launch
                val text = target.messageText

                if (config.shieldEnabled() && ProfanityGuardEngine.isAbusive(applicationContext, text)) {
                    NotificationWarnings.postAbuse(applicationContext, target.senderName)
                    return@launch                              // never emit cheerful pills for abuse
                }
                if (config.autoCopyEnabled()) {
                    SmartTokenExtractor.scan(text)?.let {
                        SmartTokenExtractor.copy(applicationContext, it)
                        NotificationWarnings.postCopied(applicationContext, it)
                    }
                }

                val suggestions: List<ReplySuggestion> =
                    ml.suggest(target)
                        .map { ReplySuggestion(it, ReplySuggestion.Source.ML_KIT) }
                        .ifEmpty { FallbackReplyEngine.reply(target, config.userOverrides(), config.persona()) }

                if (suggestions.isNotEmpty()) publisher.publish(target, suggestions, config.privacyMode())
            } finally {
                inFlight.release(active.key)
                jobs.remove(active.key)
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        val key = sbn?.key ?: return
        jobs.remove(key)?.cancel()
        inFlight.release(key)
        publisher.cancel(key)
        ml.reset()
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) requestRebind(
            android.content.ComponentName(this, NotificationProcessorService::class.java)
        )
    }

    override fun onDestroy() { scope.cancel(); super.onDestroy() }
}
```

### 9.10 OEM Keep-Alive Manager

```kotlin
package com.wristreply.app.engine.oem

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings

object OemKeepAliveManager {

    fun requestBatteryExemption(context: Context) {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            .setData(Uri.parse("package:${context.packageName}"))
        runCatching { context.startActivity(intent) }
    }

    /** Best-effort deep links to vendor autostart managers; every one must fail soft. */
    fun openVendorAutostart(context: Context): Boolean {
        val candidates = when (Build.MANUFACTURER.lowercase()) {
            "xiaomi", "redmi", "poco" -> listOf("com.miui.securitycenter/com.miui.permcenter.autostart.AutoStartManagementActivity")
            "huawei", "honor" -> listOf("com.huawei.systemmanager/.startupmgr.ui.StartupNormalAppListActivity")
            "oppo", "realme", "oneplus" -> listOf("com.coloros.safecenter/.permission.startup.StartupAppListActivity")
            "vivo" -> listOf("com.vivo.permissionmanager/.activity.BgStartUpManagerActivity")
            "samsung" -> listOf("com.samsung.android.lool/com.samsung.android.sm.ui.battery.BatteryActivity")
            else -> emptyList()
        }
        for (component in candidates) {
            val intent = Intent().setClassName(component.substringBefore('/'), component.substringAfter('/'))
            if (intent.resolveActivity(context.packageManager) != null) { runCatching { context.startActivity(intent) }; return true }
        }
        return false
    }
}
```

### 9.11 LPTE Profanity Shield

```kotlin
package com.wristreply.app.filters

import android.content.Context

object ProfanityGuardEngine {

    private val DEFAULT_BLOCKED = setOf("badword1", "gali1", "harami", "scam", "fraud")

    fun isAbusive(context: Context, text: String): Boolean = matchedToken(context, text) != null

    fun matchedToken(context: Context, text: String): String? {
        val custom = context.getSharedPreferences("wrist_reply_filters", Context.MODE_PRIVATE)
            .getStringSet("custom_blocked_words", emptySet()).orEmpty()
        val dictionary = DEFAULT_BLOCKED + custom
        val normalized = text.lowercase().replace("[^a-z0-9\\u0980-\\u09FF\\s]".toRegex(), " ")
        return normalized.split("\\s+".toRegex()).firstOrNull { it.isNotEmpty() && it in dictionary }
    }
}
```

*Rules:* run the shield **before** ML Kit so abusive threads never produce cheerful pills; on a hit, post the warning notice and stop processing; normalization must strip punctuation and preserve Bengali codepoints.

### 9.12 OTP / Transaction-ID Extractor

```kotlin
package com.wristreply.app.filters

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context

object SmartTokenExtractor {

    private val TRX_ID = Regex("(?i)(?:trx\\s?id|txid|tran\\s?id|transaction\\s?id|ref(?:erence)?\\s?no)[:\\s#]+([A-Z0-9]{8,20})")
    private val OTP = Regex("(?i)(?:otp|code|pin|verification|ভেরিফিকেশন)[:\\s]+(\\d{4,8})")
    private val UPI_REF = Regex("(?i)(?:utr|rrn|upi\\s?ref)[:\\s]+(\\d{12})")

    data class Token(val type: TokenType, val value: String)
    enum class TokenType { TRANSACTION_ID, OTP, UPI_REFERENCE }

    fun scan(text: String): Token? {
        TRX_ID.find(text)?.groupValues?.getOrNull(1)?.let { return Token(TokenType.TRANSACTION_ID, it) }
        UPI_REF.find(text)?.groupValues?.getOrNull(1)?.let { return Token(TokenType.UPI_REFERENCE, it) }
        OTP.find(text)?.groupValues?.getOrNull(1)?.let { return Token(TokenType.OTP, it) }
        return null
    }

    fun copy(context: Context, token: Token) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboard.setPrimaryClip(ClipData.newPlainText(token.type.name, token.value))
    }
}
```

*Coverage contract:* the regex set must be regression-tested against samples for bKash, Nagad, Rocket, generic bank SMS, PayPal, Stripe, UPI/PhonePe/Paytm, Apple Pay, Google Pay, AliPay, GrabPay, iDEAL, SberPay, OPay/PalmPay, and exchange notifications (Binance-style). Each case asserts exactly one token is extracted and that the copied value excludes surrounding punctuation. See the related `lpte` project: <https://github.com/mahmud-r-farhan/lpte>.

### 9.13 Wear Sync

```kotlin
package com.wristreply.app.services

import android.content.Context
import com.google.android.gms.wearable.Wearable
import org.json.JSONArray
import org.json.JSONObject

object WearSyncService {
    private const val PATH = "/smart_replies"

    fun broadcast(context: Context, notificationKey: String, suggestions: List<String>) {
        val payload = JSONObject()
            .put("key", notificationKey)
            .put("replies", JSONArray(suggestions))
            .toString().toByteArray(Charsets.UTF_8)

        Wearable.getNodeClient(context).connectedNodes
            .addOnSuccessListener { nodes -> nodes.forEach { Wearable.getMessageClient(context).sendMessage(it.id, PATH, payload) } }
    }
}
```

**Path matrix:** Wear OS → `MessageClient` + Wear Compose chip stack (Phase 2); Zepp OS → JS micro-app over the Zepp bridge loopback (Phase 2, optional); budget RTOS → nothing to do, native mirroring already carries the pills (Phase 1).

### 9.14 Configuration Store (the Flutter ⇄ Native contract)

```kotlin
package com.wristreply.app.bridge

import android.content.Context
import android.content.SharedPreferences

/** Single source of truth for engine configuration; written by Flutter, read by the daemon. */
class EngineConfig(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("wrist_reply_prefs", Context.MODE_PRIVATE)
    private val allowlist: SharedPreferences = context.getSharedPreferences("wrist_reply_whitelist", Context.MODE_PRIVATE)

    fun isEnabled() = prefs.getBoolean("wr_engine_enabled", true)
    fun pillsPerMessage() = prefs.getInt("wr_pills_count", 3).coerceIn(1, 3)
    fun privacyMode() = prefs.getBoolean("wr_privacy_mode", false)
    fun replaceMode() = prefs.getBoolean("wr_replace_mode", false)
    fun shieldEnabled() = prefs.getBoolean("wr_shield_enabled", true)
    fun autoCopyEnabled() = prefs.getBoolean("wr_autocopy_enabled", false)
    fun userOverrides(): List<String> = prefs.getString("wr_custom_pills", "").orEmpty()
        .split("|").map(String::trim).filter(String::isNotEmpty)
    fun persona() = com.wristreply.app.engine.UserPersona.valueOf(
        prefs.getString("wr_persona", "CASUAL") ?: "CASUAL"
    )
    fun isPackageAllowed(pkg: String) = allowlist.getBoolean(pkg, true)
}
```

**Contract rules**

1. Every key is declared as a `const val` in `PrefKeys.kt` and mirrored in Dart's `app_keys.dart`; a unit test asserts the two lists are identical.
2. Defaults in Kotlin are authoritative; Dart never writes a value it did not receive from a user interaction.
3. The daemon registers an `OnSharedPreferenceChangeListener` and refreshes its cached `StateFlow` — no polling.

---

## 10. Flutter Presentation Layer

### 10.1 Channel Contract

| Channel | Type | Method / Event | Payload | Returns |
| :--- | :--- | :--- | :--- | :--- |
| `com.wristreply.app/engine` | Method | `isNotificationAccessGranted` | — | `bool` |
| | | `openNotificationAccessSettings` | — | `void` |
| | | `isPostNotificationsGranted` | — | `bool` |
| | | `requestPostNotifications` | — | `bool` |
| | | `isBatteryExemptionGranted` | — | `bool` |
| | | `requestBatteryExemption` | — | `bool` |
| | | `openVendorAutostart` | — | `bool` |
| | | `getDiscoveredApps` | — | `List<Map>` (`package`, `label`, `enabled`) |
| | | `setAppEnabled` | `package`, `enabled` | `void` |
| | | `getEngineStats` | — | `Map` (`generated`, `dispatched`, `avgLatencyMs`, `ramMb`) |
| | | `previewSuggestions` | `text` | `List<String>` (sandbox only) |
| | | `setConfig` | `key`, `value` | `void` |
| `com.wristreply.app/events` | Event | `engineState` | `Map` (`active`, `listenerConnected`, `wearableConnected`) | stream |
| | | `dispatchEvent` | `Map` (`source`, `latencyMs`) | stream |

### 10.2 Platform Gateway

```dart
import 'package:flutter/services.dart';

class NativeChannel {
  static const MethodChannel _methods = MethodChannel('com.wristreply.app/engine');
  static const EventChannel _events = EventChannel('com.wristreply.app/events');

  static Future<bool> isNotificationAccessGranted() async =>
      await _methods.invokeMethod<bool>('isNotificationAccessGranted') ?? false;

  static Future<void> openNotificationAccessSettings() =>
      _methods.invokeMethod<void>('openNotificationAccessSettings');

  static Future<List<DiscoveredApp>> getDiscoveredApps() async {
    final raw = await _methods.invokeListMethod<Map<Object?, Object?>>('getDiscoveredApps') ?? const [];
    return raw.map(DiscoveredApp.fromMap).toList(growable: false);
  }

  static Stream<Map<Object?, Object?>> get engineState =>
      _events.receiveBroadcastStream().cast<Map<Object?, Object?>>();
}

/// Plain data holder for a discovered messaging client. No package names are hardcoded:
/// the list always comes from the native capability scan.
class DiscoveredApp {
  const DiscoveredApp({required this.package, required this.label, required this.enabled});

  final String package;
  final String label;
  final bool enabled;

  factory DiscoveredApp.fromMap(Map<Object?, Object?> map) => DiscoveredApp(
        package: map['package'] as String? ?? '',
        label: map['label'] as String? ?? '',
        enabled: map['enabled'] as bool? ?? true,
      );

  DiscoveredApp copyWith({bool? enabled}) =>
      DiscoveredApp(package: package, label: label, enabled: enabled ?? this.enabled);
}
```

### 10.3 Design System Tokens (OLED Dark Utility)

| Token | Hex | Role |
| :--- | :--- | :--- |
| `surface-canvas` | `#0B0E14` | Root scaffold background |
| `surface-raised` | `#131823` | Cards, sheets, list tiles |
| `surface-interactive` | `#1C2333` | Pills, inputs |
| `border-subtle` | `#222B3D` | 1px separators |
| `border-accent` | `#2D3A54` | Hover / focus / active outline |
| `accent-primary` | `#00F2FE` | Status indicators, toggles, icons |
| `accent-mint` | `#38EF7D` | Successful dispatch, live pulse |
| `accent-warning` | `#FFB020` | Missing permission, disconnected node |
| `text-primary` | `#F1F5F9` | Titles, pill labels |
| `text-secondary` | `#94A3B8` | Descriptions, timestamps |
| `text-tertiary` | `#475569` | Disabled / metadata |

**Typography:** `Space Grotesk` (hero metrics 32/700, section titles 18/600) · `Inter` (body 14/400, micro badge 11/500 caps, pill label 13/600).

**Motion spec**

| Interaction | Motion |
| :--- | :--- |
| Pill press | scale 1.00 → 0.96, 90 ms, `easeOutQuad`, light haptic |
| Pill release/dispatch | 0.96 → 1.02 → 1.00, 180 ms, `elasticOut`; border `#222B3D` → `#00F2FE` → `#38EF7D` |
| Permission granted | radio `(○)` morphs to mint `(✓)` + medium haptic |
| Launch button | spring in `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| Feedback toasts | none — a 2px top progress-bar flash instead |
| Loading spinners | **never** — instant local render with shimmer placeholders |

### 10.4 Screen Specifications

**Screen 1 — Zero-Friction Permissions Handshake**
Layout: logo + `Step 1 of 2` → hero card with glowing mint shield and copy *"100% On-Device Isolation — your incoming chats never touch external servers"* → `CORE ACCESS REQUIRED` block with the Notification Bridge row (`(●)` + `GRANT ACCESS`) → optional Background Keep-Alive row (`(○)` + `WHITELIST ME`) → `LAUNCH CONSOLE` (enabled only once Step 1 is granted).
Rules: the disclosure card must be visible **before** the system settings intent fires (Play requirement); returning with the grant flips the state without a reload.

**Screen 2 — Real-Time Cockpit / Console**
Header `⚡ WRISTREPLY CONSOLE` + `[ ● LIVE ]` pulsing status; hardware & engine status card (daemon state, wearable node, protected RAM); performance snapshot (replies dispatched, average BLE round trip); live sandbox with a test input and generated pills (tap = simulate dispatch, never a real send); monitored platforms row of app toggles.

**Screen 3 — Persona & Pill Tailoring**
Tone segmented control (Casual `"Astechi 5m"` / Professional `"Understood"` / Benglish Mix); persistent fallback pill list with delete + `+ ADD CUSTOM FALLBACK TEMPLATE`; dynamic injection switches (location pin, suppress duplicate chime, floating assistive bubble).

**Screen 4 — Wear OS Micro-HUD (Phase 2)**
Circular dial: app label, sender, message, vertical pill stack of full-width chips, min 44dp height, frost-white labels on `#1C2333`, 8dp corners, immediate `EFFECT_CLICK` vibration, checkmark, dismissal < 100 ms.

### 10.5 Accessibility

1. Every interactive chip ≥ 48dp (mobile) / 44dp (wearable).
2. Every pill exposes a semantic label, e.g. *"Tap to immediately send this quick reply via WhatsApp."*
3. Contrast: `#0B0E14` on `#F1F5F9` = **16.2:1** (AAA); never place `text-tertiary` on `surface-interactive` for body copy.
4. All state changes (grant, dispatch, failure) must be announced by the screen reader, not only shown visually.

---

## 11. Testing & Quality Assurance

### 11.1 Test Layers

| Layer | Scope | Tooling | Must-pass |
| :--- | :--- | :--- | :--- |
| Kotlin unit | Gate logic, resolver heuristics, fallback tiers, regexes, chrono bias | JUnit5 + Robolectric (notification fixtures) | 100% of `engine` and `filters` |
| Kotlin instrumentation | Listener binding, real `StatusBarNotification` resolution, dispatch round trip | `androidTest` + `NotificationListenerService` harness | All FR-2.x, FR-5.x |
| Dart unit | Providers, key parity, config serialization | `flutter_test` | 100% of providers |
| Dart widget | Widget rendering (pills, badges, banners) at 1.0, 1.3, 2.0 textScale | `flutter_test` + golden files | All atomic widgets |
| Manual/device | Real apps, real watches, OEM behaviours | ADB + matrix (§11.3) | Per release |
| Performance | Latency, RAM, wakeups, battery | Macrobenchmark, `dumpsys meminfo`, Battery Historian | NFR-1.x |

### 11.2 Mandatory Automated Assertions

1. `NotificationGate` rejects: ongoing, group summary, self-injected, blank text, null notification.
2. `DynamicTargetResolver` resolves a WhatsApp-style action set **and** a WearableExtender-only set **and** returns `null` when no `RemoteInput` exists.
3. `FallbackReplyEngine` returns exactly 3 pills for: empty ML result, Bengali script input, "kemon acho" input, and a user-override set.
4. `SmartTokenExtractor` extracts exactly one token from every provider fixture and copies no punctuation.
5. Pref-key parity test: Kotlin `PrefKeys` set == Dart `appKeys` set.
6. File-size gate: no file in `lib/` or `android/app/src/main/kotlin/` exceeds 150 lines.
7. Hardcoded-package gate: no literal `com.whatsapp`/`org.telegram` outside test fixtures.
8. `vanillaRelease` manifest contains **no** `android.permission.INTERNET`.

### 11.3 Real-World Verification Matrix

| Target app | Extraction path | Expected result |
| :--- | :--- | :--- |
| WhatsApp | Standard actions | `resultKey` resolves; reply lands in thread |
| WhatsApp Business / clones | Standard actions | Works with zero code change |
| Telegram / Telegram X | Standard actions | Dispatch succeeds |
| Google Messages (RCS) | MessagingStyle + action | Reply without unlock |
| Signal | Standard actions | Local encryption preserved (OS handles send) |
| Facebook Messenger | Standard actions | Quick reply resolved |
| Slack / Teams (work profile) | Standard or WearableExtender | Only if profile grants listener access |
| Native SMS (OEM) | Standard actions | Works |
| Media player / download | Gate rejection | No pills |
| Group summary | Gate rejection | No pills |

### 11.4 Definition of Done (per feature)

1. Code ≤ 150 lines/file, named per §7.7, no hardcoded packages, no message content in logs.
2. Unit + widget tests added and green; `flutter analyze` and Gradle lint clean.
3. Configurable from the settings UI and persisted natively.
4. Verified on the ADB simulation path and at least one real messenger.
5. Battery/RAM budget unchanged (or documented improvement).
6. Doc updated in this file if behaviour or contract changed.

### 11.5 Release Regression Checklist

* [ ] Airplane mode: pills still generate and dispatch (queued locally).
* [ ] Locked device: pill dispatch works without unlock.
* [ ] Single chime only (no double alert).
* [ ] Swipe-away source removes the companion.
* [ ] Reboot: listener rebinds; settings intact.
* [ ] Doze (8 h): no wakeups, no missed messages after wake.
* [ ] OEM kill (Xiaomi/Samsung/Oppo emulation): auto-rebind within 5 s.
* [ ] TalkBack pass over onboarding + dashboard + pills.
* [ ] Text scale 1.3: no clipping or overflow in any screen.
* [ ] Bengali/Banglish messages produce sensible pills.
* [ ] OTP/TrxID auto-copy produces exactly one clipboard entry.
* [ ] Abusive message produces the warning path, not cheerful pills.
* [ ] `vanillaRelease` APK has no INTERNET permission.

---

## 12. Performance Budget & Optimization

| Budget | Target | How to hold it |
| :--- | :--- | :--- |
| Native daemon RSS | 15–25 MB | No Flutter in background; lazy `EngineConfig`; bounded in-flight jobs |
| Idle CPU | 0% | `NotificationGate` rejects before any allocation; no polling, no timers |
| Inference | ≤ 250 ms p90 | `Dispatchers.Default`; capped context (≤10 messages); close client immediately |
| Notification post latency | ≤ 40 ms after inference | Pre-built channel; reuse `NotificationCompat.Builder` template |
| Settings UI cold start | ≤ 900 ms | No blocking channel calls in `build()`; splash theme; cached prefs snapshot |
| APK size | ≤ 12 MB | `shrinkResources`, ABI splits, R8, no analytics SDK in `vanilla` |
| Wakeups | 0/min idle | No `AlarmManager`, no polling; event-driven only |

**Anti-patterns (forbidden):**

1. Static `SmartReplyGenerator` field held for the service lifetime.
2. Summoning a hidden `FlutterEngine` to read settings.
3. `Thread.sleep`, busy-wait loops, or polling `SharedPreferences`.
4. Posting a `PRIORITY_HIGH`/default-importance companion notification (double chime).
5. Holding message text in a static map after dispatch (memory + privacy leak).
6. Parsing large `EXTRA_TEXT_SUMMARY`/big-text bundles when `EXTRA_TEXT` suffices.

---

## 13. Privacy, Compliance & Policy Contract

### 13.1 Privacy Guarantees

1. Message content is processed only in RAM, only for the duration of inference, then discarded.
2. No content is written to disk, logged, or transmitted.
3. The `vanilla` release manifest excludes `android.permission.INTERNET`.
4. The `full` flavour (crash reporting) may only transmit crash stacks, device model and OS version — never message text, sender names, or package-level conversation metadata tied to a person. It must declare diagnostics in the Data Safety form.
5. Notification history is not persisted; only aggregate counters (count, average latency) are stored locally and are clearable.

### 13.2 Required In-App Disclosures

* **Prominent disclosure before requesting notification access:** an undismissable card stating, in the user's locale, that notification access is used solely to read incoming message text on-device and attach smart reply actions.
* **Data Safety statement in-app:** a settings row stating "No data leaves your device; no account, no cloud."
* **Clipboard automation disclosure:** explain that copied OTP/TrxID values are placed on the system clipboard where other apps may read them, and that the feature is off by default.

### 13.3 Google Play Compliance Matrix

| Vector | Requirement | Implementation |
| :--- | :--- | :--- |
| Restricted permission (NotificationListenerService) | Declaration form + demo video | `HUMAN_TASKS.md` Phase 4: 30s unlisted YouTube recording showing message → pills → send |
| Permissions declaration text | Explain the single purpose | *"NotificationListenerService is strictly required to detect incoming conversational contexts and attach on-device Google ML Kit reply actions."* |
| Data Safety form | Data collection **No**, sharing **No**; diagnostics **Yes** only if Crashlytics ships | `vanilla` flavour answers "No" to everything |
| Ads / monetization | Prohibited with this permission | No ad SDK, no IAP |
| Accessibility API use | Not used | No `AccessibilityService` anywhere |
| Privacy policy | Public URL, on-device statement | Required before first submission |
| Target API level | Current Play minimum (verify each cycle) | Bump `targetSdk` with each yearly deadline |
| Foreground services | Only when a wearable session is active; declare `foregroundServiceType` | Avoid entirely in MVP — event-driven listener needs no FGS |

### 13.4 Policy Red Lines (never do these)

1. Never upload, mirror, or back up message content.
2. Never use notification content for advertising, profiling, or audience building.
3. Never repurpose notification access for unrelated features (e.g. step counting, credit scoring).
4. Never sell or share any derived signal with a third party.
5. Never ship the `full` flavour as the default listing build.

---

## 14. Release & Distribution Process

### 14.1 Versioning

* `versionName`: `MAJOR.MINOR.PATCH` (semver-ish; Play shows it to users).
* `versionCode`: monotonically increasing integer, derived from a build counter.
* Every release maps to a Git tag `v<x.y.z>` and a signed `.aab`.

### 14.2 Pipeline Steps

```text
1. Freeze  → feature freeze on the release branch; update CHANGELOG + master.md
2. Verify  → flutter analyze · gradle lint · unit + instrumentation suites · regression checklist
3. Build   → flutter build appbundle --flavor vanilla --release --obfuscate
4. Sign    → upload keystore (Play App Signing enabled; keystore never in the repo)
5. Stage   → Internal testing track → 20 testers, 48 h minimum
6. Review  → Closed track (Alpha) → verify vitals (crash-free ≥ 99.5%, ANR < 0.4%)
7. Market  → Staged rollout 10% → 50% → 100%, each with a 24 h vitals gate
8. Post    → Archive symbols, capture screenshots for the listing, update ASO copy if needed
```

### 14.3 Signing Reference

```bash
keytool -genkey -v -keystore wristreply-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias wristreply
```

Store `key.properties` + keystore privately; load them in `android/app/build.gradle` from `signingConfigs.release`. Never commit either file; add `*.jks` and `key.properties` to `.gitignore`.

### 14.4 Post-Launch Monitoring

| Signal | Threshold | Action |
| :--- | :--- | :--- |
| Crash-free sessions | < 99.5% | Halt rollout, hotfix |
| ANR rate | > 0.4% | Investigate listener path first |
| Battery complaints in reviews | rising | Re-check wakeup budget |
| "Reply didn't send" reports | any cluster | Check `resultKey`/source handling per app version |
| Play policy email | any | Respond within 72 h; be ready to disable a feature flag remotely by releasing a config default change |

---

## 15. Roadmap & Phase Gates

### Phase 0 — Foundations (1 week)

*Deliverables:* repo layout, Gradle/manifest contract, channel definitions, pref-key parity test, CI checks (line count, hardcoded packages, INTERNET-absence gate), design tokens in Dart.
*Gate GATE-0:* `flutter analyze` clean; empty-but-valid app builds in both flavours; CI gates green.

### Phase 1 — MVP Engine + Console (3 weeks)

*Deliverables:* `NotificationGate`, `DynamicTargetResolver`, `EphemeralMLKitEngine`, `FallbackReplyEngine`, `NotificationPublisher`, `ActionBroadcastReceiver`, `EngineConfig`, onboarding, dashboard, app whitelist, persona basics.
*Gate GATE-1:* ADB simulation yields pills; a real WhatsApp message is answered from the shade without unlock; RAM ≤ 25 MB; no double chime; all FR-1.x–FR-5.x and FR-8.x pass.

### Phase 2 — Wearables + Intelligence (2–3 weeks)

*Deliverables:* Wear OS companion module (`MessageClient` + chip stack), persona engine, chrono heuristics, location pill, LPTE shield, OTP/TrxID automation, local metrics.
*Gate GATE-2:* watch round trip ≤ 150 ms; shield and clipboard features verified against the provider fixture corpus; no content in any outbound payload.

### Phase 3 — Hardening & Store (1–2 weeks)

*Deliverables:* OEM keep-alive flows, battery-exemption UX, privacy policy page, data-safety answers, store assets, demo video (human task), staging → production rollout.
*Gate GATE-3:* full regression checklist green; Play review approved; crash-free ≥ 99.5% over 72 h of internal testing.

### Phase 4 — Post-Launch (ongoing)

Wear OS store tab, Bengali UI localization, Zepp OS micro-app (optional, demand-driven), additional regional fallback banks (Hindi, Indonesian, Arabic), per-contact persona rules, battery telemetry (local only).

---

## 16. Risk Register

| # | Risk | Impact | Likelihood | Mitigation |
| :--- | :--- | :--- | :--- | :--- |
| R1 | Play rejects the notification-listener declaration | Critical (blocks launch) | Medium | Prominent disclosure, demo video, no-internet build, no ads, precise declaration text |
| R2 | ML Kit returns no suggestions for regional languages | High (core feature) | High | Multi-tier fallback engine, persona banks, on-device-only positioning |
| R3 | Target app changes its notification structure | High | Medium | Capability-based resolution + graceful "no endpoint → skip" behaviour; no package logic to update |
| R4 | Duplicate notifications annoy users | Medium | High | Companion mode grouped under the original key, LRU budget, replace mode opt-in |
| R5 | OEM kills the listener | High | High | `onListenerDisconnected` → `requestRebind()`, battery-exemption flow, vendor autostart deep links |
| R6 | Double chime / extra vibration | Medium | Medium | `IMPORTANCE_LOW` channel, `setSilent(true)`, `setOnlyAlertOnce(true)` |
| R7 | Passing `PendingIntent` extras breaks on new API levels | High | Low | Explicit `FLAG_MUTABLE`, `IntentCompat` fallbacks, API-matrix instrumentation tests |
| R8 | Users expect cloud-quality replies | Medium | Medium | Set expectations in onboarding ("local, instant, private"); persona tuning |
| R9 | Clipboard automation flagged as a privacy risk | Medium | Medium | Off by default, explicit disclosure, per-type toggles |
| R10 | File-size/modularity rules erode | Medium | Medium | CI line-count gate + code review checklist |
| R11 | Grouped notifications exceed shade budget | Low | Medium | Max 3 live companions with `setTimeoutAfter` + LRU eviction |
| R12 | Work-profile notifications inaccessible | Low | Medium | Document the limitation; scope §3.3 |

---

## 17. Human-Only Tasks (Condensed)

Full detail: `HUMAN_TASKS.md`. An AI agent must not execute these.

1. Install Android Studio + SDK 34/35, create Wear OS and Phone emulators, pair them.
2. Grant notification access and battery exemption on a physical device; verify the prominent disclosure.
3. Run the ADB simulation test and confirm 3 pills + single chime.
4. Generate the production keystore; store it privately; configure signing.
5. Record the mandatory 30-second review video and upload it unlisted.
6. Complete the Play Console Data Safety form, permission declaration, and privacy-policy URL.
7. Produce store graphics: 512×512 icon, 1024×500 feature graphic, ≥4 phone screenshots (and 2 Wear OS screenshots if shipping Phase 2).

---

## Appendix A — Glossary

| Term | Meaning |
| :--- | :--- |
| **Companion notification** | Our own silent notification carrying the smart-reply actions, grouped with the source |
| **RemoteInput** | Android API that defines a text input whose results can be delivered to another app's `PendingIntent` |
| **resultKey** | Bundle key that the target app expects inside the `RemoteInput` results |
| **Reply target** | Immutable bundle: sender, text, package, `resultKey`, `RemoteInput`, `PendingIntent` |
| **LPTE** | Language/Profanity Filter Engine (see `smart_parser_and_filter.md`, `lpte` repo) |
| **Benglish / Banglish** | Romanized Bengali used in chat |
| **RTOS watch** | Closed-source budget watch (boAt, Noise, Fire-Boltt) reachable only through notification mirroring |
| **Ephemeral inference** | Creating and closing the ML client per request to minimise memory |

## Appendix B — Requirement Traceability Map

| Requirement group | Primary source doc | Section in this file |
| :--- | :--- | :--- |
| Ingestion & gating | `engineering.md`, `system_feasibility_and_optimization.md` | §4.1, §9.2 |
| Dynamic discovery | `dynamic_app_detection.md` | §4.2, §9.3 |
| Inference & fallback | `agents.md`, `system_feasibility_and_optimization.md` | §4.3, §4.6, §9.4–9.6 |
| Presentation & dispatch | `Technical Architecture.md`, `PESG.md` | §4.4, §4.5, §7.5, §9.7–9.8 |
| Filters & clipboard | `smart_parser_and_filter.md` | §4.7, §9.11–9.12 |
| UI/UX & accessibility | `ui-ux.md` | §10, NFR-4.x |
| Build system | `gradle.md` | §8.2 |
| Performance | `system_feasibility_and_optimization.md`, `engineering.md` | §12, NFR-1.x |
| Compliance | `engineering.md`, `PESG.md`, `aso.md` | §13 |
| Store copy | `aso.md` | §1.2–1.5 |

## Appendix C — Reference Links

**Google ML Kit**
* Smart Reply — <https://developers.google.com/ml-kit/language/smart-reply>
* Translation — <https://developers.google.com/ml-kit/language/translation>
* Language identification — <https://developers.google.com/ml-kit/language/identification>
* GenAI summarization — <https://developers.google.com/ml-kit/genai/summarization/android>
* GenAI proofreading — <https://developers.google.com/ml-kit/genai/proofreading/android>
* GenAI rewriting — <https://developers.google.com/ml-kit/genai/rewriting/android>
* GenAI prompting — <https://developers.google.com/ml-kit/genai/prompt/android>

**Android platform**
* `NotificationListenerService` — <https://developer.android.com/reference/android/service/notification/NotificationListenerService>
* `RemoteInput` — <https://developer.android.com/reference/android/app/RemoteInput>
* Notification channels & importance — <https://developer.android.com/develop/ui/views/notifications/channels>
* Notification runtime permission (API 33+) — <https://developer.android.com/develop/ui/views/notifications/notification-permission>
* Package visibility (`<queries>`) — <https://developer.android.com/training/package-visibility>
* Battery optimization exemption — <https://developer.android.com/training/monitoring-device-state/doze-standby>
* Wear OS data layer — <https://developer.android.com/training/wearables/data-layer>

**Related project**
* LPTE (profanity/parser engine reference) — <https://github.com/mahmud-r-farhan/lpte>

## Appendix D — Agent Execution Directive (Condensed)

```text
You are an expert Android (Kotlin) & Flutter engineer building WristReply AI.

MUST
 1. Background engine = headless Kotlin only. Never boot Flutter in the background.
 2. Add reply actions via a silent companion notification (NotificationListenerService
    cannot mutate another app's notification). IMPORTANCE_LOW + setSilent(true);
    never produce a second chime or vibration.
 3. Everything user-facing is configurable in the settings UI and persisted to
    SharedPreferences, which the native daemon reads directly.
 4. Detect apps dynamically by inspecting RemoteInput / CATEGORY_MESSAGE / MessagingStyle.
    Zero hardcoded package names in engine logic.
 5. If ML Kit returns nothing, run the fallback engine (user overrides → Banglish →
    script defaults), with Bengali and regional support.
 6. Keep every file under 150 lines; small, reusable, single-responsibility units.
 7. UX must feel like a polished native mobile app: OLED dark tokens, 48dp targets,
    no spinners, subtle motion, full accessibility labels.
 8. Run the ADB simulation test after each engine change and confirm pills resolve
    and dispatch without unlocking.

NEVER
 - Create AccessibilityService-based text injection.
 - Add INTERNET to the vanilla release manifest.
 - Log, store, or transmit message content.
 - Hardcode WhatsApp/Telegram package names outside test fixtures.
 - Execute anything in HUMAN_TASKS.md.
```

## Appendix E — Document Changelog

| Version | Date | Change |
| :--- | :--- | :--- |
| 1.0.0 | 2026-09-28 | First consolidated master build document. Merges requirements, architecture, implementation, ASO copy, process, testing, compliance, roadmap and risk from all source docs; adds corrected platform constraints (companion-notification reality, `POST_NOTIFICATIONS`, `<queries>`, `setResultsSource`, pref-key parity, notification budget). |

---

*End of master.md — this file is the single source of truth for building WristReply AI. Update it in the same commit as any behavioural change.*