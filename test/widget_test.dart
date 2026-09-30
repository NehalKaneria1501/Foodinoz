import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/main.dart';

void main() {
  testWidgets('JeerolaApp smoke test renders splash screen and brand', (WidgetTester tester) async {
    await tester.pumpWidget(const JeerolaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('JEEROLA'), findsWidgets);

    // Advance past splash transition
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
  });
}
