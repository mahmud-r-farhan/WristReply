package com.wristreply.core.model

/**
 * Shared preferences keys used across the Core Engine and Flutter bridge.
 * All keys prefixed with "wr_" for clean namespacing.
 */
object PrefKeys {
    const val PREFS_RUNTIME = "wrist_reply_runtime_prefs"
    const val PREFS_WHITELIST = "wrist_reply_whitelist_prefs"
    const val PREFS_FILTERS = "wrist_reply_filters"
    const val PREFS_SLEEP = "wrist_reply_sleep_prefs"

    const val KEY_MASTER_ENABLED = "wr_master_enabled"
    const val KEY_PILLS_PER_MESSAGE = "wr_pills_per_message"
    const val KEY_REPLACE_MODE = "wr_replace_mode"
    const val KEY_PRIVACY_MODE = "wr_privacy_mode"
    const val KEY_WHITELISTED_PACKAGES = "wr_whitelisted_packages"

    const val KEY_CONVERSATION_TONE = "wr_conversation_tone"
    const val KEY_CUSTOM_FALLBACK_PILLS = "wr_custom_fallback_pills"
    const val KEY_CHRONO_BIAS_ENABLED = "wr_chrono_bias_enabled"
    const val KEY_LOCATION_PIN_ENABLED = "wr_location_pin_enabled"

    const val KEY_PROFANITY_SHIELD = "wr_profanity_shield"
    const val KEY_CUSTOM_BLOCKED_WORDS = "wr_custom_blocked_words"

    const val KEY_AUTO_COPY_OTP = "wr_auto_copy_otp"
    const val KEY_AUTO_COPY_TRX = "wr_auto_copy_trx"

    const val KEY_RESPECT_DND = "wr_respect_dnd"
    const val KEY_SLEEP_WINDOW_ENABLED = "wr_sleep_window_enabled"
    const val KEY_SLEEP_START_HOUR = "wr_sleep_start_hour"
    const val KEY_SLEEP_START_MINUTE = "wr_sleep_start_minute"
    const val KEY_SLEEP_END_HOUR = "wr_sleep_end_hour"
    const val KEY_SLEEP_END_MINUTE = "wr_sleep_end_minute"

    const val KEY_DELAYED_REPLY_ENABLED = "wr_delayed_reply_enabled"
    const val KEY_DELAYED_REPLY_MINUTES = "wr_delayed_reply_minutes"
    const val KEY_DELAYED_REPLY_TEMPLATE = "wr_delayed_reply_template"
}
