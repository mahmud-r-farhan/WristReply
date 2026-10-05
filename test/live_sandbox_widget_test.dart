import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/core/constants/app_keys.dart';
import 'package:wrist_reply/features/dashboard/widgets/live_sandbox_widget.dart';

/// Tests the [LiveSandboxWidget] interactive surface used by both the dashboard
/// and the GitHub Pages playground.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(AppKeys.methodChannel);

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'simulateSmartReply') {
        return <String>['Sounds good!', 'On my way!', 'Busy, text me'];
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('renders the seed text and the generated pills', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LiveSandboxWidget())));

    // Wait for the post-frame callback to fire and the pills to populate.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Sounds good'), findsWidgets);
    expect(find.text('GENERATED PILLS (TAP TO SIMULATE SEND):'), findsOneWidget);
  });

  testWidgets('tapping a pill surfaces the simulated-dispatch notice', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LiveSandboxWidget())));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final pillFinder = find.text('Sounds good!').first;
    await tester.tap(pillFinder);
    await tester.pump();

    expect(find.textContaining('Simulated dispatch'), findsOneWidget);
  });

  testWidgets('seed text can be customised', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LiveSandboxWidget(seedText: 'Custom seed message')),
      ),
    );

    expect(find.text('Custom seed message'), findsOneWidget);
  });
}
