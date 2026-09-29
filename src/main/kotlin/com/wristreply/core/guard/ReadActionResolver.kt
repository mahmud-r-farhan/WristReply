package com.wristreply.core.guard

import android.app.Notification
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * Extracts and surfaces one-tap "Mark as Read" actions exposed by messaging hosts.
 */
object ReadActionResolver {

    private val READ_KEYWORDS = setOf("read", "mark as read", "seen", "dismiss")

    fun extractMarkAsReadAction(notification: Notification?): Notification.Action? {
        val actions = notification?.actions ?: return null

        for (action in actions) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                if (action.semanticAction == Notification.Action.SEMANTIC_ACTION_MARK_AS_READ) {
                    return action
                }
            }

            val label = action.title?.toString()?.lowercase() ?: continue
            if (READ_KEYWORDS.any { label.contains(it) }) {
                return action
            }
        }
        return null
    }

    fun buildReadPill(action: Notification.Action): NotificationCompat.Action {
        return NotificationCompat.Action.Builder(
            0,
            "✓ Read",
            action.actionIntent
        ).build()
    }
}
