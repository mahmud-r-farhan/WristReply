---

# `dynamic_app_detection.md`

```markdown
# Dynamic App Detection & RemoteInput Resolution Engine

An architectural specification for inspecting, validating, and extracting direct-reply endpoints from any Android messaging client dynamically at runtime without package hardcoding.

---

## 1. Architectural Overview & Rationale

Hardcoding specific package identifiers (such as `com.whatsapp` or `org.telegram.messenger`) introduces three points of failure:
1. **Third-party forks & multi-accounts:** WhatsApp Business, Telegram X, cloned work-profile apps, and region-specific chat clients are excluded.
2. **Maintenance overhead:** Any package renaming or newly released messenger requires an app update on the Google Play Store.
3. **Ecosystem rigidity:** Standard SMS apps (Google Messages, Samsung Messages, MIUI Messaging) utilize disparate package namespaces across different OEMs.

### The Universal Solution: Semantic RemoteInput Inspection
Instead of filtering by package name, the engine inspects the notification's internal capability contract:
* Does the `Notification` object declare `Notification.CATEGORY_MESSAGE`?
* Does the notification expose one or more `NotificationCompat.Action` instances holding a valid `RemoteInput`?
* Is `remoteInput.resultKey` non-null and linked to a live `PendingIntent`?

If these conditions are met, the application is fundamentally capable of background text dispatch.


```

```
                      [Incoming Notification]
                                 │
                                 ▼
                 [Heuristic Category & Style Check]
                 ├── Notification.CATEGORY_MESSAGE?
                 └── Notification.MessagingStyle in extras?
                                 │
                                 ▼
                [Action Array Deep Inspection]
                                 │
              ┌──────────────────┴──────────────────┐
              │                                     │
              ▼                                     ▼
    [Standard Actions]                   [WearableExtender Actions]
    (action.remoteInputs)                (wearActions.remoteInputs)
              │                                     │
              └──────────────────┬──────────────────┘
                                 ▼
                  [Extract Target RemoteInput]
                  - Result Key: String
                  - Action Intent: PendingIntent
                  - Semantic Action: SEMANTIC_ACTION_REPLY
                                 │
                                 ▼
                  [Construct Dynamic Reply Target]

```

```

---

## 2. Core Kotlin Implementation

### 2.1 Dynamic Discovery Data Models (`DynamicReplyTarget.kt`)

```kotlin
package com.wristreply.app.engine.dynamic

import android.app.PendingIntent
import android.app.RemoteInput

data class DynamicReplyTarget(
    val packageName: String,
    val senderName: String,
    val messageText: String,
    val remoteInput: RemoteInput,
    val resultKey: String,
    val pendingIntent: PendingIntent,
    val isDirectReplyAllowed: Boolean
)

```

### 2.2 Reflection & Heuristic Extraction Engine (`DynamicNotificationInspector.kt`)

```kotlin
package com.wristreply.app.engine.dynamic

import android.app.Notification
import android.app.RemoteInput
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat

object DynamicNotificationInspector {

    /**
     * Inspects an incoming StatusBarNotification dynamically.
     * Returns a valid DynamicReplyTarget if inline reply is supported, null otherwise.
     */
    fun resolveReplyTarget(sbn: StatusBarNotification): DynamicReplyTarget? {
        val notification = sbn.notification ?: return null
        val packageName = sbn.packageName

        // Step 1: Reject ongoing, summary groups, or system background events
        if ((notification.flags and Notification.FLAG_ONGOING_EVENT) != 0 ||
            (notification.flags and Notification.FLAG_GROUP_SUMMARY) != 0
        ) {
            return null
        }

        // Step 2: Validate messaging context heuristics
        val isMessageCategory = notification.category == Notification.CATEGORY_MESSAGE
        val isMessagingStyle = notification.extras.containsKey(Notification.EXTRA_MESSAGING_STYLE_USER)
        val hasText = notification.extras.getCharSequence(Notification.EXTRA_TEXT) != null

        if (!isMessageCategory && !isMessagingStyle && !hasText) {
            return null
        }

        // Step 3: Extract Sender and Message Content
        val sender = notification.extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() 
            ?: notification.extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() 
            ?: "Unknown"

        val message = notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() 
            ?: notification.extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() 
            ?: return null

        // Step 4: Locate Direct Reply Action via standard notification actions
        var targetAction: Notification.Action? = null
        var targetRemoteInput: RemoteInput? = null

        notification.actions?.forEach { action ->
            action.remoteInputs?.forEach { input ->
                if (!input.resultKey.isNullOrEmpty() && action.actionIntent != null) {
                    targetAction = action
                    targetRemoteInput = input
                    return@forEach
                }
            }
        }

        // Step 5: Fallback to WearableExtender if not exposed in standard tray actions
        if (targetAction == null || targetRemoteInput == null) {
            val wearableExtender = NotificationCompat.WearableExtender(notification)
            wearableExtender.actions.forEach { action ->
                action.remoteInputs?.forEach { input ->
                    if (!input.resultKey.isNullOrEmpty() && action.actionIntent != null) {
                        // Bridge compat action to platform target
                        return DynamicReplyTarget(
                            packageName = packageName,
                            senderName = sender,
                            messageText = message,
                            remoteInput = RemoteInput.Builder(input.resultKey).build(),
                            resultKey = input.resultKey,
                            pendingIntent = action.actionIntent,
                            isDirectReplyAllowed = true
                        )
                    }
                }
            }
        }

        val resolvedAction = targetAction ?: return null
        val resolvedRemoteInput = targetRemoteInput ?: return null

        return DynamicReplyTarget(
            packageName = packageName,
            senderName = sender,
            messageText = message,
            remoteInput = resolvedRemoteInput,
            resultKey = resolvedRemoteInput.resultKey,
            pendingIntent = resolvedAction.actionIntent,
            isDirectReplyAllowed = true
        )
    }
}

```

---

## 3. Dynamic App Preferences & Whitelist Sync

Users still require granular control over which discovered apps are permitted to trigger Smart Reply pills.

### 3.1 App Metadata Discovery (`InstalledMessagingAppsRepository.kt`)

```kotlin
package com.wristreply.app.engine.dynamic

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.drawable.Drawable
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

data class DiscoveredAppInfo(
    val packageName: String,
    val appName: String,
    val isEnabled: Boolean
)

class InstalledMessagingAppsRepository(private val context: Context) {

    private val prefs = context.getSharedPreferences("wrist_reply_whitelist_prefs", Context.MODE_PRIVATE)

    suspend fun getInstalledMessagingClients(): List<DiscoveredAppInfo> = withContext(Dispatchers.IO) {
        val packageManager = context.packageManager
        val discoveredList = mutableListOf<DiscoveredAppInfo>()

        // Query standard SMS and Share intents to find communication clients
        val smsIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = android.net.Uri.parse("smsto:")
        }
        val resolveInfos = packageManager.queryIntentActivities(smsIntent, PackageManager.MATCH_DEFAULT_ONLY)

        val foundPackages = resolveInfos.map { it.activityInfo.packageName }.toMutableSet()
        // Include common chat packages if installed
        foundPackages.addAll(listOf("com.whatsapp", "com.facebook.orca", "org.telegram.messenger", "com.discord"))

        for (pkg in foundPackages) {
            try {
                val appInfo = packageManager.getApplicationInfo(pkg, 0)
                val label = packageManager.getApplicationLabel(appInfo).toString()
                val isWhitelisted = prefs.getBoolean(pkg, true) // Enabled by default
                discoveredList.add(DiscoveredAppInfo(pkg, label, isWhitelisted))
            } catch (_: PackageManager.NameNotFoundException) {
                // App not installed on device
            }
        }

        discoveredList.distinctBy { it.packageName }
    }

    fun isAppWhitelisted(packageName: String): Boolean {
        return prefs.getBoolean(packageName, true)
    }

    fun setAppWhitelisted(packageName: String, enabled: Boolean) {
        prefs.edit().putBoolean(packageName, enabled).apply()
    }
}

```

---

## 4. Hooking Dynamic Inspector into NotificationProcessorService

```kotlin
package com.wristreply.app.services

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.wristreply.app.engine.SmartReplyEngine
import com.wristreply.app.engine.dynamic.DynamicNotificationInspector
import com.wristreply.app.engine.dynamic.InstalledMessagingAppsRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class NotificationProcessorService : NotificationListenerService() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private lateinit var whitelistRepo: InstalledMessagingAppsRepository

    override fun onCreate() {
        super.onCreate()
        whitelistRepo = InstalledMessagingAppsRepository(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val activeSbn = sbn ?: return

        // 1. Check if user whitelisted this specific package
        if (!whitelistRepo.isAppWhitelisted(activeSbn.packageName)) {
            return
        }

        // 2. Dynamically resolve whether this notification supports inline replies
        val replyTarget = DynamicNotificationInspector.resolveReplyTarget(activeSbn) ?: return

        // 3. Process via Google ML Kit
        scope.launch {
            val suggestions = SmartReplyEngine.getSuggestions(
                message = replyTarget.messageText,
                senderId = replyTarget.senderName
            )

            if (suggestions.isNotEmpty()) {
                // 4. Inject pills directly into notification tray or wearable payload
                WearSyncService.broadcastToWatch(
                    context = applicationContext,
                    suggestions = suggestions,
                    notificationId = activeSbn.id
                )
            }
        }
    }
}

```

---

## 5. Verification Matrix for Universal App Support

| Messaging App | Package Name | Extraction Path | Verification Standard |
| --- | --- | --- | --- |
| **WhatsApp** | `com.whatsapp` | Standard `notification.actions` | Extracts `resultKey = "key_text_reply"`. |
| **Facebook Messenger** | `com.facebook.orca` | Standard `notification.actions` | Extracts RemoteInput linked to Quick Reply. |
| **Google Messages (RCS)** | `com.google.android.apps.messaging` | `MessagingStyle` + Standard Action | Direct reply functional without unlocking screen. |
| **Telegram** | `org.telegram.messenger` | Standard `notification.actions` | Instant dispatch via `PendingIntent.send()`. |
| **Signal** | `org.thoughtcrime.securesms` | Standard `notification.actions` | Local encryption maintained; OS handles dispatch. |
| **Slack / Teams** | Work namespace packages | Standard & WearableExtender | Auto-detected as valid `CATEGORY_MESSAGE`. |

```

<FollowUp label="Want to see the Flutter UI implementation for displaying discovered apps with toggle switches?" query="Show me the Flutter UI code that fetches the discovered messaging apps and allows users to toggle smart replies on or off per app."/>

```