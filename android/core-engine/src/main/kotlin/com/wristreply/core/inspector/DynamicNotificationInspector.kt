package com.wristreply.core.inspector

import android.app.Notification
import android.app.RemoteInput
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import com.wristreply.core.model.DynamicReplyTarget

/**
 * Dynamically discovers direct-reply endpoints across any messaging app at runtime
 * without hardcoding package names, inspecting RemoteInput and PendingIntent.
 */
object DynamicNotificationInspector {

    fun resolveReplyTarget(sbn: StatusBarNotification): DynamicReplyTarget? {
        val notification = sbn.notification ?: return null
        val packageName = sbn.packageName

        // Step 1: Validate messaging heuristics
        val isMessageCategory = notification.category == Notification.CATEGORY_MESSAGE
        val isMessagingStyle = notification.extras.containsKey(NotificationCompat.EXTRA_MESSAGING_STYLE_USER)
            || notification.extras.containsKey("android.messagingStyleUser")
        val hasText = notification.extras.getCharSequence(Notification.EXTRA_TEXT) != null

        if (!isMessageCategory && !isMessagingStyle && !hasText) {
            return null
        }

        // Step 2: Extract sender and message text
        val sender = notification.extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
            ?: notification.extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
            ?: "User"

        val message = notification.extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            ?: notification.extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            ?: return null

        // Step 3: Scan standard notification actions for live RemoteInput
        var targetAction: Notification.Action? = null
        var targetRemoteInput: RemoteInput? = null

        val actions = notification.actions
        if (actions != null) {
            outer@ for (action in actions) {
                val inputs = action.remoteInputs ?: continue
                for (input in inputs) {
                    if (!input.resultKey.isNullOrEmpty() && action.actionIntent != null) {
                        targetAction = action
                        targetRemoteInput = input
                        break@outer
                    }
                }
            }
        }

        // Step 4: Fallback to WearableExtender actions if standard tray has no inline input
        if (targetAction == null || targetRemoteInput == null) {
            val wearableExtender = NotificationCompat.WearableExtender(notification)
            for (action in wearableExtender.actions) {
                val actionIntent = action.actionIntent
                action.remoteInputs?.forEach { input ->
                    if (!input.resultKey.isNullOrEmpty() && actionIntent != null) {
                        return DynamicReplyTarget(
                            packageName = packageName,
                            senderName = sender,
                            messageText = message,
                            remoteInput = RemoteInput.Builder(input.resultKey).build(),
                            resultKey = input.resultKey,
                            pendingIntent = actionIntent,
                            isDirectReplyAllowed = true,
                            groupKey = notification.group,
                            originalNotification = notification
                        )
                    }
                }
            }
        }

        val resolvedAction = targetAction ?: return null
        val resolvedRemoteInput = targetRemoteInput ?: return null
        val resolvedIntent = resolvedAction.actionIntent ?: return null

        return DynamicReplyTarget(
            packageName = packageName,
            senderName = sender,
            messageText = message,
            remoteInput = resolvedRemoteInput,
            resultKey = resolvedRemoteInput.resultKey,
            pendingIntent = resolvedIntent,
            isDirectReplyAllowed = true,
            groupKey = notification.group,
            originalNotification = notification
        )
    }
}
