package com.wristreply.core.receiver

import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.app.NotificationManagerCompat
import com.wristreply.core.metrics.MetricsLedger

/**
 * Executes headless background dispatch via RemoteInput when an action pill is tapped
 * on a connected smartwatch or inside the system notification tray.
 */
class ActionBroadcastReceiver : BroadcastReceiver() {

    companion object {
        const val EXTRA_REPLY_TEXT = "KEY_REPLY_TEXT"
        const val EXTRA_RESULT_KEY = "KEY_RESULT_KEY"
        const val EXTRA_ORIGINAL_INTENT = "KEY_ORIGINAL_INTENT"
        const val EXTRA_NOTIFICATION_ID = "KEY_NOTIFICATION_ID"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val replyText = intent.getStringExtra(EXTRA_REPLY_TEXT) ?: return
        val resultKey = intent.getStringExtra(EXTRA_RESULT_KEY) ?: return
        val originalPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(EXTRA_ORIGINAL_INTENT, PendingIntent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_ORIGINAL_INTENT)
        } ?: return

        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)

        val replyBundle = Bundle().apply {
            putCharSequence(resultKey, replyText)
        }

        val fillInIntent = Intent()
        val remoteInput = RemoteInput.Builder(resultKey).build()
        RemoteInput.addResultsToIntent(arrayOf(remoteInput), fillInIntent, replyBundle)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            RemoteInput.setResultsSource(fillInIntent, RemoteInput.SOURCE_FREE_FORM_INPUT)
        }

        try {
            originalPendingIntent.send(context, 0, fillInIntent)
            MetricsLedger.recordDispatch()
            if (notificationId != -1) {
                NotificationManagerCompat.from(context).cancel(notificationId)
            }
        } catch (_: Exception) {}
    }
}
