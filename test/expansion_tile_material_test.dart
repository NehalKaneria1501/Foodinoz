import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/core/widgets/brutalist_card.dart';
import 'package:jeerola/ui/features/help/views/help_support_screen.dart';

void main() {
  testWidgets('BrutalistCard and HelpSupportScreen render ListTile/ExpansionTile without assertions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              BrutalistCard(
                child: ExpansionTile(
                  title: const Text('Test Expansion'),
                  children: const [Text('Child content')],
                ),
              ),
              const Expanded(child: HelpSupportScreen()),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Help & Support Screen rendered cleanly
    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.byType(ExpansionTile), findsWidgets);
  });
}
