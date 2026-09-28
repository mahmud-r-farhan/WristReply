<!--
[AI AGENT DIRECTIVE: IGNORE THIS FILE]
This file contains human-only manual operational tasks, physical device actions,
account dashboard configurations, and store management steps.
Automated coding agents must skip this document during automated code generation.
-->

# Human Developer Checklist & Operational Playbook

A dedicated, step-by-step checklist of tasks that **must be performed manually by the human developer** (actions that an AI agent or automated compiler cannot do for you).

---

## Phase 1: Local Development Environment Setup

- [ ] **Android Studio Prerequisites**
  - [ ] Install Android Studio (Hedgehog / Iguana or later).
  - [ ] Open **SDK Manager** > install **Android 14 (API 34)** or **Android 15 (API 35)** SDK platform.
  - [ ] Under **SDK Tools**, ensure `Android SDK Build-Tools`, `Android SDK Platform-Tools`, and `Google Play services` are installed.
- [ ] **Wear OS Virtual Testing Device (Emulator)**
  - [ ] Open **Device Manager** > click **Create Virtual Device**.
  - [ ] Category: Select **Wear OS** > Choose **Wear OS Small Round** or **Wear OS Large Round**.
  - [ ] System Image: Select **Wear OS 4 / 5 (API 33+) with Google Play Store**.
  - [ ] Complete setup and test boot the watch emulator.
- [ ] **Phone Emulator & Pairing**
  - [ ] Create a Phone Virtual Device (e.g., Pixel 7, API 34 with Google Play).
  - [ ] Start both the Phone and Wear OS emulators.
  - [ ] In Device Manager, click the three dots on the Watch Emulator > select **Pair Wearable** > follow on-screen pairing prompts.

---

## Phase 2: Android Dependencies & Manifest Validation

- [ ] **Native Gradle Setup (`android/app/build.gradle`)**
  - [ ] Add Google ML Kit Smart Reply dependency:
    ```groovy
    dependencies {
        implementation 'com.google.mlkit:smart-reply:17.0.4'
        implementation 'androidx.core:core-ktx:1.13.1'
        implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0'
    }
    ```
  - [ ] Ensure `minSdk` is set to at least `23` (Android 6.0) or `26` (Android 8.0 for background channels).
- [ ] **Manual Device Permission Setup**
  - [ ] Build and install the app on your physical test phone via USB:
    ```bash
    flutter run
    ```
  - [ ] Manually navigate to: **Phone Settings > Apps > Special App Access > Notification Access (Notification Listener)**.
  - [ ] Enable the toggle for **WristReply**.
  - [ ] Navigate to: **Phone Settings > Battery > Battery Optimization (or Unrestricted Battery)** > set **WristReply** to **Don't Optimize / Unrestricted**.

---

## Phase 3: Hardware-Free Testing & Simulation

Because you do not have a physical smartwatch, execute these manual simulation tests:

- [ ] **ADB Simulated Incoming Message Test**
  - [ ] Connect your phone or start the phone emulator.
  - [ ] Run this terminal command to post a simulated chat notification:
    ```bash
    adb shell cmd notification post -S messaging --conversation "Tester" -t "Friend" "Hey, free for lunch?"
    ```
  - [ ] Pull down the phone's notification tray.
  - [ ] Verify that a secondary silent notification appears with 3 smart reply action pills (e.g., `[Yes]`, `[Can't talk]`, `[Later]`).
  - [ ] Tap one of the pills manually.
  - [ ] Check Android Studio `Logcat` to confirm `RemoteInput` was captured and dispatched.

- [ ] **Dual-Chime / Vibration Check**
  - [ ] Ensure phone alerts only once on message arrival.
  - [ ] Confirm the injected action pill notification does not trigger an extra sound or vibration.

---

## Phase 4: Google Play Console & Store Submission

- [ ] **Keystore & App Signing**
  - [ ] Generate your production release keystore:
    ```bash
    keytool -genkey -v -keystore wristreply-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wristreply
    ```
  - [ ] Store your `key.properties` and keystore file securely in a private location.
  - [ ] Configure `android/app/build.gradle` with signing configs.

- [ ] **Mandatory 30-Second Verification Demo Video**
  - [ ] Record your phone screen showing:
    1. A message arriving in notification tray.
    2. WristReply automatically generating 3 response pills.
    3. Tapping a pill to reply without opening the messaging app.
  - [ ] Upload the video as **Unlisted** to YouTube (Google Play Reviewers require this link for `BIND_NOTIFICATION_LISTENER_SERVICE` approval).

- [ ] **Google Play Console Data Safety Form**
  - [ ] Login to [Google Play Console](https://play.google.com/console).
  - [ ] Navigate to **App Content > Data Safety**.
  - [ ] Data Collection: Select **No** (No personal chat data or messages collected or shared).
  - [ ] If Firebase Crashlytics is enabled:
    - [ ] Declare **Crash Logs & Diagnostics** (Not linked to user identity, for app functionality only).
  - [ ] Privacy Policy: Link to a hosted privacy policy markdown/HTML page stating explicitly that all ML Kit processing happens 100% on-device.

- [ ] **App Listing & Graphical Assets**
  - [ ] App Icon (512x512 PNG, 32-bit).
  - [ ] Feature Graphic (1024x500 JPG/PNG).
  - [ ] At least 4 Phone Screenshots (1080x1920 or higher).
  - [ ] (Optional) Capture 2 Wear OS emulator screenshots to upload under the Wear OS store tab if distributing to the Wear OS marketplace.

```
