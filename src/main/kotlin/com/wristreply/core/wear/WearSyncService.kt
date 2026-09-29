package com.wristreply.core.wear

import android.content.Context
import android.content.Intent

/**
 * Local sync bridge for Wear OS, Zepp OS, and notification mirroring endpoints.
 */
object WearSyncService {

    const val ACTION_WRIST_REPLY_SYNC = "com.wristreply.core.ACTION_WEAR_SYNC"
    const val EXTRA_SUGGESTIONS = "EXTRA_SUGGESTIONS"
    const val EXTRA_NOTIFICATION_ID = "EXTRA_NOTIFICATION_ID"

    fun broadcastToWatch(
        context: Context,
        suggestions: List<String>,
        notificationId: Int
    ) {
        val intent = Intent(ACTION_WRIST_REPLY_SYNC).apply {
            putStringArrayListExtra(EXTRA_SUGGESTIONS, ArrayList(suggestions))
            putExtra(EXTRA_NOTIFICATION_ID, notificationId)
            setPackage(context.packageName)
        }
        context.sendBroadcast(intent)
    }
}
