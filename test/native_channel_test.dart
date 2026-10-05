import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/core/constants/app_keys.dart';
import 'package:wrist_reply/core/platform/native_channel.dart';

/// Mocks the platform [MethodChannel] used by [NativeChannel].
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AppKeys.methodChannel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NativeChannel graceful failure handling', () {
    test('isListenerRunning returns false on missing handler', () async {
      // No handler installed → PlatformException is thrown, NativeChannel catches it.
      final result = await NativeChannel.isListenerRunning();
      expect(result, isFalse);
    });

    test('isBatteryOptimizationIgnored returns false on missing handler', () async {
      final result = await NativeChannel.isBatteryOptimizationIgnored();
      expect(result, isFalse);
    });

    test('isNotificationPermissionGranted returns false on missing handler', () async {
      final result = await NativeChannel.isNotificationPermissionGranted();
      expect(result, isFalse);
    });

    test('openOemAutostart returns false on missing handler', () async {
      final result = await NativeChannel.openOemAutostart();
      expect(result, isFalse);
    });
  });

  group('NativeChannel normal success paths', () {
    test('isListenerRunning returns the value from the host', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'isListenerRunning') return true;
        return null;
      });
      expect(await NativeChannel.isListenerRunning(), isTrue);
    });

    test('getDiscoveredApps parses a list of maps', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getDiscoveredApps') {
          return [
            {'packageName': 'com.whatsapp', 'appName': 'WhatsApp', 'isEnabled': true},
            {'packageName': 'org.telegram.messenger', 'appName': 'Telegram', 'isEnabled': false},
          ];
        }
        return null;
      });
      final apps = await NativeChannel.getDiscoveredApps();
      expect(apps, hasLength(2));
      expect(apps[0].packageName, 'com.whatsapp');
      expect(apps[0].appName, 'WhatsApp');
      expect(apps[0].isEnabled, isTrue);
      expect(apps[1].isEnabled, isFalse);
    });

    test('getEngineMetrics parses the metric map', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getEngineMetrics') {
          return {
            'repliesDispatched': 12,
            'avgLatencyMs': 25,
            'cacheHits': 4,
            'isActive': true,
          };
        }
        return null;
      });
      final stats = await NativeChannel.getEngineMetrics();
      expect(stats.repliesDispatched, 12);
      expect(stats.avgLatencyMs, 25);
      expect(stats.cacheHits, 4);
      expect(stats.isActive, isTrue);
    });

    test('getEngineMetrics returns defaults when host returns empty map', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getEngineMetrics') return <String, dynamic>{};
        return null;
      });
      final stats = await NativeChannel.getEngineMetrics();
      expect(stats.repliesDispatched, 0);
      expect(stats.avgLatencyMs, 18);
      expect(stats.cacheHits, 0);
      expect(stats.isActive, isFalse);
    });

    test('simulateSmartReply falls back to English when host returns empty', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('Hey what is up?');
      expect(pills, isNotEmpty);
      expect(pills.first, isNotEmpty);
    });
  });

  group('Web fallback engine locale detection', () {
    test('Spanish keyword triggers Spanish gold', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('Hola amigo, ¿dónde estás?');
      expect(pills.any((p) => p.contains('Dale') || p.contains('camino')), isTrue);
    });

    test('German keyword triggers German gold', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('Hallo, wo bist du?');
      expect(pills.any((p) => p.contains('klar') || p.contains('unterwegs')), isTrue);
    });

    test('Arabic script triggers Arabic gold', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('وينك يا غالي؟');
      expect(pills.any((p) => p.contains('تمام') || p.contains('الطريق')), isTrue);
    });

    test('Bengali script triggers Bengali gold', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('কেমন আছো?');
      expect(pills.any((p) => p.contains('হ্যাঁ') || p.contains('কথা বলছি')), isTrue);
    });

    test('English defaults to English gold', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'simulateSmartReply') return <String>[];
        return null;
      });
      final pills = await NativeChannel.simulateSmartReply('What time is dinner?');
      expect(pills, contains('Sounds good!'));
    });
  });
}