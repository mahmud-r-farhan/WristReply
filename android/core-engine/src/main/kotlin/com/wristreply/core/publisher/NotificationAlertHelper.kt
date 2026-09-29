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
 */
object NotificationAlertHelper {

    private const val ALERT_CHANNEL_ID = "wrist_reply_alerts"
    private const val ABUSE_NOTIF_ID = 9901
    private const val CLIPBOARD_NOTIF_ID = 9902

    fun ensureAlertChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                ALERT_CHANNEL_ID,
                "WristReply Alerts",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Security warnings and clipboard notices"
                setSound(null, null)
                enableVibration(false)
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            manager?.createNotificationChannel(channel)
        }
    }

    fun postAbuseWarning(context: Context, sender: String, detectedWord: String) {
        ensureAlertChannel(context)
        val builder = NotificationCompat.Builder(context, ALERT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("Inappropriate Language Shield")
            .setContentText("Flagged message from $sender (blocked token: $detectedWord)")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)

        try {
            NotificationManagerCompat.from(context).notify(ABUSE_NOTIF_ID, builder.build())
        } catch (_: SecurityException) {}
    }

    fun postCopyConfirmation(context: Context, type: TokenType, tokenValue: String) {
        ensureAlertChannel(context)
        val title = if (type == TokenType.TRANSACTION_ID) "Transaction ID Copied" else "OTP Copied"
        val builder = NotificationCompat.Builder(context, ALERT_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_save)
            .setContentTitle(title)
            .setContentText("Token $tokenValue saved to clipboard")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setTimeoutAfter(4000)
            .setAutoCancel(true)

        try {
            NotificationManagerCompat.from(context).notify(CLIPBOARD_NOTIF_ID, builder.build())
        } catch (_: SecurityException) {}
    }
}
