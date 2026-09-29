/// Keys matching the native Kotlin PrefKeys and MethodChannel interface.
class AppKeys {
  AppKeys._();

  static const String methodChannel = 'com.wristreply.app/engine';

  static const String keyMasterEnabled = 'wr_master_enabled';
  static const String keyPillsPerMessage = 'wr_pills_per_message';
  static const String keyReplaceMode = 'wr_replace_mode';
  static const String keyPrivacyMode = 'wr_privacy_mode';

  static const String keyConversationTone = 'wr_conversation_tone';
  static const String keyCustomFallbackPills = 'wr_custom_fallback_pills';
  static const String keyChronoBiasEnabled = 'wr_chrono_bias_enabled';
  static const String keyLocationPinEnabled = 'wr_location_pin_enabled';

  static const String keyProfanityShield = 'wr_profanity_shield';
  static const String keyCustomBlockedWords = 'wr_custom_blocked_words';

  static const String keyAutoCopyOtp = 'wr_auto_copy_otp';
  static const String keyAutoCopyTrx = 'wr_auto_copy_trx';

  static const String keyRespectDnd = 'wr_respect_dnd';
  static const String keySleepWindowEnabled = 'wr_sleep_window_enabled';

  static const String keyDelayedReplyEnabled = 'wr_delayed_reply_enabled';
  static const String keyDelayedReplyMinutes = 'wr_delayed_reply_minutes';
  static const String keyDelayedReplyTemplate = 'wr_delayed_reply_template';

  static const String keyDrivingModeEnabled = 'wr_driving_mode_enabled';
  static const String keyDrivingAutoReplyEnabled = 'wr_driving_auto_reply_enabled';
  static const String keyDrivingTemplate = 'wr_driving_template';
  static const String keyCalendarModeEnabled = 'wr_calendar_mode_enabled';
}
