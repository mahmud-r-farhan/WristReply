package com.wristreply.core.filters

import android.content.Context
import com.wristreply.core.model.PrefKeys

/**
 * LPTE (Language/Profanity Filter Engine) for on-device abusive content interception.
 * Prevents automated cheerful smart replies for toxic or abusive incoming messages.
 * Uses decoupled DefaultBlockedWords covering English, Spanish, German, Portuguese,
 * Arabic, Hindi, and Bengali.
 */
object ProfanityGuardEngine {

    fun containsAbusiveContent(
        context: Context,
        text: String,
        isShieldEnabled: Boolean = true
    ): Pair<Boolean, String?> {
        if (!isShieldEnabled) return Pair(false, null)

        val prefs = context.getSharedPreferences(PrefKeys.PREFS_FILTERS, Context.MODE_PRIVATE)
        val customWords = prefs.getStringSet(PrefKeys.KEY_CUSTOM_BLOCKED_WORDS, emptySet()) ?: emptySet()
        val combinedDictionary = DefaultBlockedWords.WORDS + customWords

        val normalized = text.lowercase().replace("[^a-zA-Z0-9\u0980-\u09FF\u0600-\u06FF\u0900-\u097F\\s]".toRegex(), " ")
        val tokens = normalized.split("\\s+".toRegex()).filter { it.isNotBlank() }

        for (token in tokens) {
            if (combinedDictionary.contains(token)) {
                return Pair(true, token)
            }
        }

        return Pair(false, null)
    }
}
