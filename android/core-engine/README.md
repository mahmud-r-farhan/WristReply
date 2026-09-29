# WristReply Core Engine

An on-device, zero-cloud smart reply engine for Android and connected smartwatches.

## Highlights
- **100% On-Device:** Powered by Google ML Kit Smart Reply with zero cloud calls and zero internet permissions required.
- **Dynamic App Detection:** Resolves inline-reply endpoints at runtime via semantic `RemoteInput` inspection without hardcoded package identifiers.
- **Universal Smartwatch Support:** Mirrors silent action pills to Wear OS, Zepp OS, and budget RTOS smartwatches (Pixel Watch, Galaxy Watch, Amazfit, boAt, Noise, Fire-Boltt, etc.).
- **Global Multi-Lingual Fallbacks:** Native deterministic fallbacks for high-adoption smartwatch markets (English, Spanish, German, Portuguese, French, Arabic) plus Indic & regional support (Hindi, Bengali/Banglish).
- **LPTE Profanity Shield & Clipboard Automation:** Intercepts abusive messages with decoupled token dictionaries and auto-copies global financial tokens/OTPs (Apple Pay, Google Pay, PayPal, Stripe, Pix, iDEAL, UPI, Bank SMS).
- **Zero-Battery Daemon:** Ephemeral client lifecycles, debounced anti-spam buffers, and in-memory LRU caching keep steady-state RAM at 15MB–25MB and 0% idle CPU.
