import 'package:flutter_test/flutter_test.dart';
import 'package:wrist_reply/main.dart';

void main() {
  testWidgets('WristReplyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WristReplyApp());
    expect(find.byType(WristReplyApp), findsOneWidget);
  });
}
