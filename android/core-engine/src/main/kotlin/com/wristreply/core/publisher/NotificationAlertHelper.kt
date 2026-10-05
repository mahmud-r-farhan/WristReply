package com.wristreply.core.publisher

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.wristreply.core.model.TokenType

/**
 * Dispatches non-intrusive alert pills for abusive content warnings
 * and smart clipboard auto-copy confirmations.
 *
 * The helper exposes two static notification IDs so subsequent calls
 * replace the previous notification rather than stacking up.
 */
object NotificationAlertHelper {

    private const val ALERT_CHANNEL_ID = "wrist_reply_alerts"
    private const val ALERT_CHANNEL_NAME = "WristReply Alerts"
    private const val ALERT_CHANNEL_DESCRIPTION = "Security warnings and clipboard notices"
    private const val ABUSE_NOTIF_ID = 9901
    private const val CLIPBOARD_NOTIF_ID = 9902

    @Volatile
    private var channelRegistered = false

    /**
     * Idempotent channel registration. Call from anywhere — it short-circuits
     * after the first successful run.
     */
    fun ensureAlertChannel(context: Context) {
        if (channelRegistered) return
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            channelRegistered = true
            return
        }
        val channel = NotificationChannel(
            ALERT_CHANNEL_ID,
            ALERT_CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = ALERT_CHANNEL_DESCRIPTION
            setSound(null, null)
            enableVibration(false)
            enableLights(false)
            setShowBadge(false)
        }
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.createNotificationChannel(channel)
        channelRegistered = true
    }

    fun postAbuseWarning(context: Context, sender: String, detectedWord: String) {
        val prefsCache = com.wristreply.core.cache.UserPreferencesHotCache(context)
        if (!prefsCache.isNotificationsEnabled()) return

        ensureAlertChannel(context)
        val builder = NotificationCompat.Builder(context, ALERT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Inappropriate Language Shield")
            .setContentText("Flagged message from $sender (blocked token: $detectedWord)")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)

        try {
            NotificationManagerCompat.from(context).notify(ABUSE_NOTIF_ID, builder.build())
        } catch (_: SecurityException) {
            // Notification permission revoked mid-session.
        }
    }

    fun postCopyConfirmation(context: Context, type: TokenType, tokenValue: String) {
        val prefsCache = com.wristreply.core.cache.UserPreferencesHotCache(context)
        if (!prefsCache.isNotificationsEnabled()) return

        ensureAlertChannel(context)
        val title = if (type == TokenType.TRANSACTION_ID) "Transaction ID Copied" else "OTP Copied"
        val builder = NotificationCompat.Builder(context, ALERT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_save)
            .setContentTitle(title)
            .setContentText("Token $tokenValue saved to clipboard")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setTimeoutAfter(4000)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)

        try {
            NotificationManagerCompat.from(context).notify(CLIPBOARD_NOTIF_ID, builder.build())
        } catch (_: SecurityException) {
            // Notification permission revoked mid-session.
        }
    }
}
