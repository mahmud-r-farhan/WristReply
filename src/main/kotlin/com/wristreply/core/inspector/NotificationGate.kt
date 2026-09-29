package com.wristreply.core.inspector

import android.app.Notification
import android.service.notification.StatusBarNotification

/**
 * Validates incoming notifications to filter out ongoing events, summary groups,
 * self-injected notifications, and empty alerts without allocating NLP compute.
 */
object NotificationGate {

    const val EXTRA_IS_WRIST_REPLY = "IS_WRIST_REPLY_INJECTED"

    fun shouldProcess(sbn: StatusBarNotification?): Boolean {
        if (sbn == null) return false
        val notification = sbn.notification ?: return false

        // 1. Prevent recursion on our own companion or cloned notifications
        if (notification.extras?.getBoolean(EXTRA_IS_WRIST_REPLY, false) == true) {
            return false
        }

        // 2. Reject ongoing events (media playback, downloads, foreground monitors)
        if ((notification.flags and Notification.FLAG_ONGOING_EVENT) != 0) {
            return false
        }

        // 3. Reject summary group headers (parent notifications)
        if ((notification.flags and Notification.FLAG_GROUP_SUMMARY) != 0) {
            return false
        }

        // 4. Ensure non-blank text content exists
        val text = notification.extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            ?: notification.extras?.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()

        return !text.isNullOrBlank()
    }
}
