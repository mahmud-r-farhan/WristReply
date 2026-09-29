import 'package:flutter/services.dart';
import '../constants/app_keys.dart';

/// Dart wrapper communicating directly with the headless Kotlin engine.
class NativeChannel {
  static const MethodChannel _channel = MethodChannel(AppKeys.methodChannel);

  static Future<bool> isListenerRunning() async {
    try {
      final res = await _channel.invokeMethod<bool>('isListenerRunning');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestListenerPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestListenerPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final res = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestBatteryExemption() async {
    try {
      await _channel.invokeMethod('requestBatteryExemption');
    } catch (_) {}
  }

  static Future<bool> openOemAutostart() async {
    try {
      final res = await _channel.invokeMethod<bool>('openOemAutostart');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getDiscoveredApps() async {
    try {
      final res = await _channel.invokeListMethod<dynamic>('getDiscoveredApps');
      if (res == null) return [];
      return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setAppWhitelisted(String packageName, bool enabled) async {
    try {
      await _channel.invokeMethod('setAppWhitelisted', {
        'packageName': packageName,
        'enabled': enabled,
      });
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> getEngineMetrics() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getEngineMetrics');
      return res ?? {};
    } catch (_) {
      return {};
    }
  }

  static Future<void> resetEngineMetrics() async {
    try {
      await _channel.invokeMethod('resetEngineMetrics');
    } catch (_) {}
  }

  static Future<List<String>> simulateSmartReply(String messageText) async {
    try {
      final res = await _channel.invokeListMethod<String>('simulateSmartReply', {
        'messageText': messageText,
      });
      return res ?? [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getPreferences');
      return res ?? {};
    } catch (_) {
      return {};
    }
  }

  static Future<void> updatePreference(String key, dynamic value) async {
    try {
      await _channel.invokeMethod('updatePreference', {
        'key': key,
        'value': value,
      });
    } catch (_) {}
  }
}
