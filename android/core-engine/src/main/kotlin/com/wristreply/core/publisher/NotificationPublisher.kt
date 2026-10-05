package com.wristreply.core.publisher

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.wristreply.core.guard.ReadActionResolver
import com.wristreply.core.inspector.NotificationGate
import com.wristreply.core.model.DynamicReplyTarget
import com.wristreply.core.nlp.LocationPillResolver
import com.wristreply.core.receiver.ActionBroadcastReceiver
import java.util.concurrent.ConcurrentLinkedQueue

/**
 * Publishes silent companion notifications containing interactive Smart Reply pills.
 *
 * Guarantees:
 *  - IMPORTANCE_LOW channel → zero sound, zero vibration, no badge.
 *  - Per-process cap on simultaneous companions to avoid notification spam.
 *  - Each tap routes through [ActionBroadcastReceiver] which dispatches via
 *    the original messaging app's PendingIntent (no UI launch required).
 */
object NotificationPublisher {

    const val CHANNEL_ID = "smart_reply_channel"
    private const val CHANNEL_NAME = "Smart Reply Actions"
    private const val CHANNEL_DESCRIPTION = "Silent contextual quick reply pills"
    private const val MAX_LIVE_COMPANIONS = 3

    private val liveCompanionIds = ConcurrentLinkedQueue<Int>()
    @Volatile
    private var channelRegistered = false

    fun ensureChannel(context: Context) {
        if (channelRegistered) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            channelRegistered = true
            return
        }
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = CHANNEL_DESCRIPTION
            setSound(null, null)
            enableVibration(false)
            enableLights(false)
            setShowBadge(false)
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.createNotificationChannel(channel)
        channelRegistered = true
    }

    /**
     * Renders a silent companion notification containing interactive smart-reply
     * pills for the supplied [suggestions]. Each pill tap dispatches the
     * underlying [PendingIntent] via [ActionBroadcastReceiver].
     */
    fun publishPills(
        context: Context,
        notificationId: Int,
        target: DynamicReplyTarget,
        suggestions: List<String>,
        readAction: android.app.Notification.Action? = null,
        isPrivacyMode: Boolean = false,
        appendLocationPin: Boolean = false
    ) {
        val prefsCache = com.wristreply.core.cache.UserPreferencesHotCache(context)
        if (!prefsCache.isNotificationsEnabled()) return
        if (suggestions.isEmpty()) return

        ensureChannel(context)
        val displayText = if (isPrivacyMode) "••••••••••" else target.messageText

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setContentTitle(target.senderName)
            .setContentText(displayText)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)

        target.groupKey?.let { builder.setGroup(it) }

        val extras = Bundle().apply {
            putBoolean(NotificationGate.EXTRA_IS_WRIST_REPLY, true)
            putString("KEY_SOURCE_PACKAGE", target.packageName)
        }
        builder.addExtras(extras)

        // Cap at 5 pills (Wear OS comfortably renders that on most screens).
        val maxPills = prefsCache.getPillsPerMessage().coerceIn(1, 5)
        val pills = suggestions.take(maxPills).toMutableList()
        if (appendLocationPin) {
            LocationPillResolver.resolveLocationPill(target.messageText)?.let { locPill ->
                pills.add(locPill)
            }
        }

        pills.forEachIndexed { index, pillText ->
            val truncated = if (pillText.length > 25) pillText.take(24) + "…" else pillText
            val intent = Intent(context, ActionBroadcastReceiver::class.java).apply {
                putExtra(ActionBroadcastReceiver.EXTRA_REPLY_TEXT, pillText)
                putExtra(ActionBroadcastReceiver.EXTRA_RESULT_KEY, target.resultKey)
                putExtra(ActionBroadcastReceiver.EXTRA_ORIGINAL_INTENT, target.pendingIntent)
                putExtra(ActionBroadcastReceiver.EXTRA_NOTIFICATION_ID, notificationId)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                notificationId * 10 + index,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            builder.addAction(NotificationCompat.Action.Builder(0, truncated, pendingIntent).build())
        }

        readAction?.let { builder.addAction(ReadActionResolver.buildReadPill(it)) }

        // Evict older companions if the threshold is exceeded.
        while (liveCompanionIds.size >= MAX_LIVE_COMPANIONS) {
            val oldId = liveCompanionIds.poll() ?: break
            try {
                NotificationManagerCompat.from(context).cancel(oldId)
            } catch (_: SecurityException) {}
        }

        try {
            NotificationManagerCompat.from(context).notify(notificationId, builder.build())
            liveCompanionIds.add(notificationId)
        } catch (_: SecurityException) {
            // POST_NOTIFICATIONS revoked between channel creation and notify.
        }
    }

    fun cancelCompanion(context: Context, notificationId: Int) {
        liveCompanionIds.remove(notificationId)
        try {
            NotificationManagerCompat.from(context).cancel(notificationId)
        } catch (_: SecurityException) {}
    }

    /** Number of currently active companions, exposed for diagnostics. */
    fun activeCompanionCount(): Int = liveCompanionIds.size
}
