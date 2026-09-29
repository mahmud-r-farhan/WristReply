package com.wristreply.core.guard

import android.app.NotificationManager
import android.content.Context
import com.wristreply.core.model.PrefKeys
import java.util.Calendar

/**
 * Evaluates DND and scheduled quiet hours to achieve a zero-wake daemon state.
 */
object SleepWindowGate {

    fun shouldSuppressProcessing(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PrefKeys.PREFS_SLEEP, Context.MODE_PRIVATE)

        // 1. Check Do Not Disturb (DND) state
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        val dndState = notificationManager?.currentInterruptionFilter ?: NotificationManager.INTERRUPTION_FILTER_ALL
        val isDndSuppressed = dndState != NotificationManager.INTERRUPTION_FILTER_ALL
        val respectDnd = prefs.getBoolean(PrefKeys.KEY_RESPECT_DND, true)

        if (respectDnd && isDndSuppressed) {
            return true
        }

        // 2. Evaluate Scheduled Sleep Window
        val isSleepWindowEnabled = prefs.getBoolean(PrefKeys.KEY_SLEEP_WINDOW_ENABLED, false)
        if (!isSleepWindowEnabled) {
            return false
        }

        val startHour = prefs.getInt(PrefKeys.KEY_SLEEP_START_HOUR, 23)
        val startMinute = prefs.getInt(PrefKeys.KEY_SLEEP_START_MINUTE, 0)
        val endHour = prefs.getInt(PrefKeys.KEY_SLEEP_END_HOUR, 6)
        val endMinute = prefs.getInt(PrefKeys.KEY_SLEEP_END_MINUTE, 30)

        val calendar = Calendar.getInstance()
        val currentMinutes = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)
        val startMinutes = startHour * 60 + startMinute
        val endMinutes = endHour * 60 + endMinute

        return if (startMinutes <= endMinutes) {
            currentMinutes in startMinutes..endMinutes
        } else {
            currentMinutes >= startMinutes || currentMinutes <= endMinutes
        }
    }
}
