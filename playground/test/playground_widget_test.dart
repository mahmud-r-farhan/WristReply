import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wristreply_playground/main.dart';

void main() {
  testWidgets('Playground renders the sandbox and the locale preview', (WidgetTester tester) async {
    await tester.pumpWidget(const PlaygroundApp());
    await tester.pump();

    expect(find.text('WristReply AI'), findsOneWidget);
    expect(find.text('LIVE TEST SANDBOX'), findsOneWidget);
    expect(find.text('MULTI-REGIONAL LOCALE PREVIEW'), findsOneWidget);
    expect(find.text('ARCHITECTURE'), findsOneWidget);
  });

  test('WebFallbackEngine routes Spanish keywords to Spanish gold', () {
    final result = WebFallbackEngine.resolve('Hola amigo, ¿dónde estás?', applyChronoBias: false);
    expect(result.localeLabel, 'es-ES');
    expect(result.replies, isNotEmpty);
    expect(
      result.replies.any((p) => p.contains('Dale') || p.contains('camino') || p.contains('hablar')),
      isTrue,
    );
  });

  test('WebFallbackEngine routes Arabic script to Arabic gold', () {
    final result = WebFallbackEngine.resolve('وينك يا غالي؟', applyChronoBias: false);
    expect(result.localeLabel, 'ar-MENA');
    expect(result.replies.any((p) => p.contains('تمام') || p.contains('الطريق')), isTrue);
  });

  test('WebFallbackEngine routes Bengali script to Bengali gold', () {
    final result = WebFallbackEngine.resolve('কেমন আছো?', applyChronoBias: false);
    expect(result.localeLabel, 'bn-BD');
    expect(result.replies.any((p) => p.contains('হ্যাঁ') || p.contains('কথা')), isTrue);
  });

  test('WebFallbackEngine falls back to English for plain text', () {
    final result = WebFallbackEngine.resolve('What time is dinner?', applyChronoBias: false);
    expect(result.localeLabel, 'en-US');
    expect(result.replies, contains('Sounds good!'));
  });
}