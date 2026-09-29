package com.wristreply.core.context

import android.content.Context
import com.wristreply.core.cache.UserPreferencesHotCache

/**
 * Injects context-aware pills based on real-time environmental sensors (Bluetooth A2DP & Calendar).
 */
object ContextualReplyEnhancer {

    fun enhanceSuggestions(
        context: Context,
        baseSuggestions: List<String>,
        prefsCache: UserPreferencesHotCache
    ): List<String> {
        val enhanced = baseSuggestions.toMutableList()

        // 1. Driving Mode Context Injection
        if (prefsCache.isDrivingModeEnabled() && DrivingModeDetector.isConnectedToCarOrAudio(context)) {
            enhanced.add(0, "Driving right now, will reply once parked.")
            enhanced.add(1, "[🚗 Driving]")
            return enhanced.distinct()
        }

        // 2. Calendar Busy Meeting Context Injection
        if (prefsCache.isCalendarModeEnabled()) {
            val meeting = CalendarMeetingDetector.getActiveBusyMeeting(context)
            if (meeting != null && meeting.isBusy) {
                enhanced.add(0, "In a meeting until ${meeting.formattedEndTime}, will get back to you.")
                enhanced.add(1, "[📅 Meeting until ${meeting.formattedEndTime}]")
                return enhanced.distinct()
            }
        }

        return enhanced
    }
}
