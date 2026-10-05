# Changelog

All notable changes to WristReply AI are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased] — 2026-10-05

### Added
- Apache 2.0 LICENSE file at the repository root.
- `.editorconfig` enforcing LF line endings, UTF-8, 4-space indent (2-space for Dart/YAML).
- `CONTRIBUTING.md` with full engineering etiquette and Conventional Commits policy.
- GitHub Actions workflow `.github/workflows/ci.yml` — Flutter analyze + test + core-engine JUnit on PR.
- GitHub Actions workflow `.github/workflows/release.yml` — builds signed Android App Bundle and publishes a GitHub Release with the standalone `core-engine` AAR.
- GitHub Actions workflow `.github/workflows/docs.yml` — lints Markdown and deploys the playground site to GitHub Pages.
- `playground/` Flutter Web project showcasing live reply pills, language detection and locale routing, ready for one-click GitHub Pages deployment.
- Dart unit tests under `test/` (engine contract, native channel mocks, fallback banks).
- Kotlin unit tests under `android/core-engine/src/test/` for `NotificationGate`, `ProfanityGuardEngine`, `SmartTokenExtractor`, `ReadActionResolver`, `FallbackReplyEngine`, `LocationPillResolver`, `MetricsLedger`, `SleepWindowGate`.
- `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1).
- `SECURITY.md` describing the zero-cloud security policy and responsible disclosure.
- New `core-engine` public API surface: `EngineBootstrap` so external apps can install/start the headless daemon in 5 lines of Kotlin.
- Robust `mounted` guards in Flutter state classes (`PermissionScreen`, `GeneralSettingsScreen`, `LiveSandboxWidget`).
- `LocationProviderHelper` now resolves both `[📍…]` and bare `📍` pill prefixes.
- Kotlin coroutine cancellation propagation inside `MessageDebounceBuffer`.

### Changed
- Bumped Dart SDK constraint to `^3.5.0` and aligned `pubspec.yaml` dependencies with current versions.
- Upgraded `flutter_lints` to `^6.0.0`.
- Updated `analysis_options.yaml` with stricter rule set (prefer_single_quotes, require_trailing_commas, avoid_relative_lib_imports).
- `NotificationPublisher.publishPills` no longer silently drops to a 3-pill cap — now respects the user-selected `pillsPerMessage` (default 3, max 5).
- `MessageDebounceBuffer` debounce window tuned to 1.5 s for snappier UX on rapid-fire chats.
- `LocationProviderHelper.resolveDispatchText` handles missing location gracefully without crashing receivers.

### Fixed
- `general_settings_screen.dart` no longer calls `setState` after `await` without mounted guard.
- `permission_screen.dart` async action handler now awaits properly and guards the navigator.
- `OemKeepAliveManager` no longer crashes if a manufacturer component is uninstalled.
- `ActionBroadcastReceiver` correctly resolves `RemoteInput.SOURCE_FREE_FORM_INPUT` on API 28+ and falls back cleanly on lower API levels.
- `NotificationProcessorService` now flushes its `MessageDebounceBuffer` for the sender before publishing to prevent duplicate pills.
- Removed unsafe double `kotlinx.coroutines` dispatch path in `SmartReplyResolver`.

### Removed
- Dead `MaterialState` references (Flutter 3.27 migration to `WidgetState`).

## [0.1.0] — 2026-09-30

Initial public release containing the headless Kotlin engine (`android/core-engine`) and the Flutter OLED dark cockpit (`lib/`).