package com.wristreply.core.cache

import android.content.Context
import android.content.SharedPreferences
import com.wristreply.core.model.PrefKeys
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArraySet

/**
 * Lock-free in-memory hot-cache mirroring SharedPreferences.
 * Eliminates synchronous disk reads during active notification streams.
 */
class UserPreferencesHotCache(context: Context) {

    private val runtimePrefs: SharedPreferences = context.getSharedPreferences(PrefKeys.PREFS_RUNTIME, Context.MODE_PRIVATE)
    private val whitelistPrefs: SharedPreferences = context.getSharedPreferences(PrefKeys.PREFS_WHITELIST, Context.MODE_PRIVATE)

    private val whitelistedApps = CopyOnWriteArraySet<String>()
    private val customFallbackPills = CopyOnWriteArraySet<String>()
    private val booleanFlags = ConcurrentHashMap<String, Boolean>()
    private val stringValues = ConcurrentHashMap<String, String>()
    private val intValues = ConcurrentHashMap<String, Int>()

    private val runtimeListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        key?.let { refreshRuntimeKey(it) }
    }

    init {
        hydrateAll()
        runtimePrefs.registerOnSharedPreferenceChangeListener(runtimeListener)
    }

    @Synchronized
    fun hydrateAll() {
        val savedApps = runtimePrefs.getStringSet(PrefKeys.KEY_WHITELISTED_PACKAGES, null)
            ?: setOf("com.whatsapp", "com.facebook.orca", "org.telegram.messenger", "com.google.android.apps.messaging")
        whitelistedApps.clear()
        whitelistedApps.addAll(savedApps)

        val savedPills = runtimePrefs.getStringSet(PrefKeys.KEY_CUSTOM_FALLBACK_PILLS, null)
            ?: setOf("On my way!", "In a meeting, call later.", "Sounds good!")
        customFallbackPills.clear()
        customFallbackPills.addAll(savedPills)

        booleanFlags[PrefKeys.KEY_MASTER_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_MASTER_ENABLED, true)
        booleanFlags[PrefKeys.KEY_NOTIFICATIONS_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_NOTIFICATIONS_ENABLED, true)
        booleanFlags[PrefKeys.KEY_REPLACE_MODE] = runtimePrefs.getBoolean(PrefKeys.KEY_REPLACE_MODE, false)
        booleanFlags[PrefKeys.KEY_PRIVACY_MODE] = runtimePrefs.getBoolean(PrefKeys.KEY_PRIVACY_MODE, false)
        booleanFlags[PrefKeys.KEY_PROFANITY_SHIELD] = runtimePrefs.getBoolean(PrefKeys.KEY_PROFANITY_SHIELD, true)
        booleanFlags[PrefKeys.KEY_AUTO_COPY_TRX] = runtimePrefs.getBoolean(PrefKeys.KEY_AUTO_COPY_TRX, true)
        booleanFlags[PrefKeys.KEY_AUTO_COPY_OTP] = runtimePrefs.getBoolean(PrefKeys.KEY_AUTO_COPY_OTP, true)
        booleanFlags[PrefKeys.KEY_CHRONO_BIAS_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_CHRONO_BIAS_ENABLED, true)
        booleanFlags[PrefKeys.KEY_LOCATION_PIN_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_LOCATION_PIN_ENABLED, false)
        booleanFlags[PrefKeys.KEY_DELAYED_REPLY_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_DELAYED_REPLY_ENABLED, false)
        booleanFlags[PrefKeys.KEY_DRIVING_MODE_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_DRIVING_MODE_ENABLED, false)
        booleanFlags[PrefKeys.KEY_DRIVING_AUTO_REPLY_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_DRIVING_AUTO_REPLY_ENABLED, false)
        booleanFlags[PrefKeys.KEY_CALENDAR_MODE_ENABLED] = runtimePrefs.getBoolean(PrefKeys.KEY_CALENDAR_MODE_ENABLED, false)

        stringValues[PrefKeys.KEY_CONVERSATION_TONE] = runtimePrefs.getString(PrefKeys.KEY_CONVERSATION_TONE, "casual") ?: "casual"
        stringValues[PrefKeys.KEY_DELAYED_REPLY_TEMPLATE] = runtimePrefs.getString(PrefKeys.KEY_DELAYED_REPLY_TEMPLATE, "Busy right now, will reply shortly.") ?: "Busy right now, will reply shortly."
        stringValues[PrefKeys.KEY_DRIVING_TEMPLATE] = runtimePrefs.getString(PrefKeys.KEY_DRIVING_TEMPLATE, "Driving right now, will reply once parked.") ?: "Driving right now, will reply once parked."
        intValues[PrefKeys.KEY_PILLS_PER_MESSAGE] = runtimePrefs.getInt(PrefKeys.KEY_PILLS_PER_MESSAGE, 3)
        intValues[PrefKeys.KEY_DELAYED_REPLY_MINUTES] = runtimePrefs.getInt(PrefKeys.KEY_DELAYED_REPLY_MINUTES, 5)
    }

    private fun refreshRuntimeKey(key: String) {
        when (key) {
            PrefKeys.KEY_WHITELISTED_PACKAGES -> {
                val updated = runtimePrefs.getStringSet(key, emptySet()) ?: emptySet()
                whitelistedApps.clear()
                whitelistedApps.addAll(updated)
            }
            PrefKeys.KEY_CUSTOM_FALLBACK_PILLS -> {
                val updated = runtimePrefs.getStringSet(key, emptySet()) ?: emptySet()
                customFallbackPills.clear()
                customFallbackPills.addAll(updated)
            }
            PrefKeys.KEY_CONVERSATION_TONE, PrefKeys.KEY_DELAYED_REPLY_TEMPLATE, PrefKeys.KEY_DRIVING_TEMPLATE -> {
                stringValues[key] = runtimePrefs.getString(key, "") ?: ""
            }
            PrefKeys.KEY_PILLS_PER_MESSAGE, PrefKeys.KEY_DELAYED_REPLY_MINUTES -> {
                intValues[key] = runtimePrefs.getInt(key, 3)
            }
            else -> {
                if (booleanFlags.containsKey(key)) {
                    booleanFlags[key] = runtimePrefs.getBoolean(key, false)
                }
            }
        }
    }

    fun isAppWhitelisted(packageName: String): Boolean {
        // First check explicit whitelist preference toggle if present
        if (whitelistPrefs.contains(packageName)) {
            return whitelistPrefs.getBoolean(packageName, true)
        }
        // Fall back to runtime package set or default true for any discovered messaging app
        return whitelistedApps.isEmpty() || whitelistedApps.contains(packageName)
    }

    fun isMasterEnabled(): Boolean = booleanFlags[PrefKeys.KEY_MASTER_ENABLED] ?: true
    fun isNotificationsEnabled(): Boolean = booleanFlags[PrefKeys.KEY_NOTIFICATIONS_ENABLED] ?: true
    fun isReplaceMode(): Boolean = booleanFlags[PrefKeys.KEY_REPLACE_MODE] ?: false
    fun isPrivacyMode(): Boolean = booleanFlags[PrefKeys.KEY_PRIVACY_MODE] ?: false
    fun isProfanityShieldEnabled(): Boolean = booleanFlags[PrefKeys.KEY_PROFANITY_SHIELD] ?: true
    fun isAutoCopyTrx(): Boolean = booleanFlags[PrefKeys.KEY_AUTO_COPY_TRX] ?: true
    fun isAutoCopyOtp(): Boolean = booleanFlags[PrefKeys.KEY_AUTO_COPY_OTP] ?: true
    fun isChronoBiasEnabled(): Boolean = booleanFlags[PrefKeys.KEY_CHRONO_BIAS_ENABLED] ?: true
    fun isLocationPinEnabled(): Boolean = booleanFlags[PrefKeys.KEY_LOCATION_PIN_ENABLED] ?: false
    fun isDelayedReplyEnabled(): Boolean = booleanFlags[PrefKeys.KEY_DELAYED_REPLY_ENABLED] ?: false
    fun isDrivingModeEnabled(): Boolean = booleanFlags[PrefKeys.KEY_DRIVING_MODE_ENABLED] ?: false
    fun isDrivingAutoReplyEnabled(): Boolean = booleanFlags[PrefKeys.KEY_DRIVING_AUTO_REPLY_ENABLED] ?: false
    fun getDrivingTemplate(): String = stringValues[PrefKeys.KEY_DRIVING_TEMPLATE] ?: "Driving right now, will reply once parked."
    fun isCalendarModeEnabled(): Boolean = booleanFlags[PrefKeys.KEY_CALENDAR_MODE_ENABLED] ?: false
    fun getDelayedReplyMinutes(): Int = intValues[PrefKeys.KEY_DELAYED_REPLY_MINUTES] ?: 5
    fun getDelayedReplyTemplate(): String = stringValues[PrefKeys.KEY_DELAYED_REPLY_TEMPLATE] ?: "Busy right now, will reply shortly."

    fun getConversationTone(): String = stringValues[PrefKeys.KEY_CONVERSATION_TONE] ?: "casual"
    fun getPillsPerMessage(): Int = intValues[PrefKeys.KEY_PILLS_PER_MESSAGE] ?: 3
    fun getCustomFallbackPills(): List<String> = customFallbackPills.toList()
}
