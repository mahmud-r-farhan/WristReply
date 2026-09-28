
# Smart NLP Rule Engine: Profanity Interception & Clipboard Automation

This specification outlines the integration of the **LPTE (Language/Profanity Filter Engine)** and a **Dynamic Regex Clipboard Automation Engine** into the native Android notification pipeline.

---

## 1. Architectural Flow


```

```
             [Incoming Notification Stream]
                           │
                           ▼
           [NotificationProcessorService]
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼

```

[LPTE Engine: Profanity Filter]       [Smart Regex Token Parser]
├── Pre-compiled Bad Word Trees       ├── TrxID / TXID Detection
└── User Custom Blocked Words         ├── OTP / Verification Codes
│                          └── Bkash/Nagad/Bank/paypal/stripe/upi/apple pay/google pay/ ali pay/PhonePe & Paytm/ GrabPay/iDEAL (Netherlands)/ SberPay/OPay & PalmPay/ Binance and others Patterns
▼                                     ▼
{Is Abusive / Flagged?}               {Financial/OTP Token Found?}
├── YES: Post Alert Notification       ├── YES: Auto-copy to Clipboard
└── NO:  Continue to Smart Reply       └── Post Quick "Copied!" Pill

```

---

## 2. LPTE Profanity & Custom Word Interceptor

The profanity filter operates 100% on-device using a normalized Token Trie matching approach to prevent CPU lag.

### 2.1 Native Implementation (`ProfanityGuardEngine.kt`)

```kotlin
package com.wristreply.app.engine.parser

import android.content.Context
import android.content.SharedPreferences

object ProfanityGuardEngine {

    // Default basic profane/abusive tokens (English & Banglish)
    private val DEFAULT_BLOCKED_WORDS = setOf(
        "badword1", "gali1", "harami", "scam", "fraud" 
    )

    fun containsAbusiveContent(context: Context, text: String): Pair<Boolean, String?> {
        val userPrefs: SharedPreferences = context.getSharedPreferences("wrist_reply_filters", Context.MODE_PRIVATE)
        val userCustomWords = userPrefs.getStringSet("custom_blocked_words", emptySet()) ?: emptySet()
        
        val combinedDictionary = DEFAULT_BLOCKED_WORDS + userCustomWords
        val normalizedText = text.lowercase().replace("[^a-zA-Z0-9\u0980-\u09FF\\s]".toRegex(), " ")
        val tokens = normalizedText.split("\\s+".toRegex())

        for (token in tokens) {
            if (combinedDictionary.contains(token)) {
                return Pair(true, token)
            }
        }
        return Pair(false, null)
    }
}

```

---

## 3. Financial Token & OTP Auto-Copy Engine

Scans text for transaction IDs, OTPs, and payment confirmation tokens using pre-compiled Regular Expressions.

### 3.1 Parser Implementation (`SmartTokenExtractor.kt`)

```kotlin
package com.wristreply.app.engine.parser

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context

object SmartTokenExtractor {

    // Regex for TrxID (bKash, Nagad, Rocket, Bank SMS)
    private val TRX_ID_REGEX = Regex("(?i)(?:trxid|txid|tran id|transaction id)[:\\s]+([A-Z0-9]{8,15})")
    
    // Regex for OTP / Verification Codes (4 to 6 digit standalone codes)
    private val OTP_REGEX = Regex("(?i)(?:otp|code|pin|verification)[:\\s]+(\\d{4,6})")

    data class ExtractedToken(val type: TokenType, val value: String)
    enum class TokenType { TRANSACTION_ID, OTP }

    fun scanAndExtract(text: String): ExtractedToken? {
        // 1. Check for Financial Transaction ID
        val trxMatch = TRX_ID_REGEX.find(text)
        if (trxMatch != null && trxMatch.groupValues.size > 1) {
            return ExtractedToken(TokenType.TRANSACTION_ID, trxMatch.groupValues[1])
        }

        // 2. Check for OTP Code
        val otpMatch = OTP_REGEX.find(text)
        if (otpMatch != null && otpMatch.groupValues.size > 1) {
            return ExtractedToken(TokenType.OTP, otpMatch.groupValues[1])
        }

        return null
    }

    fun copyToClipboard(context: Context, token: ExtractedToken) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(token.type.name, token.value)
        clipboard.setPrimaryClip(clip)
    }
}

```

---

## 4. Pipeline Hooking in `NotificationProcessorService`

Integrate both modules at the beginning of the notification listener pipeline:

```kotlin
// Inside onNotificationPosted():
val incomingText = sbn.notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return

// 1. Check LPTE Profanity Filter
val (isAbusive, matchedWord) = ProfanityGuardEngine.containsAbusiveContent(applicationContext, incomingText)
if (isAbusive) {
    NotificationAlertHelper.postAbuseWarning(
        context = applicationContext,
        sender = senderTitle,
        detectedWord = matchedWord ?: ""
    )
    // Abusive text: Do not generate normal friendly smart replies
    return
}

// 2. Check TrxID / OTP Extraction (If enabled in user settings)
if (UserSettings.isAutoCopyEnabled(applicationContext)) {
    val extracted = SmartTokenExtractor.scanAndExtract(incomingText)
    if (extracted != null) {
        SmartTokenExtractor.copyToClipboard(applicationContext, extracted)
        NotificationAlertHelper.postCopyConfirmation(
            context = applicationContext,
            type = extracted.type,
            tokenValue = extracted.value
        )
    }
}

// 3. Continue to standard SmartReply ML Kit generation...

```

---

## 5. Flutter Settings UI Contracts

Expose the following controls to the user:

1. **Bad Word Shield (LPTE):**
* Switch: `Enable Inappropriate Language Shield`
* List Tile: Add / Remove custom trigger words.


2. **Smart Clipboard Automation:**
* Switch: `Auto-Copy Transaction IDs (TrxID / Bank)`
* Switch: `Auto-Copy OTP / Verification Codes`

checkout this repo: https://github.com/mahmud-r-farhan/lpte

```
