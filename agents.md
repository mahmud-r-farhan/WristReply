---

# `agents.md`

```markdown
# AGENT SPECIFICATION: WristReply AI
**A Zero-Cloud, High-Performance Smart Reply Engine for Android & Wear OS**

---

## 1. System Design & Architectural Topology


```

```
              ┌───────────────────────────────────────────┐
              │          Android System Broadcast         │
              │       (Incoming Notification Stream)      │
              └─────────────────────┬─────────────────────┘
                                    │
                                    ▼
              ┌───────────────────────────────────────────┐
              │    Core Native Service (Kotlin Engine)    │
              │     - NotificationListenerService         │
              │     - Extract RemoteInput & MetaData      │
              └──────────────┬────────────────────────────┘
                             │
             ┌───────────────┴───────────────┐
             ▼                               ▼

```

┌─────────────────────────────┐ ┌─────────────────────────────┐
│   On-Device ML Kit Engine   │ │     Wearable Data Layer     │
│ - Conversational Context    │ │ - NodeClient & MessageClient│
│ - Local SmartReply Model    │ │ - Low-Latency Sync via BLE  │
└──────────────┬──────────────┘ └──────────────┬──────────────┘
│                               │
└───────────────┬───────────────┘
▼
┌───────────────────────────────────────────┐
│       RemoteInput Intent Dispatcher       │
│ - Re-construct RemoteInput Bundle         │
│ - PendingIntent.send() (Zero Unlock)      │
└─────────────────────┬─────────────────────┘
│
▼
┌───────────────────────────────────────────┐
│           Flutter Client UI               │
│ - Granular Whitelist & Permission Sync    │
│ - Atomic Modular Widgets & State Mgmt     │
└───────────────────────────────────────────┘

```

---

## 2. Directory Structure

```text
wrist_reply/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/com/wristreply/app/
│           ├── MainActivity.kt
│           ├── bridge/
│           │   └── NativeBridgeHandler.kt
│           ├── engine/
│           │   ├── SmartReplyEngine.kt
│           │   └── RemoteInputDispatcher.kt
│           └── services/
│               ├── NotificationProcessorService.kt
│               └── WearSyncService.kt
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   ├── platform/
│   │   │   └── native_channel.dart
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── models/
│   │   │   │   └── app_rule_model.dart
│   │   │   ├── providers/
│   │   │   │   └── service_state_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── metrics_card.dart
│   │   │       ├── permission_banner.dart
│   │   │       ├── reply_pill_preview.dart
│   │   │       └── toggle_switch_tile.dart
│   └── shared/
│       └── widgets/
│           ├── custom_app_bar.dart
│           └── state_badge.dart
└── pubspec.yaml

```

---

## 3. Native Engine Implementation (Kotlin)

### 3.1 `AndroidManifest.xml`

```xml
<manifest xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)"
    package="com.wristreply.app">

    <!-- Essential Permissions: Zero Cloud / No INTERNET required -->
    <uses-permission android:name="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <application
        android:label="WristReply"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Notification Interception Service -->
        <service
            android:name=".services.NotificationProcessorService"
            android:label="WristReply Notification Engine"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>

```

### 3.2 ML Kit Smart Reply Engine (`SmartReplyEngine.kt`)

```kotlin
package com.wristreply.app.engine

import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.SmartReplyGenerator
import com.google.mlkit.nl.smartreply.TextMessage
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

object SmartReplyEngine {
    private val client: SmartReplyGenerator = SmartReply.getClient()

    suspend fun getSuggestions(
        message: String,
        senderId: String,
        timestamp: Long = System.currentTimeMillis()
    ): List<String> = suspendCancellableCoroutine { continuation ->
        val conversation = listOf(
            TextMessage.createForRemoteUser(message, timestamp, senderId)
        )

        client.suggestReplies(conversation)
            .addOnSuccessListener { result ->
                val replies = result.suggestions.map { it.text }
                continuation.resume(replies)
            }
            .addOnFailureListener {
                continuation.resume(emptyList())
            }
    }
}

```

### 3.3 RemoteInput Injector (`RemoteInputDispatcher.kt`)

```kotlin
package com.wristreply.app.engine

import android.app.Notification
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.Context
import android.content.Intent
import android.os.Bundle

data class ReplyContext(
    val pendingIntent: PendingIntent,
    val remoteInput: RemoteInput
)

object RemoteInputDispatcher {

    fun extractReplyContext(notification: Notification): ReplyContext? {
        val actions = notification.actions ?: return null
        for (action in actions) {
            val inputs = action.remoteInputs ?: continue
            for (input in inputs) {
                if (input.resultKey != null && action.actionIntent != null) {
                    return ReplyContext(action.actionIntent, input)
                }
            }
        }
        return null
    }

    fun dispatchReply(context: Context, replyContext: ReplyContext, replyText: String): Boolean {
        return try {
            val bundle = Bundle().apply {
                putCharSequence(replyContext.remoteInput.resultKey, replyText)
            }
            val intent = Intent()
            RemoteInput.addResultsToIntent(arrayOf(replyContext.remoteInput), intent, bundle)
            replyContext.pendingIntent.send(context, 0, intent)
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

```

### 3.4 Notification Processor Service (`NotificationProcessorService.kt`)

```kotlin
package com.wristreply.app.services

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.wristreply.app.engine.RemoteInputDispatcher
import com.wristreply.app.engine.SmartReplyEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class NotificationProcessorService : NotificationListenerService() {

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        val activeSbn = sbn ?: return

        val pkg = activeSbn.packageName
        if (!isWhitelisted(pkg)) return

        val extras = activeSbn.notification.extras
        val body = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return
        val sender = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: "Sender"

        val replyContext = RemoteInputDispatcher.extractReplyContext(activeSbn.notification) ?: return

        serviceScope.launch {
            val suggestions = SmartReplyEngine.getSuggestions(body, sender)
            if (suggestions.isNotEmpty()) {
                WearSyncService.broadcastToWatch(applicationContext, suggestions, activeSbn.id)
            }
        }
    }

    private fun isWhitelisted(packageName: String): Boolean {
        val targets = setOf("com.whatsapp", "org.telegram.messenger", "com.google.android.apps.messaging")
        return targets.contains(packageName)
    }
}

```

### 3.5 Wear Sync Service (`WearSyncService.kt`)

```kotlin
package com.wristreply.app.services

import android.content.Context
import com.google.android.gms.wearable.Wearable
import org.json.JSONArray
import org.json.JSONObject

object WearSyncService {
    private const val REPLIES_PATH = "/smart_replies"

    fun broadcastToWatch(context: Context, suggestions: List<String>, notificationId: Int) {
        val client = Wearable.getMessageClient(context)
        val nodeClient = Wearable.getNodeClient(context)

        val payload = JSONObject().apply {
            put("notificationId", notificationId)
            put("replies", JSONArray(suggestions))
        }.toString().toByteArray(Charsets.UTF_8)

        nodeClient.connectedNodes.addOnSuccessListener { nodes ->
            for (node in nodes) {
                client.sendMessage(node.id, REPLIES_PATH, payload)
            }
        }
    }
}

```

---

## 4. Flutter Modular Architecture & Atomic Widgets

### 4.1 Platform Channel Gateway (`lib/core/platform/native_channel.dart`)

```dart
import 'package:flutter/services.dart';

class NativeChannel {
  static const MethodChannel _methodChannel = MethodChannel('com.wristreply.app/engine');

  static Future<bool> isNotificationAccessGranted() async {
    try {
      final bool granted = await _methodChannel.invokeMethod('isPermissionGranted');
      return granted;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openNotificationAccessSettings() async {
    try {
      await _methodChannel.invokeMethod('openSettings');
    } on PlatformException catch (e) {
      throw Exception('Failed to navigate: ${e.message}');
    }
  }
}

```

### 4.2 State Badge (`lib/shared/widgets/state_badge.dart`)

```dart
import 'package:flutter/material.dart';

class StateBadge extends StatelessWidget {
  final String label;
  final bool isActive;

  const StateBadge({
    super.key,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.emerald : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

```

### 4.3 Interactive Pill Widget (`lib/features/dashboard/widgets/reply_pill_preview.dart`)

```dart
import 'package:flutter/material.dart';

class ReplyPillPreview extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ReplyPillPreview({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

```

### 4.4 Metrics Summary Card (`lib/features/dashboard/widgets/metrics_card.dart`)

```dart
import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MetricsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

```

### 4.5 Permission Status Banner (`lib/features/dashboard/widgets/permission_banner.dart`)

```dart
import 'package:flutter/material.dart';

class PermissionBanner extends StatelessWidget {
  final bool hasPermission;
  final VoidCallback onResolve;

  const PermissionBanner({
    super.key,
    required this.hasPermission,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPermission) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notification access is required to generate smart suggestions.',
              style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onResolve,
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

```

### 4.6 Main Dashboard Screen (`lib/features/dashboard/screens/dashboard_screen.dart`)

```dart
import 'package:flutter/material.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/state_badge.dart';
import '../widgets/metrics_card.dart';
import '../widgets/permission_banner.dart';
import '../widgets/reply_pill_preview.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NativeChannel.isNotificationAccessGranted();
    setState(() => _isGranted = granted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WristReply Console'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: StateBadge(
                label: _isGranted ? 'Engine Active' : 'Suspended',
                isActive: _isGranted,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          PermissionBanner(
            hasPermission: _isGranted,
            onResolve: () async {
              await NativeChannel.openNotificationAccessSettings();
              await _checkPermission();
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: const [
                MetricsCard(title: 'Replies Generated', value: '428', icon: Icons.bolt),
                MetricsCard(title: 'Avg Latency', value: '180ms', icon: Icons.timer),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Live Pill Preview', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ReplyPillPreview(text: 'On my way!', onTap: () {}),
                ReplyPillPreview(text: 'Let\'s catch up later.', onTap: () {}),
                ReplyPillPreview(text: 'Can you call me?', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

```

---

## 5. Google Play Console Compliance Strategy

| Compliance Vector | Implementation Standard |
| --- | --- |
| **Data Safety Declaration** | Select **"No data collected or shared"**. Because all inputs are fed into the on-device ML Kit model, no network requests are dispatched. |
| **Zero Internet Privilege** | Omit `android.permission.INTERNET` from `AndroidManifest.xml` entirely to prove zero egress capability to Google Policy review. |
| **Prominent In-App Disclosure** | Display an un-dismissible onboarding dialog prior to routing users to system `ACTION_NOTIFICATION_LISTENER_SETTINGS`. |
| **Background Service Execution** | Implement foreground priority mechanisms only when active wearable sessions are established, complying with Android 14+ policies. |

```

<FollowUp label="Would you like the complete Wear OS Jetpack Compose companion module?" query="Provide the complete Wear OS Jetpack Compose companion module code to receive and render the smart reply pills on the watch."/>

```

com.google.mlkit:smart-reply:17.0.4 ?  https://developers.google.com/ml-kit/language/smart-reply
https://developers.google.com/ml-kit/language/translation

https://developers.google.com/ml-kit/language/identification
https://developers.google.com/ml-kit/genai/summarization/android
https://developers.google.com/ml-kit/genai/proofreading/android

https://developers.google.com/ml-kit/genai/rewriting/android

https://developers.google.com/ml-kit/genai/prompt/android

