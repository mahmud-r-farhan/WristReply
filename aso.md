# WristReply AI — Google Play Store ASO & Listing Pack

<!-- markdownlint-disable MD013 -->
<!-- The long description below is copy-pasted verbatim into Play Console, where
     line breaks are rendered literally. Do not reflow it. -->

Everything in this file is written against the real engine behaviour — feature claims trace to code in
`android/core-engine/`, so the Data Safety and permission disclosures stay defensible under review.

---

## 1. App Title (max 30 characters)

- **Primary (29/30):** `WristReply: Smart Quick Reply`
- **Alternative A — automation (30/30):** `WristReply: Auto Reply Offline`
- **Alternative B — AI & productivity (30/30):** `WristReply AI: Smart Auto Text`
- **Alternative C — wearable (30/30):** `WristReply: Wear OS Quick Text`

---

## 2. Short Description (max 80 characters)

- **Primary (79/80):** `One-tap smart replies for phone notifications and smartwatches. 100% offline AI.`
- **Alternative A — messaging keywords (78/80):** `Instant offline smart replies for WhatsApp & Telegram on your phone and watch.`
- **Alternative B — privacy (80/80):** `Offline smart quick replies for WhatsApp, SMS & every watch. Zero cloud, 0% ads.`
- **Alternative C — drawer focus (77/80):** `Smart auto replies in your notification shade and on your wrist. 100% private.`

---

## 3. Long Description (max 4,000 characters)

```text
Tired of typing the same repetitive replies while multitasking, driving, or glancing at your wrist?

WristReply AI delivers lightning-fast, on-device contextual quick replies directly to your Android notification shade, lock screen, and connected smartwatch — all with 100% offline privacy and zero battery drain.

Whether you're using an Android phone, a foldable or flip display, a premium Wear OS watch, or a budget fitness tracker, WristReply automatically generates intelligent 1-tap reply pills so you can respond in milliseconds without opening the messaging app.

━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 100% ON-DEVICE & ZERO CLOUD PRIVACY
━━━━━━━━━━━━━━━━━━━━━━━━━━
• Powered by Google ML Kit: all message processing and smart suggestions run strictly on your phone's local chipset.
• Zero internet permission: the engine core does not request internet access at all — silent data exfiltration is technically impossible.
• Zero tracking, zero ads: your personal chats, names and messages never touch an external server or cloud database.
• Backups disabled: android:allowBackup="false" plus data extraction rules that exclude every preference file.

━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ KEY FEATURES & CAPABILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ 1-TAP INSTANT SMART REPLIES
Context-aware quick reply pills docked right under incoming notifications for WhatsApp, Telegram, Signal, Google Messages, SMS and Slack — plus any app that exposes an inline reply action. Tap to dispatch instantly through native RemoteInput, without opening the chat.

⌚ WORKS ON PHONES & EVERY SMARTWATCH
• No watch required: instant 1-tap reply pills in your phone's notification drawer and on the lock screen.
• Wear OS & Galaxy Watch: companion notification actions with mirrored pills.
• Zepp OS / Amazfit: companion relay of the same pills.
• Budget RTOS watches (boAt, Noise, Fire-Boltt): standard notification action mirroring — no companion app.

🌍 TRUE MULTI-REGIONAL & MULTI-LINGUAL SUPPORT
• English, Spanish (Español), German (Deutsch), Portuguese (Português), French (Français), Arabic (العربية), Hindi (हिन्दी / Hinglish) and Bengali (বাংলা / Banglish) — 24 curated reply banks.
• Auto-detects location queries ("Where are you?", "¿Dónde estás?", "Wo bist du?") and appends a one-tap location pill in the right language ([📍 Location], [📍 Ubicación], [📍 Standort], [📍 موقعي]).

🚗 AUTONOMOUS DRIVING & MEETING AUTOMATION
• Bluetooth car audio detection injects driving pills ([🚗 Driving], [🚗 Manejando]) when you are connected to a car headset.
• Calendar busy mode generates contextual pills with the exact meeting end time ([📅 In meeting until 3:30 PM]).
• Delayed auto-reply: sends a polite response if you are away from your phone (default 5 minutes, adjustable).

📋 SMART CLIPBOARD & FINANCIAL TOKEN AUTO-COPY
Automatically detects and copies 2FA/OTP codes and transaction IDs (Apple Pay, Google Pay, PayPal, Stripe, Pix, iDEAL, UPI, bKash, GrabPay and bank SMS alerts) to your clipboard, with a silent confirmation notice.

🛡️ INAPPROPRIATE LANGUAGE SHIELD (LPTE)
A local on-device protection engine flags abusive messages and suppresses cheerful reply pills, so you never auto-reply to harassment.

⏱️ BURST DEBOUNCE
Rapid-fire messages from the same sender are coalesced inside a 1.5-second window (up to 5 messages), so one busy chat produces one calm set of pills instead of five.

📱 ADAPTIVE FOLDABLE & FLIP OPTIMIZATION
Tailored for Samsung Galaxy Z Fold, Galaxy Z Flip, Google Pixel Fold, tablets and cover screens: adaptive dual-pane cockpit when unfolded, zero-overflow scroll views on outer displays.

🔋 ULTRA-LEAN BATTERY GUARD
Runs as a headless Kotlin background daemon at ~15–25 MB resident RAM and 0% idle CPU. The Flutter runtime is never booted in the background, and there are no wake-locks.

━━━━━━━━━━━━━━━━━━━━━━━━━━
🔒 PERMISSIONS & COMPLIANCE DISCLOSURE
━━━━━━━━━━━━━━━━━━━━━━━━━━
WristReply requires Android Notification Access (NotificationListenerService) solely to detect incoming chat notifications and attach smart quick-reply action pills. All conversation text is processed ephemerally on-device and is never stored, tracked or shared.
```

---

## 4. Data safety form (Play Console)

| Question | Answer | Justification |
| --- | --- | --- |
| Does the app collect or share user data? | No | No `INTERNET` permission is declared |
| Is all user data encrypted in transit? | Not applicable | No data leaves the device |
| Can users request data deletion? | Yes | Preferences are local; uninstalling removes them |
| Notification access justification | On-device smart replies only | Disclosed during onboarding |

---

## 5. Keyword sets

- **Primary:** smart reply, quick reply, auto reply, notification reply, wearable reply
- **Secondary:** offline AI, private messaging, WhatsApp reply, Telegram reply, SMS auto reply
- **Wearable:** Wear OS reply, smartwatch quick reply, Amazfit reply, boAt notification, RTOS watch
- **Privacy:** no internet permission, on-device NLP, zero telemetry, no ads

## 6. Store graphic checklist

- Feature graphic 1024 × 500 px showing the phone + round watch mockup from the playground.
- Phone screenshots: onboarding disclosure, dashboard, live sandbox, whitelist, persona rules.
- Wear OS screenshots: companion pills on a round display (44 dp targets).
- Every screenshot must show the dark OLED cockpit (`#0B0E14` canvas, `#38EF7D` accents).
