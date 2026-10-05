# WristReply AI Playground

The WristReply AI Playground offers two live demonstration environments for testing the **WristReply AI** smart reply engine in modern browsers — with zero network calls and zero Android build setup required.

---

## 1. Standalone Vanilla JS & HTML Playground (Zero Build Step)

The lightweight Vanilla JS playground is located at `playground/index.html`. It runs directly in any browser with **no build tools or Flutter setup required**.

### How to Run:
- Open `playground/index.html` directly in your web browser.
- Alternatively, serve with any static web server:
  ```bash
  cd playground
  python3 -m http.server 8080
  ```
  Then visit `http://localhost:8080`.

---

## 2. Flutter Web Playground

A standalone Flutter Web application running an exact Dart mirror of the Kotlin `FallbackReplyEngine` contract.

### Running Locally:
```bash
cd playground
flutter pub get
flutter run -d chrome
```

### Building for Production:
```bash
cd playground
flutter build web --release --source-maps
```
The static web bundle is emitted to `playground/build/web/`.

---

## Features & Engine Contracts Covered

- **Banglish & Script Detection:** Automatic language routing for Bengali, Banglish, Spanish, Arabic, German, and English.
- **OTP & Payment Extractors:** Intelligent extraction of OTP verification codes (e.g. `849201`) and mobile payment tokens.
- **Location Pill Resolver:** Resolves waypoint requests and `📍` location pins to actionable response chips.
- **Driving Mode Override:** Instant override with safe driving responses when driving mode is toggled.
- **Profanity Guard:** Filters flagged words before rendering reply candidates.
- **Metrics Ledger:** Tracks sub-millisecond inference latency, active pipeline rule gates, and generated pill counts.

---

## Files

- `index.html` — Zero-dependency HTML5 interface.
- `playground.js` — Offline Vanilla JS smart reply engine.
- `styles.css` — OLED Dark Utility UI stylesheet.
- `lib/main.dart` — Flutter Web implementation.
- `web/index.html` — Flutter Web entrypoint with custom splash screen and PWA manifest.
- `web/manifest.json` — PWA configuration.
- `test/playground_widget_test.dart` — Flutter unit tests for the playground engine.
