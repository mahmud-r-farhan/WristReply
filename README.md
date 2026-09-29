# WristReply Core Engine

An on-device, zero-cloud smart reply engine for Android and connected smartwatches.

## Highlights
- **100% On-Device:** Powered by Google ML Kit Smart Reply with zero cloud calls and zero internet permissions required.
- **Dynamic App Detection:** Resolves inline-reply endpoints at runtime via semantic `RemoteInput` inspection without hardcoded package identifiers.
- **Universal Smartwatch Support:** Mirrors silent action pills to Wear OS, Zepp OS, and budget RTOS smartwatches (boAt, Noise, Fire-Boltt, Amazfit, etc.).
- **Regional Language Fallbacks:** Deterministic fallback banks for Bengali, Banglish transliteration, and English.
- **LPTE Profanity Shield & Clipboard Automation:** Intercepts abusive messages and auto-copies financial tokens/OTPs (bKash, Nagad, Bank SMS, UPI).
- **Zero-Battery Daemon:** Ephemeral client lifecycles, debounced anti-spam buffers, and in-memory LRU caching keep steady-state RAM at 15MB–25MB and 0% idle CPU.
