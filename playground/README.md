# WristReply AI Playground

A standalone Flutter Web application that demonstrates the **WristReply AI**
reply engine live in any modern browser — no Android build required.

The playground runs an **exact Dart mirror** of the Kotlin
`FallbackReplyEngine` contract, so the pills you see here are the same
pills that will appear in your phone's notification shade and on your
Wear OS / Zepp OS / RTOS smartwatch.

## Running locally

```bash
cd playground
flutter pub get
flutter run -d chrome
```

## Building for production

```bash
flutter build web --release --source-maps
```

The static bundle is emitted to `playground/build/web/`.

## Deployment

The repository ships with `.github/workflows/playground.yml` that
automatically deploys this playground to **GitHub Pages** on every push to
`main` that touches files under `playground/`.

To enable the GitHub Pages site:

1. Push the branch to GitHub.
2. In repository settings → Pages, choose **GitHub Actions** as the source.
3. The workflow will publish at:
   `https://<owner>.github.io/WristReply/`

## Files

- `lib/main.dart` — Single-file Flutter Web implementation (~700 lines).
- `web/index.html` — Custom splash screen and PWA manifest.
- `web/manifest.json` — PWA configuration (installable on Android, iOS, desktop).
- `test/playground_widget_test.dart` — Unit tests for the locale detector.
