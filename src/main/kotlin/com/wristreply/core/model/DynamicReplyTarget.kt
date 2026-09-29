package com.wristreply.core.model

import android.app.Notification
import android.app.PendingIntent
import android.app.RemoteInput

/**
 * Immutable bundle encapsulating an extracted inline-reply target.
 */
data class DynamicReplyTarget(
    val packageName: String,
    val senderName: String,
    val messageText: String,
    val remoteInput: RemoteInput,
    val resultKey: String,
    val pendingIntent: PendingIntent,
    val isDirectReplyAllowed: Boolean = true,
    val groupKey: String? = null,
    val originalNotification: Notification? = null
)
