import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/core/constants/app_keys.dart';
import 'package:wrist_reply/main.dart';

/// Smoke test verifying the app boots without throwing on the splash screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AppKeys.methodChannel);

  setUp(() {
    // SplashScreen pings isListenerRunning during initState.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isListenerRunning') return false;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('WristReplyApp boots and renders the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WristReplyApp());
    // The splash shows a CircularProgressIndicator while it probes the engine.
    expect(find.byType(WristReplyApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
