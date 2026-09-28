# Advanced Optimization: Debounce Batching, Direct "Mark as Read", and Battery Sleep Window

This specification details the implementation of three high-impact optimizations for the notification processing daemon:
1. **Debounced Burst Ingestion (Anti-Spam Batching)**
2. **One-Tap "Mark as Read" Intent Passthrough**
3. **Chrono/DND Sleep Window (Zero-Wake Daemon State)**

---

## 1. Debounced Burst Ingestion Engine

### 1.1 The Problem
Group chats or active contacts often transmit rapid bursts of single-line fragments:
* "Hey" (00.10s)
* "Free now?" (00.12s)
* "Where are you?" (00.14s)

Triggering an on-device NLP model on every single fragment causes CPU throttling, rapid battery depletion, and excessive notification rebuilds.

### 1.2 Pipeline Architecture


```

[Incoming Fragment Alerts]
│
▼
[Sender Identifier Token]
│
├── Active Job Running? ──► Cancel Previous Coroutine
│
▼
[Append Text to Sender Buffer]
│
▼
[Delay Coroutine: 2500ms Window]
│
├─► New message arrives? ──► Reset timer to 2500ms
│
└─► Timer expires? ──► Flatten Context ──► ML Kit Inference

```

### 1.3 Implementation (`MessageDebounceBuffer.kt`)

```kotlin
package com.wristreply.app.engine.buffer

import com.wristreply.app.engine.SmartReplyEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

data class BufferedMessage(
    val text: String,
    val timestamp: Long
)

object MessageDebounceBuffer {

    private const val DEBOUNCE_DELAY_MS = 2500L
    private val debounceJobs = ConcurrentHashMap<String, Job>()
    private val conversationWindows = ConcurrentHashMap<String, MutableList<BufferedMessage>>()

    fun enqueueMessage(
        scope: CoroutineScope,
        senderId: String,
        messageText: String,
        onBatchReady: (combinedContext: String) -> Unit
    ) {
        // Append incoming text segment into memory cache
        val currentBuffer = conversationWindows.getOrPut(senderId) { mutableListOf() }
        synchronized(currentBuffer) {
            currentBuffer.add(BufferedMessage(messageText, System.currentTimeMillis()))
            if (currentBuffer.size > 5) currentBuffer.removeAt(0) // Retain only latest 5 segments
        }

        // Cancel previous pending dispatch job for this sender
        debounceJobs[senderId]?.cancel()

        // Schedule consolidated processing
        debounceJobs[senderId] = scope.launch(Dispatchers.Default) {
            delay(DEBOUNCE_DELAY_MS)

            val aggregatedText = synchronized(currentBuffer) {
                currentBuffer.joinToString(" ") { it.text }
            }

            onBatchReady(aggregatedText)
            debounceJobs.remove(senderId)
        }
    }

    fun clearBuffer(senderId: String) {
        debounceJobs[senderId]?.cancel()
        debounceJobs.remove(senderId)
        conversationWindows.remove(senderId)
    }
}

```

---

## 2. One-Tap "Mark as Read" Extraction & Injection

### 2.1 Technical Mechanism

Many conversational notifications do not require a textual response. Major messaging platforms (WhatsApp, Telegram, Google Messages) bundle a semantic read action within their notification action hierarchy. The engine extracts this action and exposes it as a distinct `[✓ Read]` pill alongside the ML Kit suggestions.

### 2.2 Extraction Logic (`ReadActionResolver.kt`)

```kotlin
package com.wristreply.app.engine.actions

import android.app.Notification
import android.app.PendingIntent
import androidx.core.app.NotificationCompat

object ReadActionResolver {

    private val READ_KEYWORDS = setOf("read", "mark as read", "seen", "dismiss")

    fun extractMarkAsReadAction(notification: Notification): Notification.Action? {
        val actions = notification.actions ?: return null

        for (action in actions) {
            // Check semantic action flag (Android P / API 28+)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                if (action.semanticAction == Notification.Action.SEMANTIC_ACTION_MARK_AS_READ) {
                    return action
                }
            }

            // Fallback: Label inspection
            val label = action.title?.toString()?.lowercase() ?: continue
            if (READ_KEYWORDS.any { label.contains(it) }) {
                return action
            }
        }
        return null
    }

    fun buildReadPill(action: Notification.Action): NotificationCompat.Action {
        return NotificationCompat.Action.Builder(
            0,
            "✓ Read",
            action.actionIntent
        ).build()
    }
}

```

---

## 3. Battery Saver Smart Sleep Window (Chrono/DND Gate)

### 3.1 Zero-Wake Daemon State

To preserve battery overnight or during user downtime, the engine passes each notification through a sleep evaluation gate before invoking ML Kit inference or disk I/O.

```
Incoming Alert ──► [Is Sleep Window Active?] ──YES──► [Drop / No-Op (0% CPU)]
                         │
                        NO
                         │
                         ▼
                [Is System DND Active?] ───────YES──► [Drop / No-Op (0% CPU)]
                         │
                        NO
                         │
                         ▼
               Continue Processing

```

### 3.2 Gate Implementation (`SleepWindowGate.kt`)

```kotlin
package com.wristreply.app.engine.guard

import android.app.NotificationManager
import android.content.Context
import java.util.Calendar

object SleepWindowGate {

    fun shouldSuppressProcessing(context: Context): Boolean {
        val prefs = context.getSharedPreferences("wrist_reply_sleep_prefs", Context.MODE_PRIVATE)

        // 1. Check Do Not Disturb (DND) state
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val dndState = notificationManager.currentInterruptionFilter
        val isDndSuppressed = dndState != NotificationManager.INTERRUPTION_FILTER_ALL
        val respectDnd = prefs.getBoolean("respect_dnd_enabled", true)

        if (respectDnd && isDndSuppressed) {
            return true
        }

        // 2. Evaluate Scheduled Sleep Window (e.g., 01:00 to 06:30)
        val isSleepWindowEnabled = prefs.getBoolean("sleep_window_enabled", false)
        if (!isSleepWindowEnabled) {
            return false
        }

        val startHour = prefs.getInt("sleep_start_hour", 1)   // 1 AM
        val startMinute = prefs.getInt("sleep_start_minute", 0)
        val endHour = prefs.getInt("sleep_end_hour", 6)       // 6 AM
        val endMinute = prefs.getInt("sleep_end_minute", 30)

        val calendar = Calendar.getInstance()
        val currentMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)
        val startMinutes = startHour * 60 + startMinute
        val endMinutes = endHour * 60 + endMinute

        return if (startMinutes < endMinutes) {
            currentMinutes in startMinutes..endMinutes
        } else {
            // Window crosses midnight
            currentMinutes >= startMinutes || currentMinutes <= endMinutes
        }
    }
}

```

---

## 4. Hooking the Modules into `NotificationProcessorService`

```kotlin
override fun onNotificationPosted(sbn: StatusBarNotification?) {
    super.onNotificationPosted(sbn)
    val activeSbn = sbn ?: return

    // Gate 1: Check Sleep & DND status
    if (SleepWindowGate.shouldSuppressProcessing(applicationContext)) {
        return
    }

    // Gate 2: Extract Reply Target
    val replyTarget = DynamicNotificationInspector.resolveReplyTarget(activeSbn) ?: return

    // Extract Read Action if exposed by the host app
    val readAction = ReadActionResolver.extractMarkAsReadAction(activeSbn.notification)

    // Gate 3: Enqueue in Debounce Batch Buffer
    MessageDebounceBuffer.enqueueMessage(
        scope = serviceScope,
        senderId = replyTarget.senderName,
        messageText = replyTarget.messageText
    ) { combinedMessage ->
        // Executes strictly once after incoming messages settle
        serviceScope.launch {
            val suggestions = SmartReplyEngine.getSuggestions(combinedMessage, replyTarget.senderName)
            
            // Build notification with Smart Reply pills + optional [✓ Read] pill
            PillInjectionService.injectPills(
                context = applicationContext,
                notificationId = activeSbn.id,
                target = replyTarget,
                suggestions = suggestions,
                readAction = readAction
            )
        }
    }
}

```
