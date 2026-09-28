# Flutter Android App — From Zero to Google Play Production (September 2026 Edition)

> **Audience:** A developer (solo or team) building a new Android app with Flutter and shipping it to Google Play.
> **Written for:** 29 September 2026.
> **Purpose:** One document you can follow top-to-bottom. Every rule is written as an actionable statement, tagged **MUST** (blocks release or violates policy), **SHOULD** (strong best practice), or **AVOID** (known trap).
> **Honesty note:** Store policies and toolchain versions change every quarter. Section 0 lists what was verified against official sources in September 2026 and what you must re-verify on the day you ship. Never treat any version number in any document (including this one) as permanent.

---

## Table of Contents

0. [Snapshot: The Rules of the Game in September 2026](#0-snapshot-the-rules-of-the-game-in-september-2026)
1. [Phase 0 — Product Definition and Compliance Before Code](#1-phase-0--product-definition-and-compliance-before-code)
2. [Phase 1 — Google Play Developer Account and Identity](#2-phase-1--google-play-developer-account-and-identity)
3. [Phase 2 — Development Environment and Toolchain](#3-phase-2--development-environment-and-toolchain)
4. [Phase 3 — Project Architecture and Code Standards](#4-phase-3--project-architecture-and-code-standards)
5. [Phase 4 — Android Platform Configuration](#5-phase-4--android-platform-configuration)
6. [UI/UX Rules (Colour-Free, Structure and Behaviour Only)](#6-uiux-rules-colour-free-structure-and-behaviour-only)
7. [Performance Optimization for Android](#7-performance-optimization-for-android)
8. [Security and Privacy](#8-security-and-privacy)
9. [Testing and Quality Gates](#9-testing-and-quality-gates)
10. [Build, Signing, and Versioning](#10-build-signing-and-versioning)
11. [Play Console: Store Listing and App Content Declarations](#11-play-console-store-listing-and-app-content-declarations)
12. [Release Tracks: Internal → Closed → Production](#12-release-tracks-internal--closed--production)
13. [Post-Release Operations and the Yearly Treadmill](#13-post-release-operations-and-the-yearly-treadmill)
14. [Master Pre-Release Checklist](#14-master-pre-release-checklist)
15. [Top Rejection and Suspension Causes](#15-top-rejection-and-suspension-causes)
16. [Appendix — Snippets, Commands, Timeline, References](#16-appendix--snippets-commands-timeline-references)

---

## 0. Snapshot: The Rules of the Game in September 2026

### 0.1 Verified facts (checked against official or primary sources in September 2026)

| Topic | State as of 29 Sep 2026 | Re-verify where |
|---|---|---|
| **Target API level (Play)** | From **31 Aug 2026**, new apps and app updates must target **Android 16 (API 36)** or higher. Existing apps must target API 35+ to stay visible to new users on newer Android versions. An extension to 1 Nov 2026 could be requested. | Play Console → Policy status; Play Console Help "Target API level requirements" |
| **Play Billing Library** | From 31 Aug 2026, new apps/updates that use Play Billing must use **Billing Library 8 or later** (Google recommends going straight to the newest major). | Android Developers → Play Billing deprecation FAQ |
| **16 KB page size** | Apps targeting Android 15+ must support 16 KB memory pages (enforced since 1 Nov 2025; extended windows for existing apps passed in 2026). Native `.so` files from plugins are the usual failure point. | Play Console → App Bundle Explorer → "Memory page size" |
| **New personal accounts** | Personal accounts created after **13 Nov 2023** must run a **closed test with ≥ 12 testers opted in continuously for 14 days** before applying for production access. Organization accounts are outside this rule. | Play Console Help "App testing requirements for new personal developer accounts" |
| **Android developer verification** | Identity verification and **app registration** enforcement begins **30 Sep 2026** in Brazil, Indonesia, Singapore, Thailand (installs of unregistered apps are blocked on certified devices there). Global expansion planned for 2027+. Play developers are mostly auto-registered; still check the Play Console home page. | developer.android.com/developer-verification |
| **Flutter stable** | **Flutter 3.47.x** (Dart 3.13) is the current stable line (3.47.1 released 19 Aug 2026; later patches exist). Next planned: **3.50 in November 2026**. | docs.flutter.dev/release/archive |
| **Flutter Android defaults (3.47)** | Reported defaults: `compileSdk` / `targetSdk` **36**, `minSdk` **24**, Java 17 minimum, AGP 9.x, Gradle 9.x, Kotlin 2.x. | `flutter doctor -v`, `flutter analyze --suggestions` |
| **AGP 9 built-in Kotlin** | AGP 9 removed support for applying the Kotlin Gradle Plugin (`kotlin-android`). Flutter still tolerates the legacy setup temporarily but will remove it. Migrate app and plugins to *built-in Kotlin*. | docs.flutter.dev → Breaking changes → "Migrate to built-in Kotlin" |
| **Material / Cupertino split** | Flutter 3.47 ships standalone `material_ui` and `cupertino_ui` packages (1.0); the in-SDK design libraries are scheduled for formal deprecation in the November stable. | flutter.dev/blog "What's new in Flutter 3.47" |
| **Android 16 large-screen behaviour** | For apps targeting API 36, manifest orientation / resizability / aspect-ratio restrictions are **ignored on screens ≥ 600 dp** (tablets, foldables, desktop windowing). Edge-to-edge opt-out is removed. | developer.android.com → "App orientation, aspect ratio, and resizability" |

### 0.2 Things reported but to be re-verified before you rely on them

- Android 17 (API 37) location-button requirement for one-time precise location — reported with an enforcement date of **27 Jan 2027** (sourced from a community issue tracker, not a primary Google page). Check the official Play policy page before building any one-shot precise-location feature.
- Exact Gradle / AGP / Kotlin minimums for Flutter 3.47 — read them from your own `flutter doctor` output, not from articles.
- Regional availability of paid-app / merchant features for your country — check the official Play Console list of supported countries.

### 0.3 The three-clock model

Shipping on Android in 2026 means managing three independent clocks:

1. **Platform clock** — a new Android target API is required every 31 August.
2. **Framework clock** — Flutter releases roughly quarterly (Feb / May / Aug / Nov).
3. **Policy clock** — Play policy, data-safety and billing deadlines land continuously.

**RULE 0.1 (MUST):** Treat maintenance as part of the product. Budget at least one release per quarter even if you add no features.

---

## 1. Phase 0 — Product Definition and Compliance Before Code

Doing this first prevents the most expensive class of failure: building an app that cannot legally or technically ship.

### 1.1 Define the product in writing (one page)

- Problem statement, target user, top 3 jobs-to-be-done.
- **Core loop** — the single most repeated user action. Everything in v1 exists to make it fast.
- Non-goals for v1 (what you will *not* build).
- Success metrics: activation rate, day-1 / day-7 retention, crash-free users, store rating target.

### 1.2 Policy pre-screen (do this before writing code)

Answer these questions; each "yes" adds compliance work:

| Question | If yes, you must plan for |
|---|---|
| Can users create an account? | In-app **account deletion** + a public web deletion link; data-deletion declaration in Play Console |
| Is any content user-generated (chat, posts, uploads)? | Report + block mechanisms, moderation policy, terms of service |
| Do you sell digital goods, subscriptions, or in-app content? | **Google Play Billing** (Billing Library 8+), refund/cancel UX, tax and payments profile |
| Do you show ads? | Ads declaration, ad SDK data disclosure, Advertising ID handling |
| Is the app directed at children (under 13 or your region's equivalent)? | **Families Policy**, certified ad SDKs only, stricter data rules |
| Do you collect location, contacts, photos, microphone, camera, health data? | Runtime permission UX, Data safety disclosures, possibly a permission declaration form |
| Is it a finance, health, news, government, or gambling app? | Extra declarations and sometimes documents or licences |
| Do you need SMS, call-log, all-files, accessibility-service, VPN, or exact-alarm access? | Restricted permission declarations — often refused; redesign to avoid them |

**RULE 1.1 (MUST):** Design to *avoid* restricted permissions. Use the system photo picker instead of broad media permissions, the system share sheet instead of contacts, and inexact alarms / WorkManager instead of exact alarms unless the app is genuinely an alarm or calendar app.

**RULE 1.2 (MUST):** Do a **data inventory** now: list every piece of user data, where it is stored, who receives it (including every SDK), why, and how long it is kept. This becomes your privacy policy and your Data safety form. If you can't fill it in, you'll fail review later.

### 1.3 Irreversible decisions — decide carefully

| Decision | Why it is permanent |
|---|---|
| **Application ID** (e.g. `com.yourcompany.appname`) | Cannot be changed after first upload; it is the app's identity forever |
| **Developer account type** (personal vs organization) | Determines the closed-testing rule and how the app is presented; changing means transferring apps |
| **App signing model** | New apps use Play App Signing; you keep only an *upload key* |
| **Free vs paid** | A free app can never become a paid app on Play (in-app purchases are the path) |

**RULE 1.4 (MUST):** Use a reverse-domain application ID you control (a domain you own is best). Never ship `com.example.*`.

### 1.4 Dependency and licence policy

- **SHOULD** maintain an "approved packages" list. Prefer packages with a verified publisher, recent releases, high pub points, and native code that is 16 KB-aligned and AGP 9 / built-in-Kotlin ready.
- **MUST** record each dependency's licence; avoid licences incompatible with closed-source distribution.
- **AVOID** abandoned packages (no release in 12+ months) for security-sensitive or native-code features.

---

## 2. Phase 1 — Google Play Developer Account and Identity

### 2.1 Choose the account type

| | Personal | Organization |
|---|---|---|
| Registration fee | One-time (US$25) | One-time (US$25) |
| Identity | Government ID, contact address, phone, email verification | Legal entity verification, **D-U-N-S number**, organization website verified via Search Console |
| Closed-test rule | **12 testers × 14 days** required if account created after 13 Nov 2023 | Not applicable to organization accounts |
| Best for | Hobby, solo, first app | Companies, monetized products, teams |

**RULE 2.1 (SHOULD):** If you are building a business, register an organization account. It removes the 12-tester bottleneck and looks more trustworthy on the store page (the developer name and address are shown).

### 2.2 Account setup checklist

- [ ] Use a dedicated Google account (not a personal Gmail used for daily life) with **2-Step Verification / passkeys** enabled.
- [ ] Complete identity verification early — it can take days and is the longest unpredictable step.
- [ ] Complete **developer verification / app registration** in Play Console (check the Home page for any unregistered app; the enforcement date for the first four countries is 30 Sep 2026).
- [ ] Set up the **payments profile** if you will sell anything (merchant availability depends on your country).
- [ ] Add trusted team members with **least-privilege roles** (do not share the owner login).
- [ ] Add a monitored support email and, for organizations, a website.

**RULE 2.3 (MUST):** Never buy, rent, or borrow developer accounts, and never operate multiple accounts to dodge policy enforcement. Linked-account bans are permanent.

**RULE 2.4 (MUST):** Keep identity details identical everywhere (legal name, address, website). Mismatches are the top cause of verification delays.

---

## 3. Phase 2 — Development Environment and Toolchain

### 3.1 Install and pin

1. Install **Flutter stable** (currently 3.47.x). Never build production releases from the `beta` or `main` channels.
2. Install **Android Studio** (latest stable) and use its bundled JDK, or install JDK 17+ (Flutter's minimum). Set `JAVA_HOME` consistently on every machine and CI.
3. In SDK Manager install: **Android SDK Platform 36** (required for `compileSdk`/`targetSdk`), Build-Tools, Platform-Tools, Command-line Tools, **NDK** (Flutter provisions the version it needs), and emulator images (Android 16 phone, a tablet, and a **16 KB page-size** image).
4. Run `flutter doctor -v` until every line is green (accept licences with `flutter doctor --android-licenses`).
5. **Pin the Flutter version per project** using FVM (or a pinned CI action) so all developers and CI build with the identical SDK.

```bash
dart pub global activate fvm
fvm install stable          # or a specific 3.47.x
fvm use 3.47.x              # writes .fvmrc; commit it
fvm flutter doctor -v
```

**RULE 3.1 (MUST):** Commit `pubspec.lock`, the Gradle wrapper, `.fvmrc` (or equivalent), and CI config. A build must be reproducible from a clean clone.

**RULE 3.2 (SHOULD):** Run at least one physical low-end Android device (2–3 GB RAM, budget chipset) and one recent mid-range device in your daily workflow. Emulators hide thermal throttling, real GPU drivers, and low-memory kills.

### 3.2 Create the project

```bash
flutter create \
  --org com.yourcompany \
  --project-name your_app \
  --platforms=android \
  your_app
```

- **MUST** immediately verify `namespace` and `applicationId` in `android/app/build.gradle(.kts)` match your reserved application ID.
- **SHOULD** add other platforms later only if you actually plan to ship them; each platform adds CI and QA cost.

### 3.3 The Android build stack (AGP 9 era)

- Expect Gradle 9.x, AGP 9.x, Kotlin 2.x, and Java 17+.
- AGP 9 uses **built-in Kotlin**: the `kotlin-android` plugin must be removed from app and plugin Gradle files, and Kotlin options move to the `kotlin { }` block. Follow the official Flutter migration guide for app developers.
- Run `flutter analyze --suggestions` to see Flutter's own recommendations about Gradle / AGP / Kotlin / Java versions.
- If a plugin still applies the Kotlin Gradle Plugin, the build warns you. Upgrade that plugin, file an issue with its author, or replace it. **Do not** silence the warning permanently.

**RULE 3.3 (SHOULD):** Upgrade the toolchain in a dedicated branch, never mixed with feature work, and run the full test suite plus a release build before merging.

### 3.4 Version-control and repo hygiene

- Trunk-based or short-lived feature branches; protected `main`; required CI checks; required review.
- `.gitignore` **MUST** exclude: `key.properties`, `*.jks`, `*.keystore`, `google-services.json` if it contains restricted keys per your policy, `.env*` with secrets, `build/`, `.dart_tool/`.
- Conventional commits (or similar) so changelogs and release notes can be generated.
- **MUST** enable secret scanning on the repository host.

---

## 4. Phase 3 — Project Architecture and Code Standards

### 4.1 Feature-first layered structure

```
lib/
  main.dart                    # thin: bootstrap only
  app/                         # app widget, router, theme wiring, DI root
  core/                        # cross-cutting: network, storage, errors, logging, utils, l10n
  design_system/               # tokens, reusable widgets (no business logic)
  features/
    <feature_name>/
      data/                    # DTOs, API clients, repositories impl, local data sources
      domain/                  # entities, repository interfaces, use cases (pure Dart)
      presentation/            # screens, widgets, state holders (controllers/blocs/notifiers)
test/                          # mirrors lib/
integration_test/              # end-to-end flows
```

**RULE 4.1 (MUST):** Dependencies point inward: `presentation → domain ← data`. Domain code is pure Dart with no Flutter or platform imports so it is trivially testable.

**RULE 4.2 (MUST):** No business logic inside widgets. Widgets render state and forward events.

**RULE 4.3 (SHOULD):** Keep `main()` minimal: initialize only what is required before the first frame (see §7 startup rules).

### 4.2 Pick one of each and stay consistent

| Concern | Guidance |
|---|---|
| **State management** | Choose *one* mainstream, well-maintained approach (e.g. Riverpod or Bloc/Cubit). Mixing several is a maintenance tax. |
| **Navigation** | A declarative router (e.g. `go_router` or equivalent) with typed routes, deep-link support, and redirect guards for auth. |
| **Networking** | A single HTTP client wrapper (e.g. `dio`) with timeouts, retry with backoff for idempotent calls, auth-token refresh, and centralized error mapping. |
| **Serialization** | Code generation (`json_serializable` / `freezed` or equivalent) over hand-written parsing. |
| **Local storage** | Relational/structured data → a maintained SQLite layer (e.g. `drift`); small preferences → `shared_preferences`; secrets/tokens → Android Keystore-backed secure storage. Verify the package is maintained before adopting. |
| **Dependency injection** | Constructor injection; a DI container only at the composition root. |
| **Localization** | `flutter_localizations` + ARB files from day one, even if you ship one language. |
| **Logging / crash reporting** | A logger abstraction + a crash reporter (Crashlytics, Sentry, or equivalent), initialized behind consent where required. |

### 4.3 Error handling model

- **MUST** distinguish *expected failures* (no network, validation, 401, 404) from *bugs*. Model expected failures as values (`Result<T, Failure>` / sealed classes), not exceptions bubbling to the UI.
- **MUST** install global handlers: `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and an `runZonedGuarded` (or equivalent) so no error is silently lost.
- **MUST** map every failure to a user-facing state with a recovery action (see §6.8).
- **AVOID** catching `Exception` and swallowing it. Log with context or rethrow.

### 4.4 Environments and configuration

- **MUST** support at least `dev`, `staging`, `prod` via Android **product flavors** and/or `--dart-define-from-file`.
- **MUST NOT** hard-code API keys or secrets in Dart or resource files. Anything shipped in the APK/AAB is extractable. Secrets that must stay secret belong on a server.
- **SHOULD** give each flavor a distinct application ID suffix (`.dev`, `.staging`) so they install side-by-side, and a visibly different launcher label.

```bash
flutter run --flavor dev --dart-define-from-file=env/dev.json
```

### 4.5 Static analysis and code quality (enforced in CI, not optional)

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml   # or a stricter shared ruleset

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - unawaited_futures
    - use_build_context_synchronously
    - cancel_subscriptions
    - close_sinks
```

**RULE 4.6 (MUST):** CI fails on any analyzer warning, formatting diff (`dart format --set-exit-if-changed .`), or failing test.

**RULE 4.7 (SHOULD):** Keep files small and single-purpose; keep widget `build` methods short; extract widgets as classes (not helper methods returning widgets) so `const` and rebuild-scoping work.

**RULE 4.8 (SHOULD):** Write an **Architecture Decision Record** (ADR) for each major choice (state management, storage, navigation). Future you will need the *why*.

---

## 5. Phase 4 — Android Platform Configuration

### 5.1 SDK levels

| Setting | Rule |
|---|---|
| `compileSdk` | **MUST** be 36 or higher (use the value from Flutter's template unless you have a reason). |
| `targetSdk` | **MUST** be **36 or higher** for new apps and updates on Play after 31 Aug 2026. |
| `minSdk` | **SHOULD** stay at Flutter's default (24 on current Flutter). Raise it only with data from your target audience; every step up removes real users. |
| `ndkVersion` | **SHOULD** use the version Flutter provisions; older NDKs can produce non-16 KB-aligned libraries. |

**RULE 5.1 (MUST):** Reference SDK values through Flutter's variables (`flutter.compileSdkVersion`, `flutter.targetSdkVersion`, `flutter.minSdkVersion`) instead of hard-coding numbers, so Flutter upgrades keep you compliant. Override only deliberately.

### 5.2 Behaviour changes you inherit by targeting API 36

| Change | What to do |
|---|---|
| **Edge-to-edge is mandatory** (opt-out removed) | Draw behind system bars; use `SafeArea` / `MediaQuery` padding and view insets; never assume a fixed status-bar height. |
| **Orientation / resizability restrictions ignored on ≥ 600 dp screens** | Do not rely on `screenOrientation="portrait"` or `SystemChrome.setPreferredOrientations` to keep a phone layout on tablets/foldables. Build adaptive layouts (§6.5). |
| **Predictive back** | Use `PopScope` (not the deprecated `WillPopScope`); set `android:enableOnBackInvokedCallback="true"`; test the back gesture animation on Android 14+ devices. |
| **Photo picker changes** | Prefer the system Photo Picker; do not request broad media permissions. |
| **Foreground service rules** | Every foreground service must declare a valid type and (on Play) a declaration in App content. |
| **Scheduling / background limits** | Use WorkManager for deferrable work; avoid exact alarms and long-lived background services. |

**RULE 5.2 (MUST):** Test on Android 16 (real device or emulator) before every release. Read the official "Behavior changes: apps targeting Android 16" page each year.

### 5.3 `AndroidManifest.xml` baseline

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Declare ONLY what the app truly needs -->
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Add POST_NOTIFICATIONS only if you send notifications; request at runtime in context -->

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:enableOnBackInvokedCallback="true"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

Rules:

- **MUST** set `android:exported` explicitly on every component with an intent filter.
- **MUST NOT** ship with `usesCleartextTraffic="true"` unless an explicit, documented exception exists (use the network-security config to scope it to debug builds only).
- **MUST** decide backup behaviour deliberately: either `allowBackup="false"`, or restrictive `dataExtractionRules` that exclude tokens, databases with PII, and caches.
- **SHOULD** remove any permission a plugin merges in that you do not need (`tools:node="remove"`). Inspect the *merged* manifest (Android Studio → Manifest → Merged Manifest, or the generated file under `build/`).
- **MUST** declare the advertising-ID permission state correctly if the app targets API 33+ and uses ads or analytics that read the Advertising ID; remove it otherwise.
- **SHOULD** use `android:taskAffinity=""` and `singleTop` unless you have a reason not to (reduces task-hijack risk and duplicate-activity bugs).

### 5.4 Launcher identity

- **MUST** provide an **adaptive icon** (foreground + background layers, safe-zone respected) and a **monochrome / themed icon** layer for Android 13+.
- **MUST** use the **Android 12+ SplashScreen API** (via a themed splash, or a maintained splash package). Keep the splash static and fast; it is not a branding showcase.
- **SHOULD** localize the app label in every supported language.
- **MUST** keep a single, unambiguous app name; do not include emojis, prices, or "best/#1" claims (policy violation).

### 5.5 Deep links and App Links

- Use **verified Android App Links** (`android:autoVerify="true"`, hosted `/.well-known/assetlinks.json`) for HTTPS links you own.
- **MUST** treat all deep-link parameters as untrusted input (validate, never execute, never trust user IDs from the URL).
- **SHOULD** test with `adb shell am start -a android.intent.action.VIEW -d "https://..."` and verify with `adb shell pm get-app-links <package>`.

### 5.6 Notifications

- On Android 13+ the notification permission is a runtime permission. **MUST** ask *in context* after the user sees the value, never on first launch.
- **MUST** create notification channels with meaningful names; let users control categories.
- **SHOULD** set a small monochrome status-bar icon; a coloured launcher icon renders as a white blob.

### 5.7 Feature and device compatibility

- **MUST** mark hardware features as `required="false"` unless the app cannot function without them (camera, GPS, NFC), otherwise Play excludes devices and you lose installs silently.
- **SHOULD** review the *Device catalog* in Play Console before launch to see exclusions caused by merged manifest features.

---

## 6. UI/UX Rules (Colour-Free, Structure and Behaviour Only)

> These rules describe *structure, spacing, behaviour, and clarity* only. They deliberately avoid colour, brand, or visual style. Apply them on top of whichever design system you choose (Material 3 or its successor packages, Cupertino-style where appropriate, or your own tokens).

### 6.1 Foundational principles

1. **Clarity over cleverness.** A first-time user must understand each screen's purpose in about three seconds.
2. **One primary action per screen.** If two actions compete, one must be visually and structurally subordinate.
3. **Consistency beats novelty.** Same component, same behaviour, same placement everywhere.
4. **Feedback for every action.** Every tap gets an immediate, visible response.
5. **Forgiveness.** Undo, confirm destructive actions, preserve user input, and never lose data on rotation, back, or process death.
6. **Respect the platform.** Follow Android back behaviour, system bars, text scaling, permissions, and gestures instead of fighting them.
7. **Design for the worst case first:** small screen, large font, slow network, one hand, one bar of signal, low battery, screen reader on.

### 6.2 Design tokens (mandatory discipline)

**RULE UX-01 (MUST):** All visual values come from a token layer — spacing, radii, elevation levels, typography roles, icon sizes, durations, curves, and colour *roles* (never raw literals in widgets).

**RULE UX-02 (MUST):** Theme through `ThemeData` / a single theme extension. Widgets read tokens from `Theme.of(context)`; they never hard-code values.

**RULE UX-03 (MUST):** Support **light and dark** themes and the system setting from day one. Define colours by *role* (surface, on-surface, primary, error, outline, etc.) so both themes work without touching widgets.

**RULE UX-04 (SHOULD):** Never convey meaning by colour alone. Pair colour with an icon, label, shape, or pattern.

### 6.3 Layout and spacing

- **UX-10 (MUST):** Use a **4 dp base grid**, with **8 dp** as the primary rhythm. Allowed spacing values come from a fixed scale (e.g. 4, 8, 12, 16, 24, 32, 48). No arbitrary numbers.
- **UX-11 (MUST):** Screen edge padding is consistent (typically 16 dp on phones, larger on wide layouts) and inset-aware (system bars, display cutouts, gesture areas).
- **UX-12 (MUST):** **Touch targets ≥ 48 × 48 dp**, with at least 8 dp between adjacent targets. A small icon may have a small visual but must have a large hit area.
- **UX-13 (SHOULD):** Place primary actions within thumb reach (lower half of the screen) on phones. Destructive or rare actions should be harder to hit accidentally.
- **UX-14 (MUST):** Group related items; separate unrelated ones with spacing rather than dividers wherever possible. Proximity communicates relationship.
- **UX-15 (SHOULD):** Align to a consistent left edge; avoid ragged, unexplained offsets.
- **UX-16 (MUST):** Make content **scrollable** wherever it might overflow (font scale, landscape, split-screen, small phones). A layout that cannot scroll is a bug on some device.

### 6.4 Typography and text

- **UX-20 (MUST):** Use a small, fixed **type scale** of roles (display, headline, title, body, label) — not arbitrary sizes.
- **UX-21 (MUST):** Respect the user's **font scale**. Test at 100%, 130%, 150%, and 200%. Text must not clip, overlap, or become unreachable. Use flexible layouts (`Flexible`, `Expanded`, `Wrap`), never fixed heights around text.
- **UX-22 (MUST):** **Contrast** meets accessibility minimums: body text ≥ **4.5 : 1**, large text and essential UI components ≥ **3 : 1**, in both themes.
- **UX-23 (SHOULD):** Comfortable line length (roughly 40–75 characters on wide screens); constrain reading width on tablets.
- **UX-24 (MUST):** Use sentence case, plain language, and the user's vocabulary. Avoid jargon, internal terms, and error codes as primary messages.
- **UX-25 (MUST):** Truncate deliberately: define max lines and an overflow policy per text role; never let text render outside its container.
- **UX-26 (MUST):** For complex scripts (Bengali, Arabic, Devanagari, Thai, etc.), bundle or verify a font with full glyph and conjunct/shaping coverage, test line height (these scripts need more vertical room), and never rely on a Latin-only font with fallback surprises.

### 6.5 Adaptive layout (phones → foldables → tablets → desktop windowing)

Because API 36 ignores orientation and resizability locks on large screens, **every app is now a tablet app**.

**RULE UX-30 (MUST):** Drive layout by **window size class**, not device type or orientation:

| Class | Width | Typical structure |
|---|---|---|
| Compact | < 600 dp | Single pane; bottom navigation |
| Medium | 600–839 dp | Single or two-pane; navigation rail |
| Expanded | ≥ 840 dp | Multi-pane (list + detail); navigation rail/drawer |

- **UX-31 (MUST):** Use `LayoutBuilder` / `MediaQuery.sizeOf` (not `MediaQuery.of` for size only, to avoid unnecessary rebuilds) and split layouts by width breakpoints.
- **UX-32 (MUST):** Keep UI state across configuration changes: rotation, fold/unfold, split-screen, window resize, language change, dark-mode toggle, and font-scale change.
- **UX-33 (SHOULD):** In expanded windows, use list–detail rather than stretching a phone layout; cap the content width of text and forms.
- **UX-34 (MUST):** Support **landscape**, **multi-window**, **freeform windows**, and keyboard/mouse input (focus order, hover states, keyboard shortcuts for primary actions).
- **UX-35 (SHOULD):** Support drag-resize without jank; avoid caching size-dependent values at startup.

### 6.6 Edge-to-edge, system bars, and keyboard

- **UX-40 (MUST):** Draw edge-to-edge; scrolling content may pass behind transparent system bars, but **interactive controls must never sit under** a system bar, cutout, or gesture area.
- **UX-41 (MUST):** Handle the **IME (keyboard)**: the focused field must remain visible; primary submit buttons must be reachable with the keyboard open; use `resizeToAvoidBottomInset` deliberately.
- **UX-42 (SHOULD):** Set text-input types correctly (email, number, phone, password) plus `autofillHints`, `textInputAction`, and `autocorrect` policy so the keyboard helps instead of hindering.
- **UX-43 (MUST):** Keep system-bar icon legibility correct in both themes (the bar icon style must follow the theme).

### 6.7 Navigation and back behaviour

- **UX-50 (MUST):** Use a clear navigation model: **3–5 top-level destinations** in bottom navigation (compact) or rail (medium+). More than five → restructure, use a drawer for secondary areas, or use search.
- **UX-51 (MUST):** The **system back gesture/button** always does the expected thing: closes overlays first, then navigates up the stack, and exits only from the root. Use `PopScope` to intercept when unsaved changes exist and ask for confirmation.
- **UX-52 (MUST):** **Up ≠ Back** conceptually, but on Android within an app they should be predictable. Never trap the user in a screen with no exit.
- **UX-53 (SHOULD):** Preserve **navigation state** per tab (each tab keeps its own stack and scroll position).
- **UX-54 (MUST):** Every screen has a clear title or context indicator so the user always knows where they are.
- **UX-55 (SHOULD):** Support **predictive back** animation; do not fight it with custom transitions that ignore the gesture.
- **UX-56 (MUST):** Deep-linked screens must be reachable *and* exitable: back should go to a sensible parent, not close the app unexpectedly.

### 6.8 Screen states (every data screen must design all six)

| State | Required behaviour |
|---|---|
| **Loading (first)** | Skeleton/placeholder that matches final layout; no blank screens; no spinner-only screen longer than about a second without context |
| **Loading (refresh)** | Keep existing content visible; show light-weight progress; support pull-to-refresh where content is refreshable |
| **Empty** | Explain *why* it's empty and offer the next action |
| **Error** | Plain-language cause, what the user can do, and a **Retry** action; never a raw exception |
| **Offline** | Show cached content when possible; label it as such; queue user actions where sensible; auto-recover when back online |
| **Success / content** | Actual content; confirm completed actions (inline feedback, snackbar with undo) |

**UX-60 (MUST):** No screen ends in an unhandled state. Review every screen against this table before release.

### 6.9 Components and interaction

- **UX-70 (MUST):** Buttons: clear hierarchy (one primary, others secondary/tertiary); labels are **verbs** ("Save address", not "OK"); disabled states explain *why* (helper text) when non-obvious.
- **UX-71 (MUST):** Show **immediate feedback** (ripple/pressed state) for every tappable element; prevent **double submission** (disable or debounce while a request is in flight).
- **UX-72 (MUST):** Forms: label every field (persistent label, not placeholder-only); validate **inline, after the user leaves the field** (and on submit), with specific messages ("Password must be at least 8 characters"); preserve input on error; show one clear submit action; support autofill and password managers.
- **UX-73 (SHOULD):** Ask for the minimum. Split long forms into steps with progress; save drafts.
- **UX-74 (MUST):** **Dialogs** are for decisions that block progress, with a specific title, plain body, and action labels that restate the outcome ("Delete draft" / "Keep draft"). Do not use dialogs for information that can be inline.
- **UX-75 (SHOULD):** Use **bottom sheets** for contextual choices and secondary tasks; make them dismissible by drag, tap-outside, and back.
- **UX-76 (SHOULD):** **Snackbars** are transient confirmations (with Undo when reversible); never for critical errors that need action.
- **UX-77 (MUST):** **Destructive actions** require confirmation *or* offer Undo (Undo is better). Irreversible + high-stakes actions require explicit confirmation naming what will be lost.
- **UX-78 (MUST):** **Lists**: consistent item structure; show enough info to decide; support swipe gestures only as a *shortcut* to actions that also exist visibly; use `ListView.builder` for long lists.
- **UX-79 (SHOULD):** Prefer **native-feeling controls** (date/time pickers, sharing sheet, photo picker) over custom re-implementations.
- **UX-80 (MUST):** Icons always accompanied by a text label unless universally understood (search, close, back); provide tooltips/semantic labels for icon-only controls.

### 6.10 Onboarding, permissions, and sign-in

- **UX-90 (MUST):** Let users experience value **before** requiring sign-in whenever possible. Sign-in should appear when the feature truly needs it.
- **UX-91 (SHOULD):** Onboarding, if used, is ≤ 3 short screens, skippable, and never blocks the core action.
- **UX-92 (MUST):** **Permission requests are contextual**: ask when the user taps the feature that needs it, with a one-sentence *why* shown before the system dialog (a "pre-prompt"). Never request at launch.
- **UX-93 (MUST):** Handle **denial** and **"don't ask again"**: the feature degrades gracefully and offers a route to system settings; never nag repeatedly.
- **UX-94 (MUST):** Offer **social/password-manager/passkey** sign-in; support autofill; allow "show password"; do not force email verification before showing value.
- **UX-95 (MUST):** Provide **sign-out** and **account deletion** inside the app (Play policy requirement when accounts can be created).

### 6.11 Motion and haptics

- **UX-100 (MUST):** Motion communicates *cause and effect* (where something came from/went), never decoration alone.
- **UX-101 (SHOULD):** Durations: micro-interactions ~100–200 ms; transitions ~200–350 ms; nothing that blocks input. Use standard easing curves consistently.
- **UX-102 (MUST):** Honour the system **"Remove animations" / reduce-motion** setting (`MediaQuery.disableAnimations`): replace large motion with a simple fade or none.
- **UX-103 (SHOULD):** Use haptics sparingly for confirmations (toggle, long-press, success); never for every tap.

### 6.12 Accessibility (a release blocker, not a nice-to-have)

- **UX-110 (MUST):** Every interactive element has a **semantic label**, role, and state (`Semantics`, `tooltip`, `semanticLabel`); decorative images are excluded from semantics.
- **UX-111 (MUST):** Logical **focus / reading order** for TalkBack, Switch Access, and keyboard; no focus traps; visible focus indicators.
- **UX-112 (MUST):** Test with **TalkBack** on a real device for every core flow.
- **UX-113 (MUST):** Touch targets and contrast per UX-12 and UX-22; support **bold text**, **display size**, **font scale**, **high-contrast text**, and **colour correction** settings.
- **UX-114 (SHOULD):** Announce dynamic changes (errors, loading completion) via live regions / semantics announcements.
- **UX-115 (MUST):** No time-limited interactions without extension; no flashing content faster than 3 flashes per second.
- **UX-116 (SHOULD):** Provide text alternatives for charts and media; captions for video.
- **UX-117 (MUST):** Run Flutter's accessibility checks in widget tests (`meetsGuideline(androidTapTargetGuideline)`, `labeledTapTargetGuideline`, `textContrastGuideline`).

### 6.13 Content, microcopy, and localization

- **UX-120 (MUST):** All user-facing strings come from ARB/localization files. No concatenated sentences — use ICU placeholders/plurals/gender select.
- **UX-121 (MUST):** Support **RTL** (`Directionality`, `EdgeInsetsDirectional`, `AlignmentDirectional`, mirrored icons where meaning depends on direction) if you ship or may ship RTL languages.
- **UX-122 (MUST):** Format dates, times, numbers, currencies, and units with `intl` per locale; test locale-specific digits (e.g. Bengali digits) and long translations (German-length strings).
- **UX-123 (SHOULD):** Error text formula: **what happened → why (if helpful) → what to do next**. Never blame the user.
- **UX-124 (SHOULD):** Empty-state and success messages are short, specific, and human; avoid exclamation-mark inflation.
- **UX-125 (MUST):** Time-sensitive data shows absolute time somewhere (relative time such as "5 min ago" alone is ambiguous over long periods).

### 6.14 Media, imagery, and iconography

- **UX-130 (MUST):** Every image has a defined aspect ratio and placeholder to avoid layout shift; failed loads show a fallback.
- **UX-131 (SHOULD):** Use vector icons (icon font or SVG) at consistent sizes and optical weights; one icon family across the app.
- **UX-132 (SHOULD):** Store rasters as **WebP** (or AVIF where supported) at needed resolutions only; never ship original camera-size assets.

### 6.15 Trust, privacy, and dark patterns

- **UX-140 (MUST):** **No dark patterns.** No hidden costs, confirmshaming, disguised ads, fake countdowns, forced continuity without clear cancel, or pre-checked consent boxes.
- **UX-141 (MUST):** Explain *why* data is needed at the moment it is requested; link the privacy policy from onboarding/settings.
- **UX-142 (MUST):** Ads (if any) are clearly labelled, never disguised as UI, never placed where accidental taps are likely (near primary buttons, during transitions).
- **UX-143 (MUST):** Subscription screens show price, billing period, trial end date, and how to cancel *before* the purchase button.

### 6.16 UX review checklist (run before every release)

- [ ] Every screen has loading / empty / error / offline / success states
- [ ] All targets ≥ 48 dp; contrast passes in light **and** dark
- [ ] Works at 200 % font scale without clipping
- [ ] Works in landscape, split-screen, tablet width, and after fold/unfold
- [ ] Edge-to-edge: no control under a system bar, cutout, or IME
- [ ] Back gesture/button behaves correctly on every screen and overlay
- [ ] TalkBack walkthrough of the core flow succeeds
- [ ] Reduce-motion respected; no blocking animations
- [ ] Permission prompts are contextual; denial is handled
- [ ] All strings localized; plurals/formatting correct; RTL checked (if applicable)
- [ ] Destructive actions confirmed or undoable; double-submits prevented
- [ ] No dark patterns; ads and subscriptions transparent

---

## 7. Performance Optimization for Android

### 7.1 Performance budgets (define them, then enforce them)

| Metric | Target (guidance) |
|---|---|
| **Cold start to first meaningful frame** | ≤ ~2 s on a low-end device (measure, don't guess) |
| **Frame time** | ≤ 16 ms build + raster on 60 Hz; ≤ 8 ms on 120 Hz devices. Aim for **zero dropped frames in core flows** |
| **Memory** | No unbounded growth in a 10-minute soak; stay well below low-memory-killer thresholds for 2–3 GB devices |
| **Download size (AAB → device)** | As small as practical; set a budget per release and fail CI when exceeded |
| **Crash-free users / ANR** | Stay far below Play's *bad behaviour* thresholds (see §13.1) |
| **Battery** | No background wake-ups you can't justify; no sustained CPU at idle |

**RULE P-01 (MUST):** Profile in **profile mode on a physical mid/low-end device**, never in debug mode and never on an emulator, for any performance decision.

```bash
flutter run --profile                     # then open DevTools → Performance / CPU / Memory
flutter build apk --analyze-size --target-platform android-arm64   # size breakdown
```

### 7.2 Rendering pipeline (Impeller on Android)

- Impeller is Flutter's modern renderer on Android (Vulkan where available, with a fallback for devices without Vulkan). It precompiles shaders at build time, which removes the classic first-run shader-compilation jank.
- **SHOULD** stay on the default renderer. If you see rendering artefacts on a specific device, capture the device model and Flutter version and file a Flutter issue rather than disabling Impeller globally.
- **MUST** test on a range of GPUs (Adreno, Mali, PowerVR/other) because driver differences show up as visual bugs, not crashes.

### 7.3 Startup optimization

1. **Minimize work before `runApp`.** Only initialize what the first screen strictly needs. Defer everything else (analytics, remote config, ad SDKs, cache warming) until after the first frame (`WidgetsBinding.instance.addPostFrameCallback` or a startup coordinator).
2. **Parallelize** independent initializations with `Future.wait`.
3. **Lazy-init** heavy services (DB, image cache, ML models) on first use.
4. **Avoid synchronous disk/JSON work** on the UI isolate at launch.
5. Keep the **splash static**; show real content skeletons ASAP rather than a long splash.
6. **Cache the last known state** so users see content immediately while fresh data loads.
7. Audit plugins: each native plugin can add startup cost (initializers in `Application.onCreate`, ContentProviders). Remove unused ones; prefer plugins that initialize lazily.
8. Measure with `flutter run --profile --trace-startup` and Android's `adb shell am start -W`.

### 7.4 Rendering and rebuild efficiency

- **P-10 (MUST):** Use `const` constructors everywhere possible.
- **P-11 (MUST):** **Scope rebuilds**: split large widgets; use fine-grained state selectors (`select`, `BlocSelector`, `ValueListenableBuilder`, `Selector`) so a small change doesn't rebuild the screen.
- **P-12 (MUST):** Use `ListView.builder` / `SliverList` / `GridView.builder` for any list beyond a handful of items; give items stable `Key`s; provide `itemExtent`/`prototypeItem` when heights are uniform.
- **P-13 (SHOULD):** Add `RepaintBoundary` around independently animating regions (not everywhere — measure first).
- **P-14 (AVOID):** `Opacity`, `ClipRRect`, `BackdropFilter`, `ShaderMask`, and large `saveLayer` operations inside scrolling lists and animations. Prefer `AnimatedOpacity`/`FadeTransition`, pre-clipped assets, and cheaper alternatives.
- **P-15 (AVOID):** Doing work in `build()` — no parsing, sorting, network, or allocation-heavy operations. Precompute in state.
- **P-16 (SHOULD):** Use `AnimatedBuilder` / `TweenAnimationBuilder` with a `child` parameter so static subtrees are not rebuilt each frame.
- **P-17 (SHOULD):** Avoid `IntrinsicHeight` / `IntrinsicWidth` and deep nested `Column`/`Row` with `shrinkWrap: true` scrollables inside other scrollables (causes O(n²) layout).
- **P-18 (SHOULD):** Turn on **`debugProfileBuildsEnabled`** and the DevTools **Rebuild stats** while profiling to catch hot widgets.

### 7.5 Work off the UI isolate

- **P-20 (MUST):** Any CPU-heavy task (large JSON decode, image processing, encryption, sorting big collections, file compression) runs in `Isolate.run` / `compute` or a long-lived worker isolate.
- **P-21 (SHOULD):** Prefer streaming/paged parsing for large payloads; don't decode 5 MB JSON on the main isolate.
- **P-22 (MUST):** Never block the platform (main) thread in native plugin code; this causes ANRs.
- **P-23 (SHOULD):** Cancel obsolete work (debounce search input, cancel in-flight requests when the user navigates away).

### 7.6 Images and media

- **P-30 (MUST):** Decode images at the display size: use `cacheWidth` / `cacheHeight` (or `ResizeImage`) for network and asset images; never decode a 4000 px photo for a 100 dp thumbnail.
- **P-31 (MUST):** Use a caching image library for network images with memory + disk cache, placeholder, and error widget. Set sensible cache size limits.
- **P-32 (SHOULD):** Ask the server for appropriately sized images (responsive image URLs / CDN transforms) and modern formats.
- **P-33 (SHOULD):** Precache critical above-the-fold images; lazy-load the rest.
- **P-34 (SHOULD):** For video, use a maintained player plugin with hardware decoding; release controllers in `dispose`.
- **P-35 (SHOULD):** Set `imageCache.maximumSizeBytes` deliberately for image-heavy apps; clear it in `didHaveMemoryPressure`.

### 7.7 Memory and leak prevention

- **P-40 (MUST):** Dispose controllers (`TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`, `StreamSubscription`, `Timer`, platform channels/listeners) in `dispose`.
- **P-41 (MUST):** Avoid capturing `BuildContext` in long-lived closures; check `mounted` after `await`.
- **P-42 (SHOULD):** Use DevTools **Memory** to take snapshots before/after navigating a flow 10 times; leaked route/screen instances mean a leak.
- **P-43 (SHOULD):** Bound all in-memory caches (LRU with size limits). "Unbounded map as cache" is a bug.
- **P-44 (MUST):** Handle **process death**: Android can kill your app in the background. Persist critical state (drafts, in-progress forms, session) and restore it.

### 7.8 Network and data efficiency

- **P-50 (MUST):** Enable HTTP compression, HTTP/2 (default with modern stacks), and timeouts (connect, receive, total).
- **P-51 (MUST):** **Paginate** every list endpoint; never fetch unbounded collections.
- **P-52 (SHOULD):** Cache with ETag / `Cache-Control`; use a repository pattern that serves **cache-first, then network** (stale-while-revalidate) for read-heavy screens.
- **P-53 (MUST):** Retry idempotent requests with exponential backoff + jitter and a maximum; never retry non-idempotent writes blindly (use idempotency keys).
- **P-54 (SHOULD):** Batch analytics events; flush on lifecycle change, not per event.
- **P-55 (SHOULD):** Respect metered connections and data-saver modes when downloading large media.
- **P-56 (SHOULD):** Prefer **WebSocket/FCM push** over polling.

### 7.9 Battery and background work

- **P-60 (MUST):** Use **WorkManager** (via a maintained plugin) for deferrable/guaranteed background work. Avoid long-running foreground services unless they are a true user-visible task (music, navigation, active recording) with the correct declared type.
- **P-61 (MUST):** No wake locks held longer than needed; no exact alarms unless the app's core function requires them.
- **P-62 (SHOULD):** Stop location updates, sensors, animations, and timers when the app or screen is not visible (`AppLifecycleState`, `WidgetsBindingObserver`).
- **P-63 (SHOULD):** Choose the lowest sufficient location accuracy and update interval.

### 7.10 App size reduction (AAB → smaller downloads)

| Technique | How |
|---|---|
| **Ship an AAB** | Play generates per-device split APKs (ABI, density, language) automatically |
| **R8 shrinking + resource shrinking** | Enabled for release; verify with `--analyze-size` |
| **Split debug info + obfuscation** | `--obfuscate --split-debug-info=build/symbols` reduces Dart symbol size and hides names |
| **Tree-shake icons** | Default on in release; avoid loading full icon fonts dynamically |
| **Remove unused dependencies** | Every plugin adds Dart, Java/Kotlin, and possibly native `.so` code |
| **Subset fonts / limit weights** | Bundle only the weights and scripts you use |
| **Optimize assets** | WebP/AVIF images, compressed audio/video, remove unused assets, avoid duplicate resolutions |
| **Restrict languages** | Only include locales you actually support |
| **Deferred components / Play Feature Delivery / Asset Delivery** | Move rarely used or heavy modules and large assets out of the base download |
| **Watch native libraries** | Large `.so` files (ML, media, maps) dominate size; check for duplicates across plugins |

**RULE P-70 (MUST):** Set a **size budget** and record `--analyze-size` output per release. Fail CI on a regression beyond a set threshold.

### 7.11 16 KB page-size compatibility (performance *and* policy)

- **MUST** rebuild with a current Flutter, AGP, and NDK so native code is 16 KB-aligned.
- **MUST** audit every plugin that ships `.so` files. Check Play Console → **App Bundle Explorer → Memory page size**; a "does not support 16 KB" note lists offending libraries.
- **MUST** test on a **16 KB page-size emulator image** or device (`adb shell getconf PAGE_SIZE` returns `16384`).
- **Fix order:** upgrade plugin → replace plugin → ask the maintainer → fork and rebuild (last resort).
- **AVOID** hard-coding `4096` anywhere in native code; query the OS page size.

### 7.12 Performance testing cadence

- Per PR: analyzer + unit/widget tests + size check.
- Nightly: integration tests on device farm; startup and scroll benchmarks recorded as time series.
- Per release candidate: 15-minute manual soak on a low-end device (memory graph, jank, battery drain, thermal behaviour).
- Post-release: watch Android vitals for startup time, slow frames, frozen frames, ANRs, excessive wakeups, and crash clusters by device/OS.

---

## 8. Security and Privacy

### 8.1 Threat-model baseline

Assume: the APK/AAB will be decompiled; the device may be rooted; the network may be hostile; the user's phone may be lost; every third-party SDK is a data-exfiltration path. Design so a compromised client cannot compromise the backend or other users.

### 8.2 Secrets and keys

- **S-01 (MUST):** No secrets in the client. API keys that identify the app (maps, analytics) are *restricted* keys (bound to package name + signing certificate SHA-256, API-scoped) — restriction is your protection, not obscurity.
- **S-02 (MUST):** Real secrets (payment, admin, third-party server tokens) live only on your backend.
- **S-03 (MUST):** Pass build-time config with `--dart-define-from-file` from CI secrets; never commit `.env` files with real values.
- **S-04 (MUST):** Rotate any key that has ever been committed, even briefly.

### 8.3 Authentication and sessions

- **S-10 (MUST):** Use standard protocols: OAuth 2.0 / OIDC with **PKCE**; never roll your own crypto or token format.
- **S-11 (SHOULD):** Prefer **Credential Manager / passkeys** and system autofill for sign-in.
- **S-12 (MUST):** Store tokens in **Android Keystore-backed secure storage**, not `shared_preferences`.
- **S-13 (MUST):** Short-lived access tokens + refresh-token rotation; server-side revocation; logout clears all local secrets and caches.
- **S-14 (SHOULD):** Gate sensitive actions with **BiometricPrompt** (via a maintained plugin) using `BIOMETRIC_STRONG`, and fall back to device credentials.

### 8.4 Network security

- **S-20 (MUST):** HTTPS only; `usesCleartextTraffic="false"`; a `network_security_config.xml` that allows user-installed CAs only in debug builds.
- **S-21 (SHOULD):** Certificate pinning only if your threat model requires it *and* you have a rotation plan (backup pins, expiry monitoring). A bad pin can brick your app for every user.
- **S-22 (MUST):** Validate all server responses; treat data as untrusted (schema validation, size limits).
- **S-23 (MUST):** Never log tokens, passwords, full request bodies, or PII, even in debug builds that might leak into bug reports.

### 8.5 Local data and platform hardening

- **S-30 (MUST):** Encrypt sensitive local databases (e.g. encrypted SQLite) with a key stored in Keystore.
- **S-31 (MUST):** Control backups (see §5.3): exclude tokens, PII databases, and caches.
- **S-32 (MUST):** Export only what you must: `android:exported="false"` by default; protect exported components with permissions; validate incoming intents.
- **S-33 (MUST):** Use `FLAG_SECURE` (via a plugin) on screens showing sensitive data (banking, health, IDs) to block screenshots/recents thumbnails when appropriate.
- **S-34 (SHOULD):** Clipboard: don't auto-copy sensitive data; clear sensitive clipboard entries after a short timeout.
- **S-35 (MUST):** WebViews: disable JavaScript unless needed, disable file access, restrict navigation to an allow-list, never load untrusted content with a JS bridge.

### 8.6 Integrity and abuse resistance

- **S-40 (SHOULD):** Use the **Play Integrity API** for high-risk actions (account creation, payments, promo abuse), verified **server-side**. Treat the verdict as a risk signal, not an absolute gate.
- **S-41 (SHOULD):** Obfuscate release builds (`--obfuscate`) and keep R8 on. It raises effort but does not prevent reverse engineering.
- **S-42 (SHOULD):** Rate-limit and monitor server APIs; the server is the real security boundary.
- **S-43 (AVOID):** Home-grown root/jailbreak detection as a security control. It is easily bypassed and causes false positives.

### 8.7 Supply-chain security

- **S-50 (MUST):** Commit lockfiles; review dependency diffs on upgrades; run `dart pub outdated` and `flutter pub deps` regularly.
- **S-51 (MUST):** Audit every native/Kotlin/Java SDK for data collection and permissions (they show up in your Data safety obligations).
- **S-52 (SHOULD):** Prefer few, well-maintained dependencies. Every package is code you ship and are responsible for.
- **S-53 (SHOULD):** Enable automated dependency alerts and vulnerability scanning in the repository.

### 8.8 Privacy engineering

- **S-60 (MUST):** **Data minimization** — collect only what a feature needs; set retention limits; delete on account deletion.
- **S-61 (MUST):** Your privacy policy (public, working URL, in-app link) **exactly matches** what the app and its SDKs do.
- **S-62 (MUST):** Obtain and record consent where laws require (GDPR/UK, other regional regimes); make analytics/ads consent revocable.
- **S-63 (MUST):** Provide **in-app account and data deletion** plus a public web deletion request path if accounts exist.
- **S-64 (MUST):** For child-directed or mixed-audience apps: no behavioural ads, only certified ad SDKs, no unnecessary identifiers.

---

## 9. Testing and Quality Gates

### 9.1 Test pyramid

| Layer | Tool | Scope | Target |
|---|---|---|---|
| **Unit** | `flutter_test` / `test` | Domain logic, mappers, reducers, repositories with fakes | Fast, deterministic, high coverage of core logic |
| **Widget** | `flutter_test` | Screens/components with fake dependencies; state matrix (§6.8); accessibility guidelines | Every screen's key states |
| **Golden** | `matchesGoldenFile` (or a golden toolkit) | Design-system components across text scales, themes, locales | Prevents visual regressions |
| **Integration / E2E** | `integration_test` (or a device-driven tool) | Critical journeys on real devices/emulators | Sign-in, core loop, purchase, delete account |
| **Manual exploratory** | Humans | Real-world behaviour, gestures, interruptions | Every release candidate |

**RULE T-01 (MUST):** Test behaviour, not implementation. Mock only at boundaries (network, storage, platform).

**RULE T-02 (MUST):** Every bug fix ships with a regression test.

**RULE T-03 (SHOULD):** Define a coverage floor for `domain/` (high) and don't chase 100% on presentation code.

### 9.2 Device and OS matrix

Minimum matrix for every release candidate:

- Android **16** (target), Android **15**, Android **14**, and the **oldest** OS at your `minSdk`.
- A **low-end** phone (2–3 GB RAM), a **mid-range** phone, a **flagship**, a **tablet**, and a **foldable** (or resizable emulator).
- A **16 KB page-size** device/emulator.
- Different OEM skins (Samsung, Xiaomi/HyperOS, Oppo/Vivo, Pixel) — aggressive battery managers and custom permission UIs behave differently.
- Use **Firebase Test Lab** (or another device farm) for breadth; use physical devices for feel and performance.

### 9.3 Scenario testing (things that break real apps)

- Airplane mode mid-request; flaky network (throttle); server 5xx; server timeout.
- App killed in background → relaunch (state restoration).
- Rotate, fold/unfold, split-screen, window resize.
- Font scale 200 %, display size max, dark mode, bold text, reduce-motion, TalkBack.
- Locale changes (RTL, complex scripts, long strings), 24-hour vs 12-hour clock, different number systems.
- Permission denied, "don't ask again", revoked while running.
- Low storage, low memory, battery saver, data saver.
- Time-zone change, clock skew, DST.
- Upgrade from the previous version with existing local data (migration tests).
- Deep link cold-start and warm-start.
- Interruptions: incoming call, notification shade, another app taking focus.

### 9.4 CI pipeline (minimum viable)

1. Checkout → set up pinned Java + Flutter.
2. `flutter pub get` (fail if lockfile would change).
3. `dart format --set-exit-if-changed .`
4. `flutter analyze --fatal-infos`
5. `flutter test --coverage`
6. Build `flutter build appbundle --release` for each flavor (with `--dart-define-from-file`).
7. Size check (compare with baseline) and native-library alignment check.
8. Upload artifacts (AAB, symbols, mapping files).
9. Optional: run integration tests on a device farm.
10. On tag: sign and publish to the **internal testing** track via a Play publishing tool/API (service account with least privilege).

### 9.5 Pre-launch validation inside Google Play

- Play Console's **pre-launch report** runs your build on real devices and reports crashes, ANRs, accessibility issues, security warnings, and screenshots. **Fix everything in it before applying for production.**
- Unresolved crashes and ANRs seen during testing can reduce your chance of production approval.

### 9.6 Observability from day one

- **MUST** integrate crash + non-fatal error reporting, with **symbol upload** for obfuscated Dart and native crashes.
- **SHOULD** add lightweight analytics for funnel steps (with consent), performance traces (startup, key screens), and remote config/feature flags for safe rollouts and kill-switches.
- **MUST** define alerts: crash-free users drop, ANR spike, error-rate spike on key API calls.

---

## 10. Build, Signing, and Versioning

### 10.1 Signing model (Play App Signing)

- New apps use **Play App Signing**: Google holds the *app signing key*; you sign uploads with an **upload key**.
- **MUST** generate the upload keystore **once**, back it up in at least two secure places (password manager + offline encrypted storage), and record alias/passwords in a secrets manager.
- **MUST NOT** commit the keystore or `key.properties`.
- If the upload key is lost or compromised, you can request an upload-key reset in Play Console; this takes time, so protect it.

```bash
keytool -genkeypair -v -keystore ~/upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` (git-ignored):

```properties
storePassword=<from secrets manager>
keyPassword=<from secrets manager>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

### 10.2 Gradle signing configuration (Kotlin DSL example)

> Your generated template may differ depending on the Flutter version and whether you have migrated to AGP 9 built-in Kotlin. Adapt the *structure*, keep the *intent*.

```kotlin
// android/app/build.gradle.kts
import java.io.FileInputStream
import java.util.Properties

val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.yourcompany.yourapp"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.yourcompany.yourapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            ndk { debugSymbolLevel = "FULL" }   // native crash symbolication in Play Console
        }
    }
}
```

**RULE B-01 (MUST):** The release build **must never** fall back to the debug signing config. Fail the build if signing properties are missing.

### 10.3 Versioning

- In `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD` (e.g. `1.4.2+37`). `versionName` = `1.4.2`, `versionCode` = `37`.
- **MUST:** `versionCode` strictly increases with every upload to Play (across all tracks). Let CI set it (build number, run number, or date-based scheme).
- **SHOULD:** Follow semantic versioning for `versionName`; tag every release in Git.
- **MUST:** Keep a `CHANGELOG.md`; generate release notes from it.

### 10.4 Production build command

```bash
flutter clean
flutter pub get
flutter build appbundle --release \
  --flavor prod \
  --dart-define-from-file=env/prod.json \
  --obfuscate \
  --split-debug-info=build/symbols \
  --build-name=1.0.0 \
  --build-number=1
```

Outputs:

- AAB → `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
- Dart symbols → `build/symbols/` (**archive per version; needed to de-obfuscate crashes**)
- R8 mapping → `build/app/outputs/mapping/prodRelease/mapping.txt` (**upload to Play Console / crash reporter**)

**RULE B-02 (MUST):** Archive AAB + `build/symbols` + `mapping.txt` + native symbols for **every** release you ship. Without them, production crashes are unreadable.

### 10.5 Verify the *release* build before uploading

The debug build proves nothing about release behaviour (R8, obfuscation, signing, flavors, permissions).

- [ ] Install the release build on a physical device (use `bundletool` to build device-specific APKs from the AAB, or `flutter build apk --release` for a quick check).
- [ ] Exercise every core flow, including login, purchase (test tracks), deep links, notifications, and deletion.
- [ ] Confirm no debug banners, test endpoints, verbose logs, or debug menus.
- [ ] Inspect merged manifest, permissions list, and native libraries (16 KB alignment).
- [ ] Verify the app targets API 36+ and the expected `versionCode`.
- [ ] Run the `--analyze-size` report and compare to budget.

```bash
# Build a universal APK set from the AAB for local testing
bundletool build-apks --bundle=app.aab --output=app.apks --mode=universal \
  --ks=~/upload-keystore.jks --ks-key-alias=upload
bundletool install-apks --apks=app.apks
```

### 10.6 R8 / ProGuard rules

- Flutter's release builds shrink with R8; most Flutter apps need no custom rules.
- **MUST** add keep rules for any library that uses reflection, JNI callbacks, or serialization by name (the library's docs will say).
- **MUST** test the release build; an R8 stripping bug appears *only* in release.

---

## 11. Play Console: Store Listing and App Content Declarations

### 11.1 Create the app

- Choose the default language, app or game, free or paid (**permanent**), and accept the declarations.
- Set up the **application ID** by uploading the first AAB.

### 11.2 Main store listing (quality rules)

| Field | Guidance (verify current limits in the Console) |
|---|---|
| **App name** | Up to 30 characters. No emojis, no price/ranking claims ("#1", "best"), no misleading keywords, no all-caps (unless a brand) |
| **Short description** | Up to 80 characters; the first thing users read; state the core benefit |
| **Full description** | Up to 4,000 characters; natural language; no keyword stuffing, no fake reviews/testimonials, no unrelated app promotion |
| **App icon** | 512 × 512 px, 32-bit PNG; must not include rankings, badges, or misleading elements |
| **Feature graphic** | 1024 × 500 px; no text-heavy or misleading content; safe area respected |
| **Phone screenshots** | At least 2 required (more, e.g. 4–8, recommended); JPEG or 24-bit PNG; show the *real* app UI |
| **Tablet screenshots** | Provide 7-inch and 10-inch screenshots to be eligible for large-screen features |
| **Video** | Optional YouTube link; not age-restricted, no ads |
| **Category / tags** | Choose the closest accurate category; tags describe features honestly |
| **Contact details** | Support email required; website and phone optional but improve trust |
| **Localization** | Translate listing text and screenshots for each supported language |

**RULE L-01 (MUST):** Everything in the listing must be **true and current**. Screenshots that show features that don't exist, or descriptions that imply endorsements, cause rejection or suspension.

**RULE L-02 (SHOULD):** Use **custom store listings** and **store listing experiments** after launch to improve conversion.

### 11.3 Privacy policy (mandatory)

- Public, working HTTPS URL (not geo-restricted, not behind a login, not an editable document), in the app's language(s).
- Names the developer/entity, describes data collected, purposes, third-party recipients, retention, security measures, user rights, contact method, and how to delete data.
- **MUST** be linked in the Play listing *and* inside the app.

### 11.4 App content declarations (Policy → App content)

Complete **every** section; incomplete declarations block release.

| Declaration | Notes |
|---|---|
| **Privacy policy** | URL as above |
| **App access** | If any part needs login, provide **working reviewer credentials** and instructions; keep them valid during the entire review |
| **Ads** | Declare whether the app contains ads |
| **Content rating** | Complete the IARC questionnaire honestly; a mismatch leads to removal |
| **Target audience and content** | Choose age groups; selecting children triggers the **Families Policy** |
| **Data safety** | Declare *all* data collected/shared (including by SDKs), purposes, encryption in transit, deletion options. Must match the privacy policy and actual behaviour |
| **Government apps / Financial features / Health apps / News apps** | Answer where applicable; provide required documents |
| **Advertising ID** | State whether you use it, and for what |
| **Account deletion** | Provide in-app path and a web URL |
| **Sensitive permissions and APIs** | Photo/video access, exact alarms, full-screen intents, foreground service types (with justification and sometimes a demo video), all-files access, accessibility service, VPN, SMS/call log, package visibility (`QUERY_ALL_PACKAGES`) — each needs a declaration and a genuine core-functionality justification |
| **User-generated content** | Describe moderation, reporting, and blocking |
| **Health Connect / health data** | Additional declarations if you use them |

**RULE L-10 (MUST):** Update the Data safety form **whenever** you add an SDK, a data field, or a new purpose. Data-safety mismatches are a leading cause of enforcement.

### 11.5 Monetization (if applicable)

- **Digital goods and services must use Google Play Billing** (with allowed regional exceptions for alternative billing programs — verify your markets).
- Use **Play Billing Library 8+** (newer major recommended); handle pending purchases, acknowledgements, restores, price changes, grace period, account hold, and refunds.
- Verify purchases **server-side** (Google Play Developer API + Real-time developer notifications).
- **MUST** disclose price, billing period, free-trial terms, and cancellation path before purchase.
- Set up the **merchant/payments profile** and tax information; test with **license testers** and test tracks before enabling real money.

### 11.6 Store presence rules to avoid

- Misleading claims, impersonation, or names resembling other brands/apps.
- Keyword stuffing, repetitive text, or unrelated words.
- User reviews or ratings inside the listing text.
- Non-original content, deceptive behaviour, hidden functionality, or "spam" minimal-functionality apps.
- Wrappers of websites with no added value (minimum functionality policy).

---

## 12. Release Tracks: Internal → Closed → Production

### 12.1 Track overview

| Track | Audience | Review | Purpose |
|---|---|---|---|
| **Internal testing** | Up to 100 testers you invite | Fast (minutes–hours) | Smoke tests, CI delivery, team QA |
| **Closed testing** | Invite-only groups (email lists / Google Groups) | Standard review | Real-user testing; the **12 testers × 14 days** requirement for new personal accounts |
| **Open testing** | Anyone can join via Play (available after production access) | Standard review | Public beta |
| **Production** | Everyone in selected countries | Full review | Public release |

### 12.2 Recommended release journey

1. **Internal test** every CI build (team + a few friendly users). Fix the pre-launch report issues.
2. **Closed test (start early!)** — as soon as the core loop works and is stable. If you have a new personal account, recruit **more than 12 real testers** (aim for 20+), get them to opt in and *keep the app installed and use it on several different days*. The 14-day clock only counts continuous opt-in.
3. During those 14+ days: collect feedback, ship at least one or two updates, fix crashes/ANRs, and improve store listing and content declarations.
4. **Apply for production access** (personal accounts): answer the questions about testing, feedback, and readiness truthfully and specifically. Describe what testers found and what you changed.
5. **Submit for production review** with a **staged rollout** (start small).
6. **Monitor**, expand rollout, iterate.

**RULE R-01 (MUST):** Do **not** fake testers, buy installs, or run tester "exchange" schemes that don't reflect real usage; low-quality testing can lead to a rejected production application or account action.

### 12.3 Preparing the release in Play Console

- [ ] Upload the signed AAB (Play checks signing, target API, page-size alignment, permissions, and policy).
- [ ] Resolve all **errors**; read all **warnings** (e.g. unsupported 16 KB libraries, deobfuscation file missing, high-risk permissions).
- [ ] Write **release notes** per language (what's new, human-readable).
- [ ] Choose **countries/regions** deliberately; some regions add legal or tax requirements.
- [ ] Review **device catalog** exclusions.
- [ ] Confirm every **App content** task shows complete.
- [ ] Confirm **Policy status** shows no open issues.
- [ ] Decide **managed publishing** (control the exact go-live moment after approval).

### 12.4 Staged rollout plan (example)

| Day | Rollout % | Gate to proceed |
|---|---|---|
| 0 | 5 % | No new crash clusters; ANR and crash rates within thresholds |
| 1–2 | 20 % | Key funnels normal; ratings/reviews not degrading |
| 3–4 | 50 % | Server load and costs acceptable |
| 5+ | 100 % | All gates green |

- **Halt the rollout** immediately on a severe regression, then ship a fixed build with a **higher `versionCode`** (you cannot roll back a version code).
- Keep a **kill-switch** (remote config) for risky new features.

### 12.5 Review timing and rejections

- Review can take from hours to several days; the first review for a new app or new account is usually the longest. Plan buffer time; never schedule marketing to a store-approval date.
- If rejected: read the exact policy cited, fix the root cause (not only the symptom), update declarations if relevant, then resubmit with a clear explanation. Repeated resubmission without fixes harms your standing.

### 12.6 Sensible launch timeline (new personal account, solo developer)

| Week | Focus |
|---|---|
| 0 | Create account, start identity verification, register app, decide application ID, data inventory, privacy policy draft |
| 1–4 | Build MVP core loop, CI, error reporting, accessibility, adaptive layouts |
| 5 | Internal testing; fix pre-launch report; finish store listing and content declarations |
| 6 | **Start closed test** with 20+ testers (14-day clock) |
| 6–8 | Iterate on feedback, ship updates, hit performance and stability targets |
| 8 | Apply for production access; submit production with staged rollout |
| 9+ | Monitor vitals, respond to reviews, plan the next quarterly release |

*(Organization accounts skip the 12-tester rule, so the closed-test phase can be shortened to whatever quality demands.)*

---

## 13. Post-Release Operations and the Yearly Treadmill

### 13.1 Android vitals — your quality scoreboard

Play Console → **Quality → Android vitals**. Google measures your app and can reduce its visibility when it exceeds "bad behaviour" thresholds.

| Metric | Guidance |
|---|---|
| **User-perceived crash rate** | Keep well below the overall bad-behaviour threshold (about 1.09 % of daily active users at the time of writing) and the per-device-model threshold (about 8 %) |
| **User-perceived ANR rate** | Keep well below about 0.47 % overall (and about 8 % per device model) |
| **Excessive wake-ups / stuck wake locks / background work** | Keep at or near zero |
| **Startup time, slow rendering, frozen frames** | Track trends per release; investigate regressions |

*(Thresholds are Google's and can change; confirm the current numbers in the Play Console Help "Android vitals" pages.)*

**RULE O-01 (MUST):** Review vitals **daily for the first week** after each release, then weekly. Treat any new crash cluster as an incident.

### 13.2 Incident response

1. **Detect** (crash reporter alert, vitals spike, user reviews).
2. **Contain** (halt staged rollout, flip a remote kill-switch, disable the failing server feature).
3. **Fix** (root-cause with de-obfuscated stack traces; write a regression test).
4. **Ship** (higher `versionCode`; expedite through internal → production).
5. **Learn** (short blameless postmortem; add a guard/test/alert).

### 13.3 Reviews, support, and community

- Respond to reviews within days; be specific and polite; reply again when you ship the fix.
- Provide an **in-app feedback path** with device/app info (opt-in) so users don't vent only in reviews.
- Monitor Play Console → **Ratings and reviews** → filter by version and device.

### 13.4 The yearly and quarterly treadmill

| Cadence | Task |
|---|---|
| **Every release** | Update dependencies you touch; run analyzer/tests; regression-test the core loop; verify size, 16 KB alignment, and permissions |
| **Monthly** | `dart pub outdated`; security advisories; Play Console **Policy status** and inbox emails; rotate anything expiring (certificates, API credentials) |
| **Quarterly (Feb / May / Aug / Nov)** | Evaluate the new Flutter stable (3.50 is planned for November 2026); read release notes and breaking changes; upgrade in a dedicated branch; plan for the Material/Cupertino standalone-package transition |
| **Every August** | New Android target-API requirement (expect the next one, Android 17 / API 37, around 31 Aug 2027 — confirm with Google's announcement); Billing Library minimum bump; read "Behavior changes: apps targeting Android N" |
| **Every year** | Re-audit Data safety, privacy policy, permissions, SDK inventory, licences, and store listing accuracy |
| **Watch list (2026–2027)** | Developer-verification expansion beyond the first four countries; any one-time-location requirement for Android 17 targets (verify against official Play policy); new restricted-permission declarations |

**RULE O-10 (MUST):** Subscribe to Play Console email notifications for the whole team; a missed policy email is the most common cause of surprise removals.

**RULE O-11 (SHOULD):** Never let the app fall more than one target-API generation behind. Apps that lag lose visibility to new users on newer Android versions and eventually cannot be updated.

### 13.5 Data lifecycle and end-of-life

- If you retire the app: give notice, provide data export, delete data on schedule, and unpublish only after users have had time to migrate.
- If you transfer the app: use Play Console's app transfer; keep signing keys and Data safety accurate.

---

## 14. Master Pre-Release Checklist

Copy this into your release ticket. **Every unchecked box is a blocker until explicitly waived.**

### 14.1 Account and compliance
- [ ] Play developer identity verified; app **registered** for developer verification
- [ ] Payments profile complete (if selling)
- [ ] Data inventory matches privacy policy **and** Data safety form
- [ ] Privacy policy URL public, HTTPS, linked in-app and on Play
- [ ] Content rating (IARC) completed honestly
- [ ] Target audience declared; Families Policy handled if children are included
- [ ] Ads declaration and Advertising ID declaration correct
- [ ] App access instructions + working reviewer credentials provided (if login exists)
- [ ] Account deletion available in-app and via web link (if accounts exist)
- [ ] All restricted-permission declarations completed or the permission removed
- [ ] User-generated-content safeguards in place (if applicable)

### 14.2 Technical
- [ ] `targetSdk` ≥ 36, `compileSdk` ≥ 36, `minSdk` justified
- [ ] Built on the current Flutter stable patch; toolchain warnings cleared (`flutter analyze --suggestions`)
- [ ] AGP 9 built-in Kotlin migration done, or a dated plan exists
- [ ] All native libraries 16 KB-aligned (verified in Play App Bundle Explorer + on a 16 KB device)
- [ ] Play Billing Library ≥ 8 (if using billing)
- [ ] Release build signed with the **upload key** (never debug); `versionCode` incremented
- [ ] Obfuscation on; **symbols, mapping.txt, and native symbols archived and uploaded**
- [ ] No cleartext traffic; no secrets in code; no debug flags, logs, or test endpoints
- [ ] Merged manifest reviewed: every permission and exported component justified
- [ ] Analyzer, formatter, unit, widget, golden, and integration suites green in CI
- [ ] Release build tested on real devices (low-end, mid-range, tablet/foldable, Android 16)
- [ ] Size within budget; startup and frame-time within budget on a low-end device

### 14.3 UX and accessibility
- [ ] §6.16 UX review checklist fully passed
- [ ] TalkBack walkthrough of every core flow
- [ ] 200 % font scale, dark mode, RTL/complex scripts (if applicable) verified
- [ ] Adaptive layouts verified for compact / medium / expanded windows
- [ ] Back gesture/button correct on every screen; predictive back verified

### 14.4 Store and release
- [ ] Listing text, icon, feature graphic, phone **and** tablet screenshots complete and truthful
- [ ] Localized listing for each supported language
- [ ] Release notes written
- [ ] Pre-launch report reviewed; crashes/ANRs fixed
- [ ] Closed test requirement satisfied (personal accounts): ≥ 12 opted-in testers, 14 continuous days
- [ ] Production access application answers are specific and truthful
- [ ] Staged rollout configured; monitoring dashboards and alerts live
- [ ] Rollback/halt plan and kill-switch tested
- [ ] Support email monitored; review-response owner assigned

---

## 15. Top Rejection and Suspension Causes

| Cause | Prevention |
|---|---|
| **Data safety / privacy mismatch** (SDK collects data the form doesn't mention) | Inventory every SDK; update the form on every SDK change; keep the privacy policy accurate |
| **Missing or broken privacy policy URL** | Use a stable, public HTTPS page; test it in a private window |
| **Reviewer cannot access the app** (login walls, geo-blocks, expired credentials) | Provide working credentials and steps in *App access*; whitelist reviewer traffic |
| **Restricted permission without core-use justification** | Use system pickers/intents; remove the permission; submit a precise justification if truly needed |
| **Wrong target API level** | Set `targetSdk` to the current requirement; check the Policy status page |
| **Crashes / ANRs on launch** | Fix everything in the pre-launch report; test release builds on low-end devices |
| **Misleading store listing** (fake features, keyword stuffing, unofficial branding) | Use real screenshots, honest text, and your own branding |
| **Minimum functionality / spam / web-wrapper apps** | Deliver clear standalone value; native features, offline behaviour, meaningful UX |
| **Payments outside Play Billing for digital goods** | Use Play Billing (or an allowed regional alternative) |
| **Impersonation / intellectual-property claims** | Original name, icon, and assets; licences for everything you ship |
| **Ads policy violations** (disguised, intrusive, full-screen surprise ads) | Follow the ads policy; use reputable ad SDKs; label ads |
| **Child-safety / Families violations** | Use certified SDKs only; no behavioural advertising to children |
| **Account linked to a banned account** | Never share or buy accounts; keep identity data consistent |
| **Ignored policy warnings** | Read every Play Console notification; fix within the stated window; appeal with evidence if you disagree |
| **Failed production access application** | More real testers, real feedback loops, documented fixes, honest answers |

---

## 16. Appendix — Snippets, Commands, Timeline, References

### 16.1 Essential commands

```bash
# Environment
flutter doctor -v
flutter analyze --suggestions
flutter upgrade                      # only on a dedicated upgrade branch
dart pub outdated
dart fix --apply                     # apply automated migrations (e.g. deprecations)

# Run / profile
flutter run --flavor dev --dart-define-from-file=env/dev.json
flutter run --profile --trace-startup

# Quality
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --coverage
flutter test integration_test

# Release
flutter build appbundle --release --flavor prod \
  --dart-define-from-file=env/prod.json \
  --obfuscate --split-debug-info=build/symbols

# Size
flutter build apk --analyze-size --target-platform android-arm64

# Device checks
adb devices
adb shell getconf PAGE_SIZE                              # 16384 means a 16 KB device
adb shell pm get-app-links com.yourcompany.yourapp
adb shell am start -W com.yourcompany.yourapp/.MainActivity   # startup timing
```

### 16.2 Minimal `network_security_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <debug-overrides>
        <trust-anchors>
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```

### 16.3 Global error handling skeleton

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // report(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    // report(error, stack);
    return true;
  };

  // Initialize ONLY what the first frame needs, then start the UI.
  runApp(const App());

  // Everything else after the first frame:
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // unawaited(initAnalytics()); unawaited(warmCaches());
  });
}
```

### 16.4 Adaptive layout skeleton

```dart
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({super.key, required this.compact, required this.expanded});
  final WidgetBuilder compact;    // single pane + bottom navigation
  final WidgetBuilder expanded;   // list-detail + navigation rail

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600 ? compact(context) : expanded(context);
  }
}
```

### 16.5 `PopScope` for unsaved changes (replaces `WillPopScope`)

```dart
PopScope(
  canPop: !hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    final leave = await confirmDiscardChanges(context);
    if (leave && context.mounted) Navigator.of(context).pop();
  },
  child: const EditorScreen(),
)
```

### 16.6 GitHub Actions example (build + test + AAB)

```yaml
name: android-ci
on:
  pull_request:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '21' }
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.47.x'      # pin to the exact patch you use
          cache: true
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed .
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
      - name: Decode signing material (tags only)
        if: startsWith(github.ref, 'refs/tags/v')
        run: |
          echo "${{ secrets.UPLOAD_KEYSTORE_B64 }}" | base64 -d > android/upload-keystore.jks
          printf "storePassword=%s\nkeyPassword=%s\nkeyAlias=upload\nstoreFile=upload-keystore.jks\n" \
            "${{ secrets.KEYSTORE_PASSWORD }}" "${{ secrets.KEY_PASSWORD }}" > android/key.properties
      - name: Build AAB
        if: startsWith(github.ref, 'refs/tags/v')
        run: >
          flutter build appbundle --release
          --dart-define-from-file=env/prod.json
          --obfuscate --split-debug-info=build/symbols
          --build-number=${{ github.run_number }}
      - uses: actions/upload-artifact@v4
        if: startsWith(github.ref, 'refs/tags/v')
        with:
          name: release-artifacts
          path: |
            build/app/outputs/bundle/**/*.aab
            build/app/outputs/mapping/**/mapping.txt
            build/symbols/**
```

### 16.7 Recommended package categories (choose maintained, verified packages)

| Need | Category to evaluate |
|---|---|
| State management | Riverpod **or** Bloc (one) |
| Routing | `go_router` or an equivalent declarative router |
| HTTP | `dio` or `http` + interceptors |
| Code generation | `freezed`, `json_serializable`, `build_runner` |
| Local DB | `drift` (SQLite), `shared_preferences` for small settings |
| Secure storage | Keystore-backed secure-storage plugin |
| Images | A caching image plugin; `flutter_svg` for vector |
| Background work | WorkManager plugin |
| Push | Firebase Cloud Messaging plugin |
| Crash / performance | Crashlytics / Sentry |
| In-app purchase | Official `in_app_purchase` (verify it targets Billing Library 8+) or a maintained billing SDK |
| Testing | `mocktail`, `patrol` or `integration_test`, golden toolkit |

*Before adopting any package, check: last release date, open issues, verified publisher, licence, AGP 9 / built-in-Kotlin readiness, and 16 KB-aligned native libraries.*

### 16.8 Key official references (bookmark these)

- Google Play — Target API level requirements: `support.google.com/googleplay/android-developer/answer/11926878`
- Google Play — Testing requirements for new personal accounts: `support.google.com/googleplay/android-developer/answer/14151465`
- Android — Developer verification guides: `developer.android.com/developer-verification/guides`
- Android — Play Billing Library deprecation FAQ: `developer.android.com/google/play/billing/deprecation-faq`
- Android — App orientation, aspect ratio, and resizability (Android 16): `developer.android.com/develop/ui/compose/layouts/adaptive/app-orientation-aspect-ratio-resizability`
- Android — Prepare for 16 KB page sizes: search "Support 16 KB page sizes" on developer.android.com
- Flutter — Release archive and schedule: `docs.flutter.dev/install/archive`
- Flutter — What's new in 3.47: `flutter.dev/blog/whats-new-in-flutter-3-47`
- Flutter — Migrate to built-in Kotlin (apps): `docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers`
- Flutter — Deployment to Android: `docs.flutter.dev/deployment/android`
- Play Console Help — Android vitals, Policy center, Data safety, Families Policy

### 16.9 The ten rules if you remember nothing else

1. Reserve a real application ID and never change it.
2. Target **API 36+**, support **16 KB pages**, and use **Billing Library 8+** if you sell anything.
3. Start the **closed test early** (12+ real testers, 14 continuous days on new personal accounts).
4. Keep privacy policy, Data safety form, and actual SDK behaviour **identical**.
5. Build every screen for six states, 200 % text, dark mode, and large windows.
6. Profile on a **low-end physical device in profile mode**; enforce budgets in CI.
7. Never ship a debug-signed build; archive **AAB + symbols + mapping** for every release.
8. Use **staged rollouts** and watch **Android vitals** like a hawk.
9. Update the toolchain and dependencies **every quarter**, and the target API **every August**.
10. Re-verify every date and number in this document against the official pages on the day you ship.

---

*End of document. Version: September 2026 edition. Review and refresh at least every quarter.*