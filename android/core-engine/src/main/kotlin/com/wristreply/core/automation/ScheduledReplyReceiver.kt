package com.wristreply.core.automation

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat

/**
 * Executes scheduled automated replies via RemoteInput and notifies the user.
 */
class ScheduledReplyReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != DelayedReplyScheduler.ACTION_FIRE_DELAYED_REPLY) return

        val replyText = intent.getStringExtra("EXTRA_REPLY_TEXT") ?: return
        val resultKey = intent.getStringExtra("EXTRA_RESULT_KEY") ?: return
        val senderId = intent.getStringExtra("EXTRA_SENDER_ID") ?: "Chat"
        val originalPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra("EXTRA_PENDING_INTENT", PendingIntent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra("EXTRA_PENDING_INTENT")
        } ?: return

        // 1. Package response into RemoteInput bundle
        val replyBundle = Bundle().apply {
            putCharSequence(resultKey, replyText)
        }
        val fillInIntent = Intent()
        RemoteInput.addResultsToIntent(
            arrayOf(RemoteInput.Builder(resultKey).build()),
            fillInIntent,
            replyBundle
        )

        // 2. Dispatch headless reply
        try {
            originalPendingIntent.send(context, 0, fillInIntent)
            showAutomationNotification(context, senderId, replyText)
        } catch (_: Exception) {}
    }

    private fun showAutomationNotification(context: Context, sender: String, text: String) {
        val channelId = "wrist_reply_automation_channel"
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Automated Responses",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Confirms automated responses dispatched when busy"
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setContentTitle("Automated Reply Dispatched")
            .setContentText("Sent \"$text\" to $sender")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .build()

        manager.notify(sender.hashCode(), notification)
    }
}
