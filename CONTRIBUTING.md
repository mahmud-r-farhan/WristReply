# Contributing to WristReply AI

We welcome contributions from the open-source community. This document outlines the engineering principles, code conventions, and review workflow for the project.

## Project Overview

WristReply AI is an offline-first, on-device smart reply engine for Android and Wear OS, Zepp OS, and RTOS smartwatches. The repository is split into two modules:

- `android/core-engine/` — Pure Kotlin `:core-engine` library with **zero Flutter dependencies**, publishable as a standalone AAR or Maven artifact.
- `lib/` — Flutter presentation layer (Android cockpit).

The hard architectural boundary is: **the background daemon never boots the Flutter runtime.** All engine logic runs in pure Kotlin; the Flutter app is strictly a UI/UX layer that talks to the engine through a `MethodChannel`.

## Coding Conventions

### Kotlin (`android/core-engine/`)

- Kotlin idioms (`object` for stateless modules, `data class` for value objects).
- Maximum 150 lines per file when possible — break into micro-files inside each subpackage.
- Public APIs use `const val` for keys/channels/constants.
- All coroutine usage must end with an explicit `close()` / cancellation hook to avoid leaking the ML Kit model.
- No global `lateinit` mutable singletons — everything is wrapped in `@Volatile`, `CopyOnWriteArraySet`, or `ConcurrentHashMap`.
- Every public component has KDoc explaining its boundary and zero-leakage contract.

### Dart / Flutter (`lib/`)

- Strict separation between `core/`, `features/`, and `shared/` layers:
  - `core/` — engine plumbing (constants, theme, native bridge).
  - `features/<feature_name>/screens/` — full screens.
  - `features/<feature_name>/widgets/` — feature-specific widgets.
  - `shared/widgets/` — atoms reused across features.
- Atomic widget file size target ≤ 150 lines.
- Use `const` constructors wherever the widget accepts only constants.
- Always use `mounted` checks before `setState()` inside async callbacks.
- All `NativeChannel` calls must swallow `PlatformException` and return safe empty defaults to keep the UI resilient if the engine is offline.

## Repository Etiquette

1. **No secret keys, signing material, or `key.properties`** — `.gitignore` already excludes these.
2. **Never commit `build/` artifacts.**
3. **All commits use Conventional Commits prefixes** (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`).
4. **Pull Requests require:**
   - Updated unit tests for any behavioral change.
   - Pass-through of `flutter analyze` + `flutter test` + `./gradlew :core-engine:test`.
   - Brief description of the architectural impact.

## Setting up locally

```bash
# 1. Install Flutter (≥ 3.24)
# 2. Install dependencies
flutter pub get

# 3. Run unit tests (Dart)
flutter test

# 4. Run Kotlin unit tests (Android)
cd android
./gradlew :core-engine:testDebugUnitTest

# 5. Build the standalone AAR
./gradlew :core-engine:assembleRelease
```

## Reporting bugs

Use the GitHub issue template. Always include:

- Device manufacturer / Android version
- NotificationListenerService grant status
- Whether `flutter logs` shows any `MethodChannel` errors
- Repro steps + expected vs actual behavior

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.