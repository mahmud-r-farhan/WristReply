package com.wristreply.app.bridge

import android.content.Context
import com.wristreply.core.model.PrefKeys

/**
 * Persists configuration directly into Android SharedPreferences.
 * The headless background daemon reads these files directly without invoking Flutter.
 */
class PreferenceRepository(private val context: Context) {

    private val runtimePrefs = context.getSharedPreferences(PrefKeys.PREFS_RUNTIME, Context.MODE_PRIVATE)
    private val filterPrefs = context.getSharedPreferences(PrefKeys.PREFS_FILTERS, Context.MODE_PRIVATE)
    private val sleepPrefs = context.getSharedPreferences(PrefKeys.PREFS_SLEEP, Context.MODE_PRIVATE)

    fun getAllPreferences(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        map[PrefKeys.KEY_MASTER_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_MASTER_ENABLED, true)
        map[PrefKeys.KEY_NOTIFICATIONS_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_NOTIFICATIONS_ENABLED, true)
        map[PrefKeys.KEY_PILLS_PER_MESSAGE] = runtimePrefs.getInt(PrefKeys.KEY_PILLS_PER_MESSAGE, 3)
        map[PrefKeys.KEY_REPLACE_MODE] = runtimePrefs.getBoolean(PrefKeys.KEY_REPLACE_MODE, false)
        map[PrefKeys.KEY_PRIVACY_MODE] = runtimePrefs.getBoolean(PrefKeys.KEY_PRIVACY_MODE, false)
        map[PrefKeys.KEY_CONVERSATION_TONE] = runtimePrefs.getString(PrefKeys.KEY_CONVERSATION_TONE, "casual") ?: "casual"
        map[PrefKeys.KEY_CHRONO_BIAS_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_CHRONO_BIAS_ENABLED, true)
        map[PrefKeys.KEY_LOCATION_PIN_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_LOCATION_PIN_ENABLED, false)

        val pills = runtimePrefs.getStringSet(PrefKeys.KEY_CUSTOM_FALLBACK_PILLS, null)
            ?: emptySet()
        map[PrefKeys.KEY_CUSTOM_FALLBACK_PILLS] = pills.toList()

        map[PrefKeys.KEY_PROFANITY_SHIELD] = filterPrefs.getBoolean(PrefKeys.KEY_PROFANITY_SHIELD, true)
        val blockedWords = filterPrefs.getStringSet(PrefKeys.KEY_CUSTOM_BLOCKED_WORDS, emptySet()) ?: emptySet()
        map[PrefKeys.KEY_CUSTOM_BLOCKED_WORDS] = blockedWords.toList()

        map[PrefKeys.KEY_AUTO_COPY_OTP] = runtimePrefs.getBoolean(PrefKeys.KEY_AUTO_COPY_OTP, true)
        map[PrefKeys.KEY_AUTO_COPY_TRX] = runtimePrefs.getBoolean(PrefKeys.KEY_AUTO_COPY_TRX, true)

        map[PrefKeys.KEY_RESPECT_DND] = sleepPrefs.getBoolean(PrefKeys.KEY_RESPECT_DND, true)
        map[PrefKeys.KEY_SLEEP_WINDOW_ENABLED] = sleepPrefs.getBoolean(PrefKeys.KEY_SLEEP_WINDOW_ENABLED, false)
        return map
    }

    fun updateBoolean(key: String, value: Boolean) {
        when (key) {
            PrefKeys.KEY_PROFANITY_SHIELD -> filterPrefs.edit().putBoolean(key, value).apply()
            PrefKeys.KEY_RESPECT_DND, PrefKeys.KEY_SLEEP_WINDOW_ENABLED -> sleepPrefs.edit().putBoolean(key, value).apply()
            else -> runtimePrefs.edit().putBoolean(key, value).apply()
        }
    }

    fun updateString(key: String, value: String) {
        runtimePrefs.edit().putString(key, value).apply()
    }

    fun updateInt(key: String, value: Int) {
        runtimePrefs.edit().putInt(key, value).apply()
    }

    fun updateStringList(key: String, list: List<String>) {
        if (key == PrefKeys.KEY_CUSTOM_BLOCKED_WORDS) {
            filterPrefs.edit().putStringSet(key, list.toSet()).apply()
        } else {
            runtimePrefs.edit().putStringSet(key, list.toSet()).apply()
        }
    }
}
