package com.wristreply.core.automation

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock

/**
 * Schedules delayed auto-replies using exact/inexact Android AlarmManager triggers.
 * Automatically canceled if the user reads or dismisses the notification first.
 */
object DelayedReplyScheduler {

    const val ACTION_FIRE_DELAYED_REPLY = "com.wristreply.core.ACTION_FIRE_DELAYED_REPLY"

    fun scheduleReply(
        context: Context,
        senderId: String,
        replyText: String,
        originalPendingIntent: PendingIntent,
        resultKey: String,
        delayMinutes: Int
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return

        val intent = Intent(context, ScheduledReplyReceiver::class.java).apply {
            action = ACTION_FIRE_DELAYED_REPLY
            putExtra("EXTRA_REPLY_TEXT", replyText)
            putExtra("EXTRA_RESULT_KEY", resultKey)
            putExtra("EXTRA_PENDING_INTENT", originalPendingIntent)
            putExtra("EXTRA_SENDER_ID", senderId)
        }

        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        val pendingIntent = PendingIntent.getBroadcast(context, senderId.hashCode(), intent, flags)
        val triggerAtMillis = SystemClock.elapsedRealtime() + (delayMinutes * 60 * 1000L)

        try {
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
        } catch (_: SecurityException) {
            // Fallback for Android 12+ if SCHEDULE_EXACT_ALARM is not granted
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        }
    }

    fun cancelScheduledReply(context: Context, senderId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, ScheduledReplyReceiver::class.java).apply {
            action = ACTION_FIRE_DELAYED_REPLY
        }
        val flags = PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_MUTABLE
        val pendingIntent = PendingIntent.getBroadcast(context, senderId.hashCode(), intent, flags)
        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
        }
    }
}
