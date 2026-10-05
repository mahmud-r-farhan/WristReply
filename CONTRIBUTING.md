# Contributing to WristReply AI

We welcome contributions from the open-source community. This document outlines the engineering
principles, code conventions, and review workflow for the project.

## Project Overview

WristReply AI is an offline-first, on-device smart reply engine for Android and Wear OS, Zepp OS, and
RTOS smartwatches. The repository is split into three deliverables:

- `android/core-engine/` — pure Kotlin `:core-engine` library with **zero Flutter dependencies**,
  publishable as a standalone AAR or Maven artifact.
- `lib/` — Flutter presentation layer (Android cockpit).
- `playground/` — static web playground that mirrors the engine's decision logic in the browser.

The hard architectural boundary is: **the background daemon never boots the Flutter runtime.** All
engine logic runs in pure Kotlin; the Flutter app is strictly a UI/UX layer that talks to the engine
through a `MethodChannel`.

## Toolchain

| Component | Version | Where it is pinned |
| --- | --- | --- |
| Flutter | 3.47.6 | `.github/workflows/*.yml` (minimum 3.38 in `pubspec.yaml`) |
| Dart SDK | 3.13.5 | shipped with Flutter 3.47.6; `pubspec.lock` requires `>=3.11.0-0` |
| Kotlin | 2.4.0 | `android/settings.gradle.kts` |
| AGP | 8.13.0 | `android/settings.gradle.kts` |
| JDK | 17 | `android/app/build.gradle.kts`, CI |
| Gradle | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties` |
| Android | min SDK 26, compile SDK 36 | `android/app/build.gradle.kts` |
| Node.js | 18.13+ | playground tests only |

## Coding Conventions

### Kotlin (`android/core-engine/`)

- Kotlin idioms (`object` for stateless modules, `data class` for value objects).
- Maximum 150 lines per file when possible — break into micro-files inside each subpackage.
- Public APIs use `const val` for keys/channels/constants.
- All coroutine usage must end with an explicit `close()` / cancellation hook to avoid leaking the ML
  Kit model.
- No global `lateinit` mutable singletons — everything is wrapped in `@Volatile`, `CopyOnWriteArraySet`,
  or `ConcurrentHashMap`.
- Every public component has KDoc explaining its boundary and zero-leakage contract.
- Never depend on an Android framework class where a plain JVM one will do: framework classes are stubs
  under `unitTests.isReturnDefaultValues = true` and will silently no-op in unit tests.

### Dart / Flutter (`lib/`)

- Strict separation between `core/`, `features/`, and `shared/` layers:
  - `core/` — engine plumbing (constants, theme, native bridge).
  - `features/<feature_name>/screens/` — full screens.
  - `features/<feature_name>/widgets/` — feature-specific widgets.
  - `shared/widgets/` — atoms reused across features.
- Atomic widget file size target ≤ 150 lines.
- Use `const` constructors wherever the widget accepts only constants.
- Always check `mounted` before `setState()` inside async callbacks **and** inside
  `addPostFrameCallback`.
- All `NativeChannel` calls must swallow `PlatformException` and return safe empty defaults to keep the
  UI resilient if the engine is offline.
- Tests must be deterministic — never assert on a colour, count or string that depends on the wall
  clock, the locale of the runner, or a previous pump in the same tree.

### Playground (`playground/`)

- `assets/engine.js` is a **port** of the Kotlin engine, generated from the Kotlin sources. If you change
  a bank, a blocked word or a threshold in Kotlin, update the port and its parity test in the same
  commit — CI runs `node --test` on every pull request and will fail the build otherwise.
- Keep the page dependency-free: no bundler, no `node_modules`, no build step. CDN assets must always
  have a CSS fallback in `assets/styles.css`.

## Repository Etiquette

1. **No secret keys, signing material, or `key.properties`** — `.gitignore` already excludes these.
2. **Never commit `build/` artifacts.**
3. **All commits use Conventional Commits prefixes** (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`,
   `test:`).
4. **Every tracked text file ends with a newline** (enforced by `.editorconfig`).
5. **Pull Requests require:**
   - Updated unit tests for any behavioral change.
   - `flutter analyze` and `flutter test` passing locally.
   - `./gradlew :core-engine:testDebugUnitTest` passing locally.
   - A brief description of the architectural impact.

## Setting up locally

```bash
# 1. Install Flutter 3.47.6 (see the toolchain table above)

# 2. Install dependencies and generate android/local.properties
flutter pub get

# 3. Analyze and test the Dart layer
flutter analyze
flutter test

# 4. Run the Kotlin unit tests (Android)
cd android
./gradlew :core-engine:testDebugUnitTest

# 5. Build the standalone AAR
./gradlew :core-engine:assembleRelease

# 6. Playground parity tests (no install needed)
node --test playground/test/engine.test.mjs playground/test/markup.test.mjs

# 7. Open the playground
cd playground && python3 -m http.server 8080
```

If `./gradlew` fails with *`flutter.sdk` not set*, run `flutter pub get` once from the repository root
(Gradle reads `android/local.properties`, which Flutter generates), or export `FLUTTER_ROOT`.

## Formatting and linting

```bash
dart format .                                    # Dart
npx markdownlint-cli2 "**/*.md"                  # Markdown (rules in .markdownlint.json)
```

`markdownlint-cli2` reads `.markdownlint-cli2.jsonc`, which inherits the rule set from
`.markdownlint.json`. The Markdown job in CI fails the build on any violation.

There is no enforced line-length gate for Dart in CI — `flutter analyze` is the gate. Run
`dart format .` before pushing so reviews stay readable.

## CI workflows

| Workflow | Runs on | Checks |
| --- | --- | --- |
| `flutter.yml` | every push / PR to `main` | analyze, test, lockfile drift, playground node tests |
| `android.yml` | every push / PR to `main` | APK debug + release, app bundle, Kotlin JUnit, AAR |
| `docs.yml` | push / PR touching `**.md` | Markdown lint |
| `release.yml` | tag `v*.*.*` or manual | AAR + AAB + APK published to a GitHub Release |

## Reporting bugs

Use the GitHub issue template. Always include:

- Device manufacturer / Android version
- `NotificationListenerService` grant status
- Whether `flutter logs` shows any `MethodChannel` errors
- Repro steps + expected vs actual behavior

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
