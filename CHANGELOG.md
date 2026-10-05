# Changelog

All notable changes to WristReply AI are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.2.0] — 2026-10-05

### Added

- **Static web playground** at `playground/index.html` — a zero-build, zero-dependency page that runs the
  reply engine in the browser, with a phone mockup and both round and square smartwatch mockups. Styling
  uses Tailwind CSS from the official CDN and animations use AOS from cdnjs, with a bundled fallback
  stylesheet so the page still renders when a CDN is blocked.
- `playground/assets/engine.js` — a JavaScript port of the Kotlin engine: fallback banks, locale
  detection, `RemoteInput` scanning, profanity guard, token extraction, contextual enhancers,
  debounce buffer, and the full eight-stage `runPipeline`.
- `playground/test/engine.test.mjs` — 41 `node:test` assertions that mirror the Kotlin JUnit suite,
  including per-locale fallback expectations, token formats and debounce timing (41/41 passing).
- `playground/test/markup.test.mjs` — verifies the page wiring: every `getElementById` target exists,
  every navigation anchor resolves to a section, CDN references are present, local assets resolve, and
  the app only imports symbols the engine actually exports.
- `.markdownlint-cli2.jsonc` — markdownlint-cli2 does not read `.markdownlint.json`, so the CI Markdown
  job had been linting with stock defaults; the new config points cli2 at the shared rule set and scopes
  the glob list.
- GitHub Actions workflow `.github/workflows/flutter.yml` — `flutter analyze`, `flutter test` with
  coverage, `pubspec.lock` drift check and the playground `node --test` suites.
- GitHub Actions workflow `.github/workflows/android.yml` — `flutter build apk` (debug and release),
  `flutter build appbundle`, `:core-engine:testDebugUnitTest` and `:core-engine:assembleRelease` with
  Gradle caching, JUnit report and AAR uploaded as artifacts.
- GitHub Actions workflow `.github/workflows/docs.yml` — Markdown lint on documentation changes.
- `lifecycle-runtime-ktx:2.8.7` in `android/app/build.gradle.kts` so `MainActivity`'s `lifecycleScope`
  extension resolves on modern AGP.
- `FLUTTER_ROOT` fallback in `android/settings.gradle.kts` so Gradle can configure when
  `android/local.properties` has not been generated yet.

### Changed

- Removed `.github/workflows/playground.yml` (the GitHub Pages deployment of a Flutter Web playground).
  The playground is now a static page, so there is nothing to compile or deploy.
- Removed `.github/workflows/ci.yml` and split its responsibilities across the three focused workflows
  above. Its `markdown-lint` job passed `ignores` as a YAML sequence where the action requires a scalar
  string, which made the workflow file invalid and failed every run with zero jobs.
- Replaced the `playground/` Flutter Web project (28 files) with the static site described above.
- Bumped `pubspec.yaml` to `0.2.0+2`, Dart SDK constraint to `^3.10.0` and minimum Flutter to `>=3.38.0`,
  matching `pubspec.lock` (`shared_preferences 2.5.5`).
- CI pins Flutter **3.47.6** rather than 3.38.0. Flutter 3.38.0 ships Dart `3.10.0-290.4.beta`, and a
  pre-release does not satisfy `sdk: ^3.10.0`, so `flutter pub get` failed version solving; pub itself
  recommends 3.47.6 as the stable release carrying Dart 3.10.
- Pinned Kotlin to `2.4.0` and AGP to `8.13.0` in `android/settings.gradle.kts`, and bumped the Gradle
  wrapper from 8.8 to 8.14. Flutter 3.47 refuses anything below AGP 8.11.1 and Gradle 8.14, and KGP
  2.1.x only documents support up to AGP 8.7.2 — so all three move together. The chosen set is the
  one Flutter 3.47.6's own template and compatibility tables describe as valid.
  `compilerOptions { jvmTarget }` also requires KGP 2.0 or newer.
- Dropped the `kotlin("plugin.serialization")` plugin from `android/core-engine/build.gradle.kts`. It was
  pinned at 2.3.20 while the Android plugin was 1.9.24 (a Kotlin Gradle Plugin version split that fails
  configuration), and the module contains no `@Serializable` type.
- Replaced `androidx.collection.LruCache` in `SmartReplyLruCache` with a pure-JVM linked-hash LRU.
  `LruCache` is an Android framework class that no-ops under `unitTests.isReturnDefaultValues = true`,
  which silently disabled the cache in unit tests.
- `test/widget_test.dart` rewritten as two deterministic tests driven by a mocked `MethodChannel`. The
  previous version pumped `WristReplyApp()` twice under the same widget tree, so the second pump found
  the `CircularProgressIndicator` still on screen and the golden colour assertions failed.
- `analysis_options.yaml` expanded: strict casts, strict raw types, `unused_import` promoted to error,
  generated code excluded, plus a curated rule set (`prefer_single_quotes`, `close_sinks`,
  `cancel_subscriptions`, `hash_and_equals`, `use_full_hex_values_for_flutter_colors`, …).
- Every documentation file reflowed and refreshed for the 0.2.0 layout; 54 tracked files that were
  missing a final newline now end with one.

### Fixed

- **Neither Android module applied the Kotlin Gradle plugin.** `:app` and `:core-engine` both configure
  the compiler through `kotlin { jvmToolchain(17); compilerOptions { … } }`, but their `plugins {}`
  blocks only applied `com.android.application` / `com.android.library`, so Gradle failed configuration
  with `Unresolved reference: jvmToolchain / compilerOptions / jvmTarget`. `id("kotlin-android")` is now
  applied in both (before `dev.flutter.flutter-gradle-plugin` in `:app`, as that plugin requires). This
  was invisible until `settings.gradle.kts` stopped throwing first.
- `android/settings.gradle.kts` no longer throws when `android/local.properties` is absent. It used to
  fail the whole configuration phase, which is why the Core-Engine CI job exited with code 127.
- `FallbackReplyEngineTest` no longer depends on wall-clock time: the chrono bias is disabled
  explicitly, so the "Hello there how are you today" expectations hold at every hour.
- `MetricsLedgerTest` expectations corrected to the real ledger contract — average latency is `75L` for
  a 120/90/60 sample set, `0L` when no samples exist, and `getMetrics()` reports the `18L` idle default
  after a reset.
- `ProfanityGuardEngineTest` now asserts against a token that is actually in `DefaultBlockedWords`
  (`idiot`); `stupid` and `dumb` are not in the dictionary, so both expectations could never pass.
- `NotificationGateTest` rewritten with Mockito against a real `Bundle` instance instead of expecting a
  `null` bundle to return flags — `NotificationGate.extrasToMap` reads the bundle and would NPE.
- `SmartReplyLruCacheTest` passes again (see the LRU replacement above).
- `live_sandbox_widget.dart` guards `mounted` inside its `addPostFrameCallback`, so the initial pill
  generation cannot call `setState` on a disposed state.
- `app_theme.dart` uses `const` for the fully-constant `SliderThemeData` and `AppColors` references.
- `native_channel.dart` KDoc no longer documents a `getMetrics()` method that the bridge does not
  expose; it references `getEngineMetrics()`.
- `.github/workflows/release.yml` used `${${{ github.event.inputs.tag }}#v}`, which bash expands to
  `${v0.2.0#v}` and rejects with "bad substitution". Tag stripping now happens in a real shell variable.
- Release workflow no longer swallows build failures with `continue-on-error`, and now uploads the AAB
  and APKs alongside the AAR.
- `android/core-engine/README.md` badge links pointed at `README.md` and `LICENSE` inside the module
  directory; they now resolve to the repository root files.
- `assets/onboarding/why_offline.md` link to `engineering.md` corrected to the repository-root path.

## [0.1.0] — 2026-10-04

### Added

- Initial public release of the headless `:core-engine` Kotlin module with `NotificationProcessorService`,
  `NotificationGate`, `ProfanityGuardEngine`, `SmartTokenExtractor`, `EphemeralMLKitEngine`,
  `FallbackReplyEngine`, `ContextualReplyEnhancer`, `NotificationPublisher` and `WearSyncService`.
- Flutter cockpit with onboarding, dashboard, whitelist, persona and filters features.
- Apache 2.0 `LICENSE`, `CODE_OF_CONDUCT.md`, `SECURITY.md` and `CONTRIBUTING.md`.
- Gradle wrapper (`android/gradlew`, `android/gradle/wrapper/gradle-wrapper.jar`).
- `.editorconfig`, `.markdownlint.json` and the initial GitHub Actions release workflow.

[0.2.0]: https://github.com/mahmud-r-farhan/WristReply/releases/tag/v0.2.0
[0.1.0]: https://github.com/mahmud-r-farhan/WristReply/releases/tag/v0.1.0
