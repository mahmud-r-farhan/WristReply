---

# `automation.md`

```markdown
# Optional Automation Engine: Delayed Auto-Replies & Scheduled Message Triggers

This specification outlines the technical architecture, execution flow, and modular Kotlin implementation for optional message automation features. These features are decoupled from the main console screen and accessible strictly via dedicated settings sub-menus.

---

## 1. Feature Scope & Platform Feasibility

| Automation Feature | Target Platform | Technical Mechanism | Feasibility & Trade-offs |
| :--- | :--- | :--- | :--- |
| **Delayed Auto-Reply** | WhatsApp, Telegram, Google Messages, Signal | `AlarmManager.setExactAndAllowWhileIdle()` + Cached `RemoteInput` | **100% Native & Safe.** Fires auto-reply after $X$ minutes if user does not interact with notification. |
| **Scheduled Proactive Text (SMS)** | Default System SMS Provider | `SmsManager.sendTextMessage()` | **Native & Reliable.** Requires SMS send permissions; dispatches at target timestamp. |
| **Scheduled Proactive Text (WhatsApp/Chat)** | Third-Party Messaging Apps | Deep Link Intent with Confirmation Notification | **Store-Compliant Path.** Wakes up at target time, posts notification with 1-tap dispatch or opens pre-filled conversation. |

---

## 2. Delayed Auto-Reply Workflow


```

[Incoming Chat Notification]
│
▼
NotificationProcessorService ───> Checks User Automation Settings
│
├─► Feature Disabled? ──> Proceed to standard Smart Reply
│
└─► Feature Enabled?
│
▼
[DelayedReplyScheduler]
- Caches PendingIntent + ResultKey in SQLite / EncryptedPrefs
- Schedules AlarmManager wakeup (+X minutes)
│
┌───────────┴────────────────────────┐
▼                                    ▼
[User Reads/Dismisses Notification]    [Timer Expires (AlarmManager Fires)]

* Triggers onNotificationRemoved()                    │
* AlarmManager task canceled                          ▼
* No automated message sent              [ScheduledReplyReceiver]
- Builds RemoteInput Bundle
- Executes PendingIntent.send()
- Clears cache

```

---

## 3. Native Kotlin Implementation

### 3.1 Alarm Scheduler Manager (`DelayedReplyScheduler.kt`)

```kotlin
package com.wristreply.app.engine.automation

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock

object DelayedReplyScheduler {

    private const val ACTION_FIRE_DELAYED_REPLY = "com.wristreply.app.ACTION_FIRE_DELAYED_REPLY"

    fun scheduleReply(
        context: Context,
        senderId: String,
        replyText: String,
        originalPendingIntent: PendingIntent,
        resultKey: String,
        delayMinutes: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(context, ScheduledReplyReceiver::class.java).apply {
            action = ACTION_FIRE_DELAYED_REPLY
            putExtra("EXTRA_REPLY_TEXT", replyText)
            putExtra("EXTRA_RESULT_KEY", resultKey)
            putExtra("EXTRA_PENDING_INTENT", originalPendingIntent)
            putExtra("EXTRA_SENDER_ID", senderId)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            senderId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        val triggerAtMillis = SystemClock.elapsedRealtime() + (delayMinutes * 60 * 1000L)

        // Exact alarm scheduled across Doze mode states
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        }
    }

    fun cancelScheduledReply(context: Context, senderId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, ScheduledReplyReceiver::class.java).apply {
            action = ACTION_FIRE_DELAYED_REPLY
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            senderId.hashCode(),
            intent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_MUTABLE
        )
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
    }
}

```

### 3.2 Broadcast Receiver Execution (`ScheduledReplyReceiver.kt`)

```kotlin
package com.wristreply.app.engine.automation

import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle

class ScheduledReplyReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val replyText = intent.getStringExtra("EXTRA_REPLY_TEXT") ?: return
        val resultKey = intent.getStringExtra("EXTRA_RESULT_KEY") ?: return
        val originalPendingIntent = intent.getParcelableExtra<PendingIntent>("EXTRA_PENDING_INTENT") ?: return

        // Inject automated response text into the original target app bundle
        val replyBundle = Bundle().apply {
            putCharSequence(resultKey, replyText)
        }

        val fillInIntent = Intent()
        RemoteInput.addResultsToIntent(
            arrayOf(RemoteInput.Builder(resultKey).build()),
            fillInIntent,
            replyBundle
        )

        try {
            originalPendingIntent.send(context, 0, fillInIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

```

### 3.3 Cancellation Hook in `NotificationProcessorService.kt`

```kotlin
override fun onNotificationRemoved(sbn: StatusBarNotification?) {
    super.onNotificationRemoved(sbn)
    val activeSbn = sbn ?: return
    val sender = activeSbn.notification.extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: return

    // If notification was cleared or dismissed by user, cancel pending auto-reply
    DelayedReplyScheduler.cancelScheduledReply(applicationContext, sender)
}

```

---

## 4. Manifest & Play Store Compliance Boundaries

### 4.1 Permission Requirements (`AndroidManifest.xml`)

For Android 12+ (API 31+), scheduling exact alarms requires an explicit permission:

```xml
<!-- Required only if exact timer scheduling is enabled in settings -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

```

### 4.2 Guarding Exact Alarm Permission

Do not request `SCHEDULE_EXACT_ALARM` during initial onboarding. Request it dynamically only when the user explicitly toggles **"Delayed Auto-Reply"** on inside settings. If denied by the user, gracefully downgrade to inexact alarms using `AlarmManager.setAndAllowWhileIdle()`.

---

## 5. UI/UX Settings Hierarchy (Isolated from Main Dashboard)

The main console remains uncluttered. All automation options are sequestered in an **Advanced Automations** settings sub-screen:

```
[Main Cockpit Dashboard]
         └── [Settings Gear Icon]
                   └── [Advanced Automation Rules (Sub-Page)]
                             ├── Section: Delayed Auto-Reply
                             │     ├── Master Toggle [ON / OFF]
                             │     ├── Target Sender Filter (Specific Contacts)
                             │     ├── Delay Duration Slider (1 min to 30 min)
                             │     └── Response Template ("Busy, will call you soon")
                             │
                             └── Section: Scheduled Reminders
                                   ├── Scheduled Alerts Notification
                                   └── Quick-Launch DeepLink Templates

```

```

If notification dismiss or anything else should simply dismiss the automation task! and shows a notification to the users.

Based on the all docs and the app, think and implement real world problems solutionable automation.

```