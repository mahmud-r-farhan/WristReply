# Comprehensive Engineering & Architecture Guide: Smart Reply Engine

A production-grade, offline-first smart reply system bridging Android, budget RTOS smartwatches, Zepp OS, and Wear OS without compromising user privacy or violating Google Play Developer Policies.

---

## 1. System Reality & Ecosystem Matrix

Not all smartwatches handle notifications the same way. Understanding the platform capabilities is required before writing code:

| Ecosystem | OS Examples | Integration Method | Real-World Behavior |
| :--- | :--- | :--- | :--- |
| **Wear OS** | Galaxy Watch 4+, Pixel Watch, Xiaomi Watch 2 | Jetpack Compose + `Wearable.MessageClient` | Full standalone UI, custom pill layout, direct bidirectional BLE sync. |
| **Zepp OS** | Amazfit Balance, Cheetah, GTR/GTS 4 | Zepp OS JS App + BLE Bridge | Custom micro-app displaying suggestion pills; dispatches response code back to phone. |
| **Budget RTOS** | boAt, Noise, Fire-Boltt, basic Mi Bands | **Native Notification Mirroring** | Watches mirror system `NotificationCompat.Action`. Tapping a button triggers the phone's `PendingIntent`. |
| **Smartwatch-less** | Direct Android Device | **Assistive Bubble & System Notification Shade** | Suggestions appear directly inside the notification tray as actionable buttons, or as a floating overlay pill. |

---

## 2. Core Mechanism: Native Notification Mirroring

To make smart replies work on inexpensive RTOS watches without building custom watch apps:


```

[Incoming Chat (WhatsApp/Telegram)]
│
▼
NotificationListenerService (Reads message + RemoteInput)
│
▼
Google ML Kit (Generates on-device text pills)
│
▼
Build Cloned/Enhanced Notification with Action Pills:

* Action 1: "Yes, sure!"   ──> PendingIntent (ReplyReceiver)
* Action 2: "Call you soon"──> PendingIntent (ReplyReceiver)
* Action 3: "Can't talk"   ──> PendingIntent (ReplyReceiver)
│
┌──────┴──────────────────────────┐
▼                                 ▼
[Android Notification Tray]    [Companion App (DaFit/NoiseFit)]
(Phone user taps to reply)                 │ (Mirrors via BLE)
▼
[Budget Smartwatch]
(Shows Quick Reply buttons)

```

When a user taps an action button on their watch, the watch transmits the action ID over BLE to the companion app, which calls `PendingIntent.send()`. The app catches this, bundles the text into `RemoteInput`, and forwards it to WhatsApp or Telegram.

---

## 3. End-to-End Kotlin Implementation

### 3.1. Notification Interceptor (`SmartReplyListenerService.kt`)

```kotlin
package com.wristreply.app.services

import android.app.Notification
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.TextMessage
import com.wristreply.app.receivers.DirectReplyReceiver

class SmartReplyListenerService : NotificationListenerService() {

    private val mlKitClient = SmartReply.getClient()

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val activeSbn = sbn ?: return

        val pkg = activeSbn.packageName
        if (!isSupportedPackage(pkg)) return

        // Prevent self-loop on our own injected notifications
        if (activeSbn.notification.extras.getBoolean("IS_WRIST_REPLY_INJECTED", false)) return

        val extras = activeSbn.notification.extras
        val messageText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return
        val senderTitle = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: "Sender"

        val replyData = extractRemoteInputDetails(activeSbn.notification) ?: return

        // Build conversational context
        val contextList = listOf(
            TextMessage.createForRemoteUser(messageText, System.currentTimeMillis(), senderTitle)
        )

        mlKitClient.suggestReplies(contextList)
            .addOnSuccessListener { result ->
                val suggestions = result.suggestions.map { it.text }
                if (suggestions.isNotEmpty()) {
                    injectSmartReplyNotification(
                        notificationId = activeSbn.id,
                        title = senderTitle,
                        originalText = messageText,
                        suggestions = suggestions,
                        replyData = replyData
                    )
                }
            }
    }

    private fun isSupportedPackage(pkg: String): Boolean {
        return pkg in setOf("com.whatsapp", "org.telegram.messenger", "com.google.android.apps.messaging")
    }

    private fun extractRemoteInputDetails(notification: Notification): RemoteInputData? {
        val actions = notification.actions ?: return null
        for (action in actions) {
            val remoteInputs = action.remoteInputs ?: continue
            for (input in remoteInputs) {
                if (input.resultKey != null && action.actionIntent != null) {
                    return RemoteInputData(
                        actionIntent = action.actionIntent,
                        resultKey = input.resultKey,
                        remoteInput = input
                    )
                }
            }
        }
        return null
    }

    private fun injectSmartReplyNotification(
        notificationId: Int,
        title: String,
        originalText: String,
        suggestions: List<String>,
        replyData: RemoteInputData
    ) {
        val channelId = "smart_reply_channel"
        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setContentTitle(title)
            .setContentText(originalText)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        // Store flag to prevent recursion
        val extras = Bundle().apply {
            putBoolean("IS_WRIST_REPLY_INJECTED", true)
        }
        builder.addExtras(extras)

        // Add each Smart Reply as a distinct NotificationCompat.Action
        suggestions.take(3).forEachIndexed { index, suggestion ->
            val intent = Intent(this, DirectReplyReceiver::class.java).apply {
                putExtra("KEY_REPLY_TEXT", suggestion)
                putExtra("KEY_RESULT_KEY", replyData.resultKey)
                putExtra("KEY_ORIGINAL_INTENT", replyData.actionIntent)
                putExtra("KEY_NOTIFICATION_ID", notificationId)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                this,
                notificationId * 10 + index,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )

            val action = NotificationCompat.Action.Builder(
                0,
                suggestion, // Text label displayed as pill on watch/tray
                pendingIntent
            ).build()

            builder.addAction(action)
        }

        try {
            NotificationManagerCompat.from(this).notify(notificationId, builder.build())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }
}

data class RemoteInputData(
    val actionIntent: PendingIntent,
    val resultKey: String,
    val remoteInput: RemoteInput
)

```

### 3.2. Background Dispatcher (`DirectReplyReceiver.kt`)

```kotlin
package com.wristreply.app.receivers

import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat

class DirectReplyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val replyText = intent.getStringExtra("KEY_REPLY_TEXT") ?: return
        val resultKey = intent.getStringExtra("KEY_RESULT_KEY") ?: return
        val originalPendingIntent = intent.getParcelableExtra<PendingIntent>("KEY_ORIGINAL_INTENT") ?: return
        val notificationId = intent.getIntExtra("KEY_NOTIFICATION_ID", -1)

        // Build the RemoteInput results bundle
        val replyBundle = Bundle().apply {
            putCharSequence(resultKey, replyText)
        }

        val fillInIntent = Intent()
        RemoteInput.addResultsToIntent(
            arrayOf(RemoteInput.Builder(resultKey).build()),
            fillInIntent,
            replyBundle
        )

        // Execute background dispatch without opening the app or unlocking the screen
        try {
            originalPendingIntent.send(context, 0, fillInIntent)
            
            // Dismiss the notification upon successful dispatch
            if (notificationId != -1) {
                NotificationManagerCompat.from(context).cancel(notificationId)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

```

---

## 4. In-App Direct Reply: Accessibility vs. Floating Overlay vs. IME

For users without smartwatches who want suggestions directly inside messaging applications:

```
Method Comparison for In-App Injection:

1. AccessibilityService:
   [Inspect WhatsApp View Hierarchy] ──> [Find EditText] ──> [setText()]
   Status: HIGH RISK of Google Play rejection unless strictly classified as a disability tool.

2. Floating Assistive Overlay (SYSTEM_ALERT_WINDOW):
   [Detect Foreground Chat App] ──> [Draw Floating Reply Pills above Keyboard]
   Status: STABLE, compliant, highly intuitive. Tapping copies and sends via RemoteInput.

3. Custom Keyboard (IME Plugin):
   [Keyboard Suggestion Strip] ──> [Direct Commit to InputConnection]
   Status: 100% Google Play compliant, but requires the user to switch keyboards.

```

**Recommendation:** Provide both **Notification Tray Action Pills** and an optional **Floating Assistive Bubble** toggled in user settings.

---

## 5. Firebase Architecture (Zero-Login, Full Observability)

Even in an offline-first app, monitoring production crashes and battery metrics is critical.

### Firebase Initialization Strategy

* **Zero Authentication:** Do not integrate Firebase Auth.
* **Anonymous App Check / Crashlytics:** Collect anonymous crash stacks, device models, and Android OS versions.
* **Granular Analytics Events (No PII):**
* `reply_generated` (event metadata: `latency_ms`, `source_package: com.whatsapp`)
* `reply_dispatched` (event metadata: `source: watch_wear_os`, `source: watch_rtos_mirror`, `source: notification_tray`)
* **Strict Data Safety:** Ensure message texts are never passed into Firebase Analytics parameter bundles.



---

## 6. Google Play Store Console Preparation

1. **Permission Justification Form:**
* Prepare a 30-second screen capture showing incoming messages, on-device smart reply generation, and the tap-to-send action.
* State clearly: *"NotificationListenerService is strictly required to detect incoming conversational contexts and attach on-device Google ML Kit reply actions."*


2. **Data Safety Form Entries:**
* **Data Collection:** Mark **No** for personal chat contents.
* **Data Shared:** Mark **No**.
* **Diagnostics:** Mark **Yes** (Crash logs via Firebase Crashlytics, not linked to user identity).


3. **No Network Access Assurance:**
* Remove `android.permission.INTERNET` from the base engine module if Firebase is disabled, or isolate Firebase network traffic while documenting that message contents never leave device memory.



```

<FollowUp label="Want to inspect the Floating Assistive Overlay implementation using Flutter and native Kotlin?" query="Show me how to build the Floating Assistive Bubble overlay in Kotlin that appears above the keyboard in WhatsApp."/>

```