/// Canonical text resources for WristReply AI.
class AppStrings {
  AppStrings._();

  static const String appName = 'WristReply AI';
  static const String tagline = 'Reply from your wrist. Not from the cloud.';
  static const String heroTagline = 'On-device smart replies for phones and every smartwatch.';

  static const String privacyPromiseTitle = '100% On-Device Isolation';
  static const String privacyPromiseDesc =
      'Your incoming chats never touch external servers. All intelligence runs locally via Google ML Kit with zero cloud connectivity.';

  static const String notificationBridgeTitle = 'Notification Bridge';
  static const String notificationBridgeDesc =
      'Required to read incoming context and inject quick-reply action pills.';

  static const String backgroundKeepAliveTitle = 'Background Keep-Alive';
  static const String backgroundKeepAliveDesc =
      'Exempts the engine from OEM battery killers to ensure instant phone replies and reliable wrist syncing.';

  static const String notificationPostingTitle = 'System Notifications (Optional)';
  static const String notificationPostingDesc =
      'Optional. Allows WristReply to show real-time background status alerts, delayed reply progress, and sync indicators.';

  static const String grantAccess = 'GRANT ACCESS';
  static const String whitelistMe = 'WHITELIST ME';
  static const String grantOptional = 'ENABLE OPTIONAL';
  static const String launchConsole = 'LAUNCH CONSOLE';

  static const String liveConsole = 'WRISTREPLY CONSOLE';
  static const String liveIndicator = 'LIVE';
  static const String engineStatus = 'HARDWARE & ENGINE STATUS';
  static const String performanceSnapshot = 'PERFORMANCE SNAPSHOT';
  static const String liveTestSandbox = 'LIVE TEST SANDBOX';
  static const String monitoredPlatforms = 'MONITORED PLATFORMS';
}
