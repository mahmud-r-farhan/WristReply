import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/app_keys.dart';

/// Engine statistics returned by the headless Kotlin daemon.
@immutable
class EngineStats {
  final int repliesDispatched;
  final int avgLatencyMs;
  final int cacheHits;
  final bool isActive;

  const EngineStats({
    this.repliesDispatched = 0,
    this.avgLatencyMs = 18,
    this.cacheHits = 0,
    this.isActive = false,
  });

  factory EngineStats.fromMap(Map<String, dynamic> map) {
    return EngineStats(
      repliesDispatched: (map['repliesDispatched'] as num?)?.toInt() ?? 0,
      avgLatencyMs: (map['avgLatencyMs'] as num?)?.toInt() ?? 18,
      cacheHits: (map['cacheHits'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? false,
    );
  }
}

/// Discovered messaging app on the host device.
@immutable
class DiscoveredApp {
  final String packageName;
  final String appName;
  final bool isEnabled;

  const DiscoveredApp({
    required this.packageName,
    required this.appName,
    required this.isEnabled,
  });

  factory DiscoveredApp.fromMap(Map<String, dynamic> map) {
    return DiscoveredApp(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
    );
  }
}

/// Dart wrapper communicating directly with the headless Kotlin engine via
/// the `com.wristreply.app/engine` [MethodChannel]. Every call swallows
/// [PlatformException] / [MissingPluginException] and returns a safe default
/// so the UI stays alive even when the engine is unreachable (e.g. running
/// the playground on the web).
class NativeChannel {
  NativeChannel._();

  static const MethodChannel _channel = MethodChannel(AppKeys.methodChannel);

  // ----- Permissions ----------------------------------------------------
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

  static Future<bool> isNotificationPermissionGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isNotificationPermissionGranted');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('requestNotificationPermission');
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

  // ----- App discovery / whitelist --------------------------------------
  static Future<List<DiscoveredApp>> getDiscoveredApps() async {
    try {
      final res = await _channel.invokeListMethod<dynamic>('getDiscoveredApps');
      if (res == null) return const [];
      return res
          .map((dynamic e) => DiscoveredApp.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> setAppWhitelisted(String packageName, bool enabled) async {
    try {
      await _channel.invokeMethod('setAppWhitelisted', <String, Object?>{
        'packageName': packageName,
        'enabled': enabled,
      });
    } catch (_) {}
  }

  // ----- Metrics & simulation -------------------------------------------
  static Future<EngineStats> getEngineMetrics() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getEngineMetrics');
      return EngineStats.fromMap(res ?? const {});
    } catch (_) {
      return const EngineStats();
    }
  }

  static Future<void> resetEngineMetrics() async {
    try {
      await _channel.invokeMethod('resetEngineMetrics');
    } catch (_) {}
  }

  /// Generates smart replies for the supplied message text. Backs the live
  /// sandbox on the dashboard.
  ///
  /// On non-Android platforms the engine isn't available — we fall back to an
  /// offline locale-detection routine that mirrors the contract of the Kotlin
  /// `FallbackReplyEngine` (android/core-engine/nlp) so the live sandbox in the
  /// cockpit still demonstrates the same reply behaviour.
  static Future<List<String>> simulateSmartReply(String messageText) async {
    try {
      final res = await _channel.invokeListMethod<String>('simulateSmartReply', <String, Object?>{
        'messageText': messageText,
      });
      if (res != null && res.isNotEmpty) return res;
    } catch (_) {}
    return _webFallbackEngine(messageText);
  }

  /// Offline mirror of the Kotlin fallback engine, used by the playground.
  /// Mirrors the same priority order as `core-engine/nlp/FallbackReplyEngine.kt`.
  static List<String> _webFallbackEngine(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return const ['تمام، إن شاء الله!', 'أنا في الطريق!', 'مشغول الآن، بكلمك بعدين.'];
    }
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
      return const ['হ্যাঁ, ঠিক আছে!', 'আমি রাস্তায় আছি!', 'একটু পর কথা বলছি।'];
    }
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return const ['हाँ, बिल्कुल!', 'रास्ते में हूँ!', 'थोड़ी देर में बात करता हूँ।'];
    }
    if (RegExp(r'\b(donde|d[oó]nde|hola|gracias|amigo|vamos)\b').hasMatch(lower)) {
      return const ['¡Dale, suena bien!', '¡Voy en camino!', 'No puedo hablar ahora, te escribo.'];
    }
    if (RegExp(r'\b(wo|wie|hallo|danke|bitte|unterwegs|bist)\b').hasMatch(lower)) {
      return const ['Alles klar!', 'Bin unterwegs!', 'Kann gerade nicht, melde mich später.'];
    }
    if (RegExp(r'\b(onde|ol[áa]|obrigado|beleza|tudo)\b').hasMatch(lower)) {
      return const ['Beleza, combinado!', 'Estou a caminho!', 'Não posso falar agora, te ligo já.'];
    }
    if (RegExp(r'\b(o[uù]|comment|merci|salut|dispo)\b').hasMatch(lower)) {
      return const ['Ça marche !', 'Je suis en route !', 'Occupé pour le moment, je te rappelle.'];
    }
    if (RegExp(r'\b(kahan|kidhar|kya|badhiya|bhai)\b').hasMatch(lower)) {
      return const ['Theek hai, badhiya!', 'Raste me hu!', 'Abhi thoda busy hu, baad me call karta hu.'];
    }
    if (RegExp(r'\b(kothay|koi|kemon|aschis|hobe)\b').hasMatch(lower)) {
      return const ['Astechi 5 min e', 'Ekhon ektu busy achi', 'Call dao ektu por'];
    }
    return const ['Sounds good!', 'On my way!', "Can't talk now, text later."];
  }

  // ----- Preferences ----------------------------------------------------
  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('getPreferences');
      return res ?? const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  static Future<void> updatePreference(String key, dynamic value) async {
    try {
      await _channel.invokeMethod('updatePreference', <String, Object?>{
        'key': key,
        'value': value,
      });
    } catch (_) {}
  }
}
