package com.wristreply.core.context

import android.content.Context
import com.wristreply.core.cache.UserPreferencesHotCache

/**
 * Injects context-aware pills based on real-time environmental sensors (Bluetooth A2DP & Calendar)
 * with multi-regional language awareness.
 */
object ContextualReplyEnhancer {

    private val SPANISH_PATTERN = Regex("(?i)\\b(hola|gracias|como|d\u00F3nde|amigo|vamos|qu\u00E9)\\b")
    private val GERMAN_PATTERN = Regex("(?i)\\b(hallo|danke|bitte|wie|wo|sp\u00E4ter|bist)\\b")
    private val PORTUGUESE_PATTERN = Regex("(?i)\\b(ol\u00E1|obrigado|beleza|onde|tudo|valeu)\\b")
    private val FRENCH_PATTERN = Regex("(?i)\\b(salut|merci|comment|o\u00F9|\u00E7a va)\\b")
    private val ARABIC_REGEX = Regex("[\u0600-\u06FF]")

    fun enhanceSuggestions(
        context: Context,
        baseSuggestions: List<String>,
        prefsCache: UserPreferencesHotCache,
        incomingText: String = ""
    ): List<String> {
        val enhanced = baseSuggestions.toMutableList()

        // 1. Driving Mode Context Injection
        if (prefsCache.isDrivingModeEnabled() && DrivingModeDetector.isConnectedToCarOrAudio(context)) {
            val template = prefsCache.getDrivingTemplate()
            val drivingPill = resolveDrivingPill(incomingText)
            enhanced.add(0, template)
            enhanced.add(1, drivingPill)
            return enhanced.distinct()
        }

        // 2. Calendar Busy Meeting Context Injection
        if (prefsCache.isCalendarModeEnabled()) {
            val meeting = CalendarMeetingDetector.getActiveBusyMeeting(context)
            if (meeting != null && meeting.isBusy) {
                val meetingPill = resolveMeetingPill(incomingText, meeting.formattedEndTime)
                val fullMsg = resolveMeetingMessage(incomingText, meeting.formattedEndTime)
                enhanced.add(0, fullMsg)
                enhanced.add(1, meetingPill)
                return enhanced.distinct()
            }
        }

        return enhanced
    }

    private fun resolveDrivingPill(text: String): String = when {
        SPANISH_PATTERN.containsMatchIn(text) -> "[🚗 Manejando]"
        GERMAN_PATTERN.containsMatchIn(text) -> "[🚗 Am Fahren]"
        PORTUGUESE_PATTERN.containsMatchIn(text) -> "[🚗 Dirigindo]"
        FRENCH_PATTERN.containsMatchIn(text) -> "[🚗 Au volant]"
        ARABIC_REGEX.containsMatchIn(text) -> "[🚗 أقود السيارة]"
        else -> "[🚗 Driving]"
    }

    private fun resolveMeetingPill(text: String, endTime: String): String = when {
        SPANISH_PATTERN.containsMatchIn(text) -> "[📅 En reunión hasta $endTime]"
        GERMAN_PATTERN.containsMatchIn(text) -> "[📅 Im Meeting bis $endTime]"
        PORTUGUESE_PATTERN.containsMatchIn(text) -> "[📅 Em reunião até $endTime]"
        FRENCH_PATTERN.containsMatchIn(text) -> "[📅 En réunion jusqu'à $endTime]"
        ARABIC_REGEX.containsMatchIn(text) -> "[📅 في اجتماع حتى $endTime]"
        else -> "[📅 Meeting until $endTime]"
    }

    private fun resolveMeetingMessage(text: String, endTime: String): String = when {
        SPANISH_PATTERN.containsMatchIn(text) -> "En una reunión hasta las $endTime, te respondo luego."
        GERMAN_PATTERN.containsMatchIn(text) -> "Im Meeting bis $endTime Uhr, melde mich danach."
        PORTUGUESE_PATTERN.containsMatchIn(text) -> "Em reunião até $endTime, respondo em breve."
        FRENCH_PATTERN.containsMatchIn(text) -> "En réunion jusqu'à $endTime, je reviens vers toi."
        ARABIC_REGEX.containsMatchIn(text) -> "في اجتماع حتى $endTime، سأتواصل معك لاحقاً."
        else -> "In a meeting until $endTime, will get back to you."
    }
}
