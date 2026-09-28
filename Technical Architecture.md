3. High-Level Technical Architecture
[Flutter UI Layer (Dart)]
   ├── Settings, Whitelist Apps, Persona Customization
   ├── Onboarding & Permission Handshake
   └── Platform Channel Bridge (MethodChannel / EventChannel)
               │
               ▼
[Android Native Engine (Kotlin)]
   ├── NotificationListenerService (android.service.notification)
   │     └── Extracts RemoteInput & Active Notification Bundles
   │
   ├── MLKitEngine
   │     └── com.google.mlkit.nl.smartreply.SmartReply
   │     └── Runs 100% On-Device (No INTERNET permission required)
   │
   ├── NotificationDispatcher
   │     └── Injects Smart Reply Actions into Custom Notification
   │     └── Triggers PendingIntent.send() via RemoteInput
   │
   └── WearSyncService (Google Play Services Wearable)
         └── DataClient / MessageClient sends Reply Pills to Wear OS
4. Native Kotlin Core Implementation Blueprint
4.1. NotificationListenerService (SmartReplyListenerService.kt)
Kotlin
package com.wristreply.app

import android.app.Notification
import android.app.RemoteInput
import android.content.Intent
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import com.google.mlkit.nl.smartreply.SmartReply
import com.google.mlkit.nl.smartreply.TextMessage

class SmartReplyListenerService : NotificationListenerService() {

    private val smartReplyGenerator = SmartReply.getClient()
    private val conversationHistory = ArrayList<TextMessage>()

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val packageName = sbn.packageName
        // Filter supported apps (WhatsApp, Telegram, etc.)
        if (!isSupportedPackage(packageName)) return

        val extras = sbn.notification.extras
        val messageText = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: return
        val sender = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: "User"

        // 1. Add context to ML Kit
        conversationHistory.add(
            TextMessage.createForRemoteUser(messageText, System.currentTimeMillis(), sender)
        )

        // 2. Generate on-device smart replies
        smartReplyGenerator.suggestReplies(conversationHistory)
            .addOnSuccessListener { result ->
                val suggestions = result.suggestions.map { it.text }
                if (suggestions.isNotEmpty()) {
                    // Extract Quick Reply Action
                    val remoteInputPair = extractRemoteInput(sbn.notification)
                    if (remoteInputPair != null) {
                        dispatchSmartReplyNotification(sbn, suggestions, remoteInputPair)
                        syncWithWearable(sbn.id, suggestions)
                    }
                }
            }
    }

    private fun isSupportedPackage(pkg: String): Boolean {
        return pkg in listOf("com.whatsapp", "org.telegram.messenger")
    }

    private fun extractRemoteInput(notification: Notification): Pair<Notification.Action, RemoteInput>? {
        notification.actions?.forEach { action ->
            action.remoteInputs?.forEach { remoteInput ->
                if (remoteInput.resultKey != null) {
                    return Pair(action, remoteInput)
                }
            }
        }
        return null
    }

    private fun dispatchSmartReplyNotification(
        sbn: StatusBarNotification,
        suggestions: List<String>,
        replyPair: Pair<Notification.Action, RemoteInput>
    ) {
        // Build interactive reply pills inside system notification shade
    }

    private fun syncWithWearable(notificationId: Int, suggestions: List<String>) {
        // Send payload via Wearable.getMessageClient(this)
    }
}
4.2. Instant Reply Dispatcher (ReplyActionReceiver.kt)
Kotlin
package com.wristreply.app

import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle

class ReplyActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val replyText = intent.getStringExtra("EXTRA_REPLY_TEXT") ?: return
        val originalPendingIntent = intent.getParcelableExtra<android.app.PendingIntent>("EXTRA_PENDING_INTENT") ?: return
        val resultKey = intent.getStringExtra("EXTRA_RESULT_KEY") ?: return

        // Inject reply into RemoteInput bundle
        val replyBundle = Bundle().apply {
            putCharSequence(resultKey, replyText)
        }

        val fillInIntent = Intent()
        RemoteInput.addResultsToIntent(
            arrayOf(RemoteInput.Builder(resultKey).build()),
            fillInIntent,
            replyBundle
        )

        // Send back to WhatsApp / Telegram directly in background
        try {
            originalPendingIntent.send(context, 0, fillInIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
5. Google Play Console Compliance & Safety Checklist
Declared Permissions (AndroidManifest.xml):

android.permission.BIND_NOTIFICATION_LISTENER_SERVICE

android.permission.WAKE_LOCK

android.permission.BLUETOOTH_CONNECT (Android 12+)

(গুরুত্বপূর্ণ: ইন্টারনেট পারমিশন android.permission.INTERNET না রাখলে প্লে স্টোরে সহজে বিশ্বাসযোগ্যতা অর্জন করা যায় যে ডেটা চুরি হচ্ছে না।)

In-App Prominent Disclosure:

অ্যাপের প্রথম স্ক্রিনে বড় করে ডায়লগ বা অনবোর্ডিং কার্ড দেখাতে হবে, যেখানে উল্লেখ থাকবে নোটিফিকেশন অ্যাক্সেসের উদ্দেশ্য শুধুই মেসেজ অটোমেশন।

Privacy Policy Requirement:

প্রাইভেসি পলিসিতে স্পষ্ট করে লিখতে হবে: "WristReply does not transmit, store, or sell user chat contents. All language analysis is handled locally on the device using Google ML Kit."