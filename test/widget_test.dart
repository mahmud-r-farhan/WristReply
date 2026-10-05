import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/core/constants/app_keys.dart';
import 'package:wrist_reply/features/onboarding/screens/disclosure_screen.dart';
import 'package:wrist_reply/main.dart';

/// Smoke test for the boot path: splash → disclosure when the notification
/// listener has not been granted yet.
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

  testWidgets('boots on the splash screen while the engine is probed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WristReplyApp());

    // The splash shows a CircularProgressIndicator while it probes the engine.
    expect(find.byType(WristReplyApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('routes to the disclosure screen when access is not granted', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WristReplyApp());

    // Let the post-frame callback resolve the permission probe and let the
    // replacement route finish its transition.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DisclosureScreen), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
